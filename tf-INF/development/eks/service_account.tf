data "aws_iam_policy_document" "habor" {
  statement {
    actions = [
      "s3:Get*",
      "s3:ListBucket",
      "s3:GethaborConfiguration",
    ]

    resources = [
      "${data.terraform_remote_state.s3.outputs.chart_arn}/*",
      "${data.terraform_remote_state.s3.outputs.chart_arn}",
    ]
  }
}
data "aws_iam_policy_document" "habor_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "habor" {
  name               = "${var.environment}-s3-chart-habor"
  assume_role_policy = data.aws_iam_policy_document.habor_assume_role.json
  tags               = "${local.common_tags}"
}

resource "aws_iam_policy" "habor" {
  name   = "${var.environment}-s3-chart-habor"
  policy = data.aws_iam_policy_document.habor.json
}

resource "aws_iam_role_policy_attachment" "habor" {
  role       = "${aws_iam_role.habor.name}"
  policy_arn = "${aws_iam_policy.habor.arn}"
}
