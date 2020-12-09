module "jx" {
  source               = "jenkins-x/eks-jx/aws"
  version              = "1.13.1"
  apex_domain          = local.eks_domain
  region               = var.aws_region
  use_vault            = true
  use_asm              = false
  install_kuberhealthy = true
  enable_external_dns  = false
  create_exdns_role    = false
  cluster_name         = local.cluster_name // Cluster ID/Name of the EKS cluster where we want to install the jx cloud resources in
  is_jx2               = false
  create_eks           = false // Skip EKS creation
  create_vpc           = false // skip VPC creation
}
resource "local_file" "jx_requirements" {
  depends_on = [module.jx]
  content    = module.jx.jx_requirements
  filename   = "files/jx-requirements.yml"
}
//Next: Please follow up the instruction here to completely boot up Jenkins X
//https://github.com/jenkins-x/terraform-aws-eks-jx
