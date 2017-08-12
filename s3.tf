provider "aws" {
  region = "us-east-1"
}

variable "bucket_name" {
  default = "tf_react_bucket_for_terrafuzz"
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

# we could also have terraform make a script for creating and deleting the bucket
resource "aws_s3_bucket" "react_bucket" {
  bucket     = "${var.bucket_name}"

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
