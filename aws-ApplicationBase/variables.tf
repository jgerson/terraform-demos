variable "network_workspace" {
  description = "Network workspace to utilize"
  default     = "notSet"
}

variable "environment" {
  description = "Environment Type - dev, stage, prod"
  default     = "notSet"
}

variable "application_name" {
  description = "Application Name"
  default     = "notSet"
}

variable "ami_id" {
  description = "AMI for launch"
  default     = "ami-aa2ea6d0"
}

variable "owner" {
  description = "Owner of Instance"
  default     = "notSet"
}

variable "ttl" {
  description = "Length of time the instance should stay alive - requires reaperbot to work"
  default     = "1"
}

variable "key_name" {
  description = "Key name to use for EC2 instance"
}

variable "instance_type" {
  description = "EC2 Instance Type"
  default     = "t2.micro"
}

variable "domain_root" {
  description = "Root of domain for site"
}

variable "WORKSPACE_TTL" {
  description = "TTL of how long workspace should stick around"
}
