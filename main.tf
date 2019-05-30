data "aws_elb_service_account" "default" {}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.1.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.default.arn}"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${module.label.id}/*",
    ]
  }
}

data "aws_iam_policy_document" "legacy_bucket" {
  statement {
    sid = ""

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_elb_service_account.default.arn}"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.legacy_bucket}/*",
    ]
  }
}

module "s3_bucket" {
  source                 = "git::https://github.com/GMADLA/terraform-aws-s3-log-storage.git?ref=tags/0.5.0-dev.2"
  namespace              = "${var.namespace}"
  stage                  = "${var.stage}"
  name                   = "${var.name}"
  region                 = "${var.region}"
  acl                    = "${var.acl}"
  policy                 = "${var.legacy_bucket == "" ?  data.aws_iam_policy_document.default.json: data.aws_iam_policy_document.legacy_bucket.json}"
  force_destroy          = "${var.force_destroy}"
  versioning_enabled     = "true"
  lifecycle_rule_enabled = "false"
  delimiter              = "${var.delimiter}"
  attributes             = "${var.attributes}"
  tags                   = "${var.tags}"
  prefix                 = "${var.prefix}"
}
