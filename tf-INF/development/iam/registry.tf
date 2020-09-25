data "aws_iam_policy_document" "harbor" {
  statement {
    actions = [
      "s3:Get*",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [
      "${data.terraform_remote_state.s3.outputs.chart_arn}",
    ]
  }
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${data.terraform_remote_state.s3.outputs.chart_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "harbor" {
  name   = "harbor-registry"
  policy = "${data.aws_iam_policy_document.harbor.json}"
}

resource "aws_iam_user" "harbor" {
  name = "harbor-registry"
  path = "/"
  tags = "${local.common_tags}"
}

resource "aws_iam_access_key" "harbor" {
  user = "${aws_iam_user.harbor.name}"
}

resource "aws_iam_user_policy_attachment" "harbor" {
  user       = "${aws_iam_user.harbor.name}"
  policy_arn = "${aws_iam_policy.harbor.arn}"
}
