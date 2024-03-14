data "aws_kms_key" "ssm_default" {
  key_id = "alias/aws/ssm"
}

resource "aws_ssm_parameter" "creds" {
  name   = "/unifi_ddns_route53_credentials"
  type   = "SecureString"
  value  = "CHANGE:ME"
  key_id = data.aws_kms_key.ssm_default.key_id

  lifecycle {
    ignore_changes = [value]
  }
}
