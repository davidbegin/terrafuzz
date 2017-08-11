provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "react_bucket" {
  bucket = "tf_react_bucket_for_terrafuzz"
}
