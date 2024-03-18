resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist([aws_subnet.app_db_subnet.id])
  private_dns_enabled = true
#   security_group_ids  = [aws_security_group.ssm_endpoint.id]
}

# resource "aws_security_group" "ssm_endpoint" {
#   name        = "ssm-endpoint-sg"
#   vpc_id      = aws_vpc.main.id
#   description = "Allow HTTPS for SSM Endpoint"

#   ingress {
#     from_port       = 443
#     to_port         = 443
#     protocol        = "tcp"
#     cidr_blocks     = ["0.0.0.0/0"]
#   }
# }