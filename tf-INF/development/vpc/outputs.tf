output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "subnet_public" {
  value = "${module.vpc.public_subnets}"
}

output "subnet_private" {
  value = "${module.vpc.private_subnets}"
}

output "nat_gateway_public_ip" {
  value = "${module.vpc.nat_public_ips}"
}
