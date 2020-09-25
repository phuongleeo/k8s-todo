resource "aws_route53_zone" "eks" {
  name = local.eks_domain
  tags = merge(local.common_tags,
  map("Kind", "external-dns"))
}
