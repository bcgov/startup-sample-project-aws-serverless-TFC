# Output value definitions

output "apigw_url" {
  description = "Base URL for API Gateway stage."
  value       = aws_apigatewayv2_api.greetings_api.api_endpoint
}
