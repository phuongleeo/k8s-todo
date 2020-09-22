// taken from terraform.tfvars

variable "aws_account" {}

variable "aws_region" {}

variable "remote_state_bucket" {}

variable "environment" {}

variable "domain_env" {}

variable "project" {}

variable "cidr_v4" {}

variable "instance_ssh_cidr_blocks" {
  default     = ["0.0.0.0/0"]
  description = "CIDR restriction on ec2 instances"
}

variable "ssh_key_name" {}

variable "jumphost_sg" {}

variable "vpc_id" {}
variable "squad" {}
variable "ingress_istio" {
  default = true
}

variable "ingress_nginx" {
  default = true
}
variable "harbor_enable" {
  default = false
}
