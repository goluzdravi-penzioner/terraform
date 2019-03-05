provider "aws" {}

resource "aws_s3_bucket" "jenkins-k8s-test" {
    bucket = "jenkins-k8s-test"
}