variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = "alex-cluster"
}

variable "ssh_key_name" {
  description = "The name of the SSH key"
  type        = string
  default     = "alex-project3-kp"
}
