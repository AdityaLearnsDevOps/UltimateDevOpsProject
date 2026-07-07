resource "aws_s3_bucket" "tf-remote-backend" {
    bucket = "tf-remote-backend-udemyproj"
    region = "ap-south-1"
    tags = {
      "name" = "UdemyProject"
    }

# Terraform specific block to notify terraform to avoid destroying this resource.
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_dynamodb_table" "tf-lock-tbl" {
  name           = "tf-state-file-lock-main-udemyproj"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockId"

  attribute {
    name = "LockId"
    type = "S"
  }

  tags = {
    "name" = "UdemyProject"
  }

# Terraform specific block to notify terraform to avoid destroying this resource.
  lifecycle {
    prevent_destroy = true
  }   
}