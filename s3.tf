provider "aws" {
  region = "us-east-1"
}

data "template_file" "empty_bucket_script" {
  template = "${file("${path.module}/empty_bucket.tpl")}"

  vars {
    bucket_name  = "${aws_s3_bucket.react_bucket.bucket}"
  }
}

data "template_file" "populate_bucket_script" {
  template = "${file("${path.module}/populate_bucket.tpl")}"

  vars {
    bucket_name  = "${aws_s3_bucket.react_bucket.bucket}"
  }
}

resource "null_resource" "create_local_empty_bucket_script" {
  triggers {
    template = "${data.template_file.empty_bucket_script.rendered}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.empty_bucket_script.rendered}\" > empty_bucket.sh; chmod +x empty_bucket.sh"
  }
}

resource "null_resource" "create_local_populate_bucket_script" {
  triggers {
    template = "${data.template_file.populate_bucket_script.rendered}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.populate_bucket_script.rendered}\" > populate_bucket.sh; chmod +x populate_bucket.sh"
  }
}

resource "aws_s3_bucket" "react_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "public-read"


  website {
    index_document = "index.html"
    error_document = "index.html"

    routing_rules = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "docs/"
    },
    "Redirect": {
        "ReplaceKeyPrefixWith": "documents/"
    }
}]
EOF
  }

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/*"
    }
  ]
}
POLICY
}
