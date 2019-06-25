variable "name" {
  type        = "string"
  description = "Unique identifier for the Node Group"
}

variable "cluster_name" {
  type        = "string"
  description = "Cluster name provided when the cluster was created and Eks node will join to the same cluster"
}

variable "cluster_endpoint" {
  type        = "string"
  description = "Endpoint of the Kubernetes Controle Plane"
}

variable "cluster_certificate" {
  type        = "string"
  description = "Certificate used to authenticate to the Kubernetes Controle Plane"
}

variable "subnet_ids" {
  type        = "list"
  description = "Subnet IDs for where EKS node will be created"
}

variable "security_groups" {
  type        = "list"
  description = "The security groups assigned to the EKS nodes and EKS node will join to the same security groups"
}

variable "ami_id" {
  default     = ""
  description = "AMI id for the EKS node instances"
}

variable "ami_lookup" {
  default     = "amazon-eks-node-*"
  description = "AMI lookup name for the EKS node"
}

variable "instance_type" {
  default     = "t2.medium"
  description = "Instance type for the EKS node instances"
}

variable "instance_profile" {
  type        = "string"
  description = "Instance Profile which has the required policies to add the EKS node to the cluster"
}

variable "min_size" {
  default     = 1
  description = "Minimum size of EKS Node in Autoscalling groups"
}

variable "max_size" {
  default     = 2
  description = "Maximum size of EKS Node in Autoscalling groups"
}

variable "bootstrap_arguments" {
  default     = ""
  description = "Additional Arguments when bootstrapping the EKS node"
}

variable "user_data" {
  default     = ""
  description = "Additional user data used when bootstrapping the EC2 instance"
}

variable "key_pair" {
  default     = ""
  description = "SSH Key Pair to allow SSH access to the instances"
}