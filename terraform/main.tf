terraform {
  backend "s3" {
    bucket         = "alex-project3-state-bucket"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "project3-terraform-lock-table"
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = "alex-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.33.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "alex-node-group-1"

      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 5
      desired_size = 3
    }
  }
}

# Get the Auto Scaling Group name for the EKS node group
data "aws_autoscaling_groups" "eks_node_groups" {
  filter {
    name   = "tag:eks:nodegroup-name"
    values = ["alex-node-group-1-20250130220340297600000004"]
  }
}

# Define a CPU-based scaling policy
resource "aws_autoscaling_policy" "cpu_based_scaling" {
  name                   = "cpu-based-scaling"
  autoscaling_group_name = data.aws_autoscaling_groups.eks_node_groups.names[0]
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}

# Define a memory-based scaling policy using step scaling
resource "aws_autoscaling_policy" "memory_based_scaling" {
  name                   = "memory-based-scaling"
  autoscaling_group_name = data.aws_autoscaling_groups.eks_node_groups.names[0]
  policy_type            = "StepScaling"
  adjustment_type        = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = 1 # Add 1 instance
    metric_interval_lower_bound = 0 # Trigger when memory utilization is above 75%
  }

  step_adjustment {
    scaling_adjustment          = -1 # Remove 1 instance
    metric_interval_upper_bound = 0  # Trigger when memory utilization is below 75%
  }

  # CloudWatch alarm for high memory utilization
  metric_aggregation_type   = "Average"
  estimated_instance_warmup = 300 # Warm-up time for new instances (in seconds)
}

# Create a CloudWatch alarm for high memory utilization
resource "aws_cloudwatch_metric_alarm" "high_memory_utilization" {
  alarm_name          = "high-memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = 300                 # 5 minutes
  statistic           = "Average"
  threshold           = 75.0 # Trigger at 75% memory utilization
  alarm_actions       = [aws_autoscaling_policy.memory_based_scaling.arn]

  dimensions = {
    AutoScalingGroupName = data.aws_autoscaling_groups.eks_node_groups.names[0]
  }
}

# Create a CloudWatch alarm for low memory utilization
resource "aws_cloudwatch_metric_alarm" "low_memory_utilization" {
  alarm_name          = "low-memory-utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = 300                 # 5 minutes
  statistic           = "Average"
  threshold           = 75.0 # Trigger at 75% memory utilization
  alarm_actions       = [aws_autoscaling_policy.memory_based_scaling.arn]

  dimensions = {
    AutoScalingGroupName = data.aws_autoscaling_groups.eks_node_groups.names[0]
  }
}