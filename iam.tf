# Create execution role
resource "aws_iam_role" "lambda_role" {
  name = "image_optimizer_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_policy" "lambda_policy" {
  name = "image_optimizer_lambda_policy"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "AllowRetrievalOfUploadFile"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.images_bucket.arn}/${var.uploads_prefix}*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowWriteToThumbnails"
    actions = ["s3:PutObject"]
    resources = [
    "${aws_s3_bucket.images_bucket.arn}/${var.thumbnail_destination}*"]
    effect = "Allow"
  }

  # You can also attach the AWSLambdaBasicExecutionRole policy
  statement {
    sid = "AllowWritingToLogs"
    actions = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:CreateLogGroup"]
    resources = ["*"]
    effect = "Allow"
  }
}