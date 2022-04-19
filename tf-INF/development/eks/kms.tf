resource "aws_kms_key" "vault_test" {
  description = "KMS key for vault autounseal"
}

resource "aws_kms_alias" "vault_kms_alias" {
  target_key_id = aws_kms_key.vault_test.key_id
  name          = "alias/vault-test-autounseal"
}