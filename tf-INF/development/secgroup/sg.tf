resource "aws_security_group" "eks" {
  name        = "EKS ${var.environment}"
  description = "EKS"
  vpc_id      = "${data.terraform_remote_state.vpc.outputs.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "allow internal"
    cidr_blocks = [var.cidr_v4]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags,
  map("Name", "Default EKS - ${var.environment} "))
}
