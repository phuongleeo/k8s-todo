resource "aws_lb" "public_ingress" {
  name                             = "public-ingress"
  load_balancer_type               = "network"
  subnets                          = data.aws_subnet_ids.public.ids
  enable_cross_zone_load_balancing = true

  tags = local.common_tags
}
