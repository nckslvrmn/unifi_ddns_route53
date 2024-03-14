resource "aws_apigatewayv2_api" "ddns" {
  name          = "ddns"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.ddns.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "ddns" {
  api_id    = aws_apigatewayv2_api.ddns.id
  route_key = "GET /nic/update"
  target    = "integrations/${aws_apigatewayv2_integration.ddns.id}"
}

resource "aws_apigatewayv2_integration" "ddns" {
  api_id           = aws_apigatewayv2_api.ddns.id
  integration_type = "AWS_PROXY"

  description            = "update ddns"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.ddns.arn
  payload_format_version = "2.0"

  lifecycle {
    ignore_changes = [passthrough_behavior]
  }
}

resource "aws_apigatewayv2_domain_name" "ddns" {
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = var.acm_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "ddns" {
  api_id      = aws_apigatewayv2_api.ddns.id
  domain_name = aws_apigatewayv2_domain_name.ddns.id
  stage       = aws_apigatewayv2_stage.default.id
}
