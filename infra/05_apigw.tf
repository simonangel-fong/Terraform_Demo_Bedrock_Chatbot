###############################
# IAM for API Gateway
###############################
# Assume Role
resource "aws_iam_role" "api_gateway" {
  name = "${var.app_name}-api-gateway"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# allow cloudwatch log
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_policy" {
  role       = aws_iam_role.api_gateway.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# cloudwatc log group
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${aws_api_gateway_rest_api.app.name}"
  retention_in_days = 7
}

# ###############################
# API Gateway
# ###############################
resource "aws_api_gateway_rest_api" "app" {
  name = var.app_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ###################################################
# API Gateway Deployment(immutable snapshot)
# ###################################################
resource "aws_api_gateway_deployment" "app" {
  rest_api_id = aws_api_gateway_rest_api.app.id

  # Redeploy when any method/integration changes
  triggers = {
    redeployment = sha1(jsonencode([
      # POST /chatbot
      aws_api_gateway_method.chatbot_post,
      aws_api_gateway_integration.chatbot_post,

      # OPTIONS /chatbot
      aws_api_gateway_method.cors_option,
      aws_api_gateway_integration.cors_option,
      aws_api_gateway_method_response.cors_option,
      aws_api_gateway_integration_response.cors_option,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    # POST /chatbot
    aws_api_gateway_method.chatbot_post,
    aws_api_gateway_integration.chatbot_post,

    # OPTIONS /chatbot
    aws_api_gateway_method.cors_option,
    aws_api_gateway_integration.cors_option,
    aws_api_gateway_method_response.cors_option,
    aws_api_gateway_integration_response.cors_option,
  ]
}

###############################
# API Gateway stage
###############################
resource "aws_api_gateway_stage" "app" {
  stage_name    = var.env
  deployment_id = aws_api_gateway_deployment.app.id
  rest_api_id   = aws_api_gateway_rest_api.app.id
}




