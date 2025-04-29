output "api_gateway_url" {
  description = "HTTP API endpoint URL"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}