resource "aws_vpc" "nginx" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "nginx" {
  vpc_id            = aws_vpc.nginx.id
  cidr_block        = var.public_subnet
  availability_zone = "${var.aws_region}${var.availability_zone_suffix}"
}

resource "aws_internet_gateway" "nginx_gw" {
  vpc_id = aws_vpc.nginx.id

  depends_on = [ aws_vpc.nginx ]
}

resource "aws_eip" "lb" {
  instance = aws_instance.nginx.id
  domain   = "vpc"

  depends_on = [ aws_internet_gateway.nginx_gw ]
}

resource "aws_route_table" "nginx_route_table" {
  vpc_id = aws_vpc.nginx.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nginx_gw.id
  }
}

resource "aws_route_table_association" "nginx" {
  subnet_id      = aws_subnet.nginx.id
  route_table_id = aws_route_table.nginx_route_table.id
}
