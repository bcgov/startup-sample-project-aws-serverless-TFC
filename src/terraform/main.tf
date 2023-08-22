provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "site" {
  bucket = "${var.app_name}-site-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.app_name} site."
}

resource "aws_s3_bucket_policy" "site_policy" {
  bucket = aws_s3_bucket.site.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "AWS" : "${aws_cloudfront_origin_access_identity.oai.iam_arn}"
        },
        Action   = "s3:GetObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.site.bucket}/*"
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Distribution for ${var.app_name} site."
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.site.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.site.bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "${var.app_name}-distribution"
  }
}

data "archive_file" "store_greeting_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../api/lambda_functions/store_greeting"
  output_path = "${path.module}/../api/out/lambda_functions/store_greeting.zip"
}

resource "aws_lambda_function" "store_greeting" {
  function_name    = "${var.app_name}-storeGreeting"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  filename         = data.archive_file.store_greeting_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.store_greeting_zip.output_path)
  role             = aws_iam_role.lambda_execution.arn

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.greetings.name
    }
  }
}

data "archive_file" "get_greetings_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../api/lambda_functions/get_greetings"
  output_path = "${path.module}/../api/out/lambda_functions/get_greetings.zip"
}

resource "aws_lambda_function" "get_all_greetings" {
  function_name    = "${var.app_name}-getAllGreetings"
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  filename         = data.archive_file.get_greetings_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.get_greetings_zip.output_path)
  role             = aws_iam_role.lambda_execution.arn

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.greetings.name
    }
  }
}

resource "aws_iam_role" "lambda_execution" {
  name = "${var.app_name}-lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_cloudwatch_logs" {
  name        = "${var.app_name}-LambdaCloudWatchLogs"
  description = "Grants permissions for Lambda to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_attach" {
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
  role       = aws_iam_role.lambda_execution.name
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name   = "${var.app_name}-dynamodb_access"
  role   = aws_iam_role.lambda_execution.id
  policy = data.aws_iam_policy_document.dynamodb_access.json
}

data "aws_iam_policy_document" "dynamodb_access" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:Scan"
    ]
    resources = [aws_dynamodb_table.greetings.arn]
  }
}

resource "aws_dynamodb_table" "greetings" {
  name         = "${var.app_name}-greetings"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "createdAt" # This is your sort key

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S" # Assuming createdAt is a string, like an ISO timestamp.
  }
}

resource "aws_apigatewayv2_api" "greetings_api" {
  name          = "${var.app_name}-greetings-api"
  protocol_type = "HTTP"
  description   = "HTTP API for Greetings"

  cors_configuration {
    allow_headers  = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods  = ["OPTIONS", "GET", "POST"]
    allow_origins  = ["*"]
    expose_headers = ["x-api-id", "x-api-caller-id"]
    max_age        = 300
  }
}

resource "aws_apigatewayv2_route" "post_greeting" {
  api_id    = aws_apigatewayv2_api.greetings_api.id
  route_key = "POST /api/v1/greeting"
  target    = "integrations/${aws_apigatewayv2_integration.post_greeting_lambda.id}"
}

resource "aws_apigatewayv2_integration" "post_greeting_lambda" {
  api_id             = aws_apigatewayv2_api.greetings_api.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "Lambda integration for storing greetings"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.store_greeting.invoke_arn
}

resource "aws_apigatewayv2_route" "get_all_greetings" {
  api_id    = aws_apigatewayv2_api.greetings_api.id
  route_key = "GET /api/v1/greeting/latest"
  target    = "integrations/${aws_apigatewayv2_integration.get_all_greetings_lambda.id}"
}

resource "aws_apigatewayv2_integration" "get_all_greetings_lambda" {
  api_id             = aws_apigatewayv2_api.greetings_api.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "Lambda integration for retrieving all greetings"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.get_all_greetings.invoke_arn
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.greetings_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gw_v2_store_greeting" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.store_greeting.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.greetings_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_v2_get_all_greetings" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_all_greetings.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.greetings_api.execution_arn}/*/*"
}
