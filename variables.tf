variable "thumbnail_destination" {
  default = "thumbnails/"
}

variable "uploads_prefix" {
  default = "uploads/"
}

variable "image_bucket_prefix" {
  default = "user-images-"
}

variable "aws_profile" {
  default = "default"
  description = "AWS Profile name to use"
}