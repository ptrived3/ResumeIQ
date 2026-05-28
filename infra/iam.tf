# This is the role that Lambda will assume when it runs

resource "aws_iam_role" "lambda_role" {
  name = "resumeiq-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }
    ]
  })
}

# Allows Lambda to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Allows Lambda to read/write to the S3 bucket
resource "aws_iam_policy" "lambda_s3_policy" {
    name = "resumeiq-lambda-s3-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:PutObject",
                    "s3:GetObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    aws_s3_bucket.resumeiq.arn,
                    "${aws_s3_bucket.resumeiq.arn}/*"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.lambda_s3_policy.arn
  
}