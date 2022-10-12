# Lambda / S3 Demo - Basic event-driven example

**Requirement:**
When a user uploads an image, create a thumbnail of that image.

Assume that we already have the image uploading functionality implemented, and it uses S3.


### Requirements to run

- [Terraform](https://www.terraform.io/downloads)
- An AWS account (this demo is within the free tier)
- AWS CLI installed and configured

```bash
# Initialize terraform
terraform init
# Create resources
terraform apply
# Destroy resources when done
terraform destroy
```