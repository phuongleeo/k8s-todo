// taken from terraform.tfvars

variable "aws_account" {}

variable "aws_region" {}

variable "remote_state_bucket" {}

variable "environment" {}

variable "domain_env" {}

variable "project" {}

variable "cidr_v4" {}

variable "ssh_key_name" {}

variable "vpc_id" {}

variable "ingress_istio" {
  default = true
}

variable "ingress_nginx" {
  default = true
}
variable "harbor_enable" {
  default = false
}

variable "domain_name" {}
