terraform {
  backend "s3" {
    key = "stacks/route53"
  }
}
data "aws_route53_zone" "zone" {
  name = "${local.domain}."
}
