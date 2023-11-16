resource "aws_key_pair" "nginx" {
  key_name   = "nginx-access-key"
  public_key = var.ssh_pubkey
}