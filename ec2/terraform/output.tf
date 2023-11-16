output "ec2_public_ip" {
  value = aws_eip.lb
  description = "LB public IP"
}
