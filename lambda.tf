# Create a zip of the function code
data "archive_file" "function_archive" {
  type        = "zip"
  output_path = "main.zip"
  source_file = "main.py"
}

# Create lambda function
resource "aws_lambda_function" "image_optimizer" {
  filename         = data.archive_file.function_archive.output_path
  source_code_hash = data.archive_file.function_archive.output_base64sha256
  function_name    = "ImageOptimizer"
  description      = "Optimizes user image uploads"
  handler          = "main.lambda_handler"
  role             = aws_iam_role.lambda_role.arn

  runtime     = "python3.8"
  memory_size = 256
  timeout     = 60

  architectures = ["x86_64"]
  layers = [
    "arn:aws:lambda:us-west-2:770693421928:layer:Klayers-p38-Pillow:4",
    "arn:aws:lambda:us-west-2:017000801446:layer:AWSLambdaPowertoolsPython:37"
  ]

  environment {
    variables = {
      IMAGES_BUCKET = aws_s3_bucket.images_bucket.bucket
      THUMBNAIL_DESTINATION = var.thumbnail_destination
      POWERTOOLS_SERVICE_NAME = "ImageOptimizer"
    }
  }
}

# Allow S3 to invoke lambda
resource "aws_lambda_permission" "allow_bucket_notification" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_optimizer.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.images_bucket.arn
}

# Create cloudwatch log group
resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${aws_lambda_function.image_optimizer.function_name}"
  retention_in_days = 30
}
