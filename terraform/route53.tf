resource "aws_route53_record" "secret" {
  name    = var.domain_name
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.ddns.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.ddns.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
