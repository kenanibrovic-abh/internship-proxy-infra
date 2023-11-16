resource "aws_security_group" "nginx_security_group" {
  name        = "nginx_security_group"
  description = "Security group for Nginx EC2 instance"
  vpc_id      = aws_vpc.nginx.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = 6 # TCP
    cidr_blocks = [var.user_source_ip]
    description = "Allow SSH ingress"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = 6
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP ingress"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = 6
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS ingress"
  }

  ingress {
    from_port   = 6433
    to_port     = 6433
    protocol    = 6
    cidr_blocks = [var.user_source_ip] # TMP if needed
    description = "Allow k3s traffic"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = 6
    cidr_blocks = [var.user_source_ip] # TMP if needed
    description = "Allow postgres traffic"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
    description = "Allow traffic in security group"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = 6
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP egress"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = 6
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS egress"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = true
    description = "Allow traffic in security group"
  }
}
