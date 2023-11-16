data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "nginx" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = aws_key_pair.nginx.key_name
  subnet_id = aws_subnet.nginx.id
  vpc_security_group_ids = [ aws_security_group.nginx_security_group.id ]
  user_data_base64 = filebase64("./scripts/cloud_init.yaml")
  user_data_replace_on_change = true

  tags = {
    Name = "Nginx"
  }
}
