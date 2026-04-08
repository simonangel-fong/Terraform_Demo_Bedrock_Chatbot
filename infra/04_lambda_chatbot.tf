# lambda.tf
###############################
# IAM: lambda
###############################
# Assume Role
resource "aws_iam_role" "lambda" {
  name = var.app_name

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

# Attach the managed Full Access policy
resource "aws_iam_role_policy_attachment" "bedrock_full_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

# allow api to invoke lambda main
resource "aws_lambda_permission" "permission_api_invoke_lambda_main" {
  statement_id  = "AllowExecutionFromAPIGatewayPOSTChatbot"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot.function_name

  source_arn = "${aws_api_gateway_rest_api.app.execution_arn}/*/POST/chatbot"
}

###############################
# Lambda function: main
###############################
# file
data "archive_file" "pack_lambda" {
  type        = "zip"
  source_file = var.lambda_file_path
  output_path = var.lambda_zip_path
}

# lambda function: main
resource "aws_lambda_function" "chatbot" {
  function_name    = var.app_name
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  filename         = var.lambda_zip_path
  source_code_hash = data.archive_file.pack_lambda.output_base64sha256
  role             = aws_iam_role.lambda.arn

  timeout = 120 # prevent timeout
}
