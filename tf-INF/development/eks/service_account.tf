data "aws_iam_policy_document" "harbor" {
  statement {
    actions = [
      "s3:Get*",
      "s3:ListBucket",
      "s3:GetharborConfiguration",
    ]

    resources = [
      "${data.terraform_remote_state.s3.outputs.chart_arn}/*",
      "${data.terraform_remote_state.s3.outputs.chart_arn}",
    ]
  }
}
data "aws_iam_policy_document" "harbor_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "harbor" {
  name               = "${var.environment}-s3-chart-harbor"
  assume_role_policy = data.aws_iam_policy_document.harbor_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "harbor" {
  name   = "${var.environment}-s3-chart-harbor"
  policy = data.aws_iam_policy_document.harbor.json
}

resource "aws_iam_role_policy_attachment" "harbor" {
  role       = aws_iam_role.harbor.name
  policy_arn = aws_iam_policy.harbor.arn
}

/////////////
//external_dns
data "aws_iam_policy_document" "external_dns" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets"
    ]

    resources = [
      data.terraform_remote_state.route53.outputs.eks_zone_id
    ]
  }
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets"
    ]

    resources = [
      "*",
    ]
  }

}
data "aws_iam_policy_document" "external_dns_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["route53.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "external_dns" {
  name               = "${var.environment}-external_dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json
  tags               = local.common_tags
}

resource "aws_iam_policy" "external_dns" {
  name   = "${var.environment}-external_dns"
  policy = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}
