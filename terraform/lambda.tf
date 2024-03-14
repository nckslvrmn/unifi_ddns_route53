resource "aws_lambda_function" "ddns" {
  filename      = "${path.module}/placeholder.zip"
  function_name = "ddns"
  role          = aws_iam_role.ddns.arn
  handler       = "lambda.handler"
  runtime       = "python3.12"
  memory_size   = 2048
  timeout       = 5

  environment {
    variables = {
      HOSTED_ZONE_ID = var.hosted_zone_id
    }
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_lambda_permission" "allow_apig" {
  statement_id  = "AllowExecutionFromAPIG"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ddns.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.ddns.execution_arn}/*"
}
