# Providers
provider "kubernetes" {
  host                   = data.aws_eks_cluster.project_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.project_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.project_cluster_auth.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.project_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.project_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.project_cluster_auth.token
  }
}

# Data Sources
data "aws_eks_cluster" "project_cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "project_cluster_auth" {
  name = data.aws_eks_cluster.project_cluster.name
}

# Resources
resource "aws_iam_policy" "alb_ingress_controller_policy" {
  name        = "alb-ingress-controller-policy"
  description = "IAM policy for ALB Ingress Controller"
  policy      = file("iam_policy.json")
}

resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.5.0"

  set {
    name  = "replicaCount"
    value = "1"
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa_alb_ingress_controller.iam_role_arn
  }
}

# Modules
module "irsa_alb_ingress_controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.41.0"

  create_role                   = true
  role_name                     = "AwsEKSALBIngressControllerRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [aws_iam_policy.alb_ingress_controller_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}