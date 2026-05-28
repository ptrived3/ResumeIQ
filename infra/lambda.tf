resource "aws_lambda_function" "resumeiq" {
    s3_bucket        = aws_s3_bucket.resumeiq.bucket
    s3_key           = "lambda.zip"
    source_code_hash = filebase64sha256("lambda.zip")
    function_name    = "resumeiq-analyzer"  // Name of the Lambda function
    role             = aws_iam_role.lambda_role.arn
    handler          = "main.handler"  // The function within your code that Lambda calls to begin execution
    runtime          = "python3.11"  // The runtime environment for the Lambda function
    memory_size      = 512 // Amount of memory allocated to the Lambda function (in MB)
    timeout          = 60  // Maximum time that the function can run before it is terminated

    environment {
      variables = {
        S3_BUCKET_NAME = aws_s3_bucket.resumeiq.bucket
        OPENAI_API_KEY = var.openai_api_key
      }
    }
}


resource "aws_apigatewayv2_api" "resumeiq" {
  name          = "resumeiq-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "resumeiq" {
  api_id             = aws_apigatewayv2_api.resumeiq.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.resumeiq.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "analyze" {
  api_id    = aws_apigatewayv2_api.resumeiq.id
  route_key = "POST /analyze"
  target    = "integrations/${aws_apigatewayv2_integration.resumeiq.id}"
}

resource "aws_apigatewayv2_route" "results" {
  api_id    = aws_apigatewayv2_api.resumeiq.id
  route_key = "GET /results/{job_id}"
  target    = "integrations/${aws_apigatewayv2_integration.resumeiq.id}"
}

resource "aws_apigatewayv2_stage" "resumeiq" {
  api_id      = aws_apigatewayv2_api.resumeiq.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resumeiq.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.resumeiq.execution_arn}/*/*"
}

output "api_url" {
  value = aws_apigatewayv2_stage.resumeiq.invoke_url
}