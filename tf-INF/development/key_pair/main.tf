terraform {
  backend "s3" {
    key = "stacks/key-pair"
  }
}
module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.4.0"
  stage                = var.environment
  name                    = "honestbee.pem"
  description             = "KMS SSH key"
  deletion_window_in_days = 30
  enable_key_rotation     = false
}

module "ssh_key_pair" {
  source  = "cloudposse/ssm-tls-ssh-key-pair/aws"
  version = "0.4.0"
  stage                = var.environment
  kms_key_id = module.kms_key.key_id
  name                 = "honestbee.pem"
  ssm_path_prefix      = "ssh_keys"
  ssh_key_algorithm    = "RSA"
  tags = "${local.common_tags}"
}

resource "aws_key_pair" "honestbee" {
  key_name   = "honestbee-${var.environment}.pem"
  public_key = module.ssh_key_pair.public_key
}
data "aws_ssm_parameter" "honestbee" {
  depends_on = ["module.ssh_key_pair"]
  name = module.ssh_key_pair.ssh_private_key_ssm_path
  with_decryption = true
}