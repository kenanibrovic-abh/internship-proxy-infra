variable "aws_region" {
  type        = string
  description = "AWS Region"
  default = "eu-central-1"
}

variable "availability_zone_suffix" {
  type        = string
  description = "Availability zone suffix"
  default = "a"
}

variable "instance_type" {
  type = string
  description = "EC2 instance type"
  default = "t3.micro"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block"
}

variable "private_subnet" {
  type        = string
  description = "Private subnet"
}

variable "public_subnet" {
  type        = string
  description = "Public subnet"
}

variable "user_source_ip" {
  type        = string
  description = "User's source IP used for security group whitelist"
}

variable "ssh_pubkey" {
  type        = string
  description = "SSH public key used to access EC2 instances"
}
