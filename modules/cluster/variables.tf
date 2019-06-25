variable "name" {
  type        = "string"
  description = "Name for EKS cluster."
}

variable "eks_version" {
  default     = "1.10"
  description = "Kubernetes version for cluster"
}

variable "vpc_id" {
  type        = "string"
  description = "VPC ID where cluster need to be created."
}

variable "subnet_ids" {
  type        = "list"
  description = "VPC subnet IDs which the cluster uses"
}

variable "cidr_block" {
  default     = []
  description = "Inbound traffic to the Kubernetes control plane"
}

variable "ssh_cidr" {
  default     = ""
  description = "Allow incoming ssh connections to the EKS nodes"
}

variable "enable_kubectl" {
  default     = true
  description = "If you enable, it will merge the cluster's configuration with the one located in ~/.kube/config"
}

variable "enable_dashboard" {
  default     = true
  description = "If you enable, it will install the K8s Dashboard"
}

variable "aws_auth" {
  default     = ""
  description = "AWS users or roles the ability to interact with the EKS cluster"
}

variable "cluster_private_access" {
  default     = false
  description = "If you enable this, Amazon EKS private API server endpoint is enabled"
}

variable "cluster_public_access" {
  default     = true
  description = "If you enable this, Amazon EKS public API server endpoint is enabled."
}