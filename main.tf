# create vpc
resource "aws_vpc" "four_vpc" {
  cidr_block       = "152.40.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "four_vpc"
  }
}

#create aws_internet_gateway
resource "aws_internet_gateway" "four_igw" {
  vpc_id = aws_vpc.four_vpc.id

  tags = {
    Name = "four_igw"
  }
}

#create public_subnet
resource "aws_subnet" "four_public_subnet" {
  vpc_id     = aws_vpc.four_vpc.id
  cidr_block = "152.40.2.0/24"

  tags = {
    Name = "four_public_subnet"
  }
}

#create public_route
resource "aws_route_table" "four_public_route" {
  vpc_id = aws_vpc.four_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.four_igw.id

  }
  tags = {
    Name = "four_public_route"
  }
}

#route_table_association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.four_public_subnet.id
  route_table_id = aws_route_table.four_public_route.id
}

#create key_pair
resource "aws_key_pair" "four_key_pair" {
  key_name   = "four_key_pair"
  public_key = file("${path.module}/key_file.pub")
}

#create security_group
resource "aws_security_group" "four_security_group" {
  name        = "four_security_group"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.four_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "four_security_group"
  }
}

#create public_ec2
resource "aws_instance" "four_public_ec2" {
  ami                         = "ami-082b1f4237bd816a1"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.four_key_pair.key_name
  subnet_id                   = aws_subnet.four_public_subnet.id
  vpc_security_group_ids  = [aws_security_group.four_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "four_public_ec2"
  }
}

#create elastic_ip
resource "aws_eip" "four_eip" {
  vpc = true

  tags = {
    Name = "four_eip"
  }
}

#create nat_gateway
resource "aws_nat_gateway" "four_ngw" {
  connectivity_type = "public"
  allocation_id     = aws_eip.four_eip.id
  subnet_id         = aws_subnet.four_public_subnet.id

  tags = {
    Name = "four_ngw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.four_igw]
}

#create private_subnet
resource "aws_subnet" "four_private_subnet" {
  vpc_id     = aws_vpc.four_vpc.id
  cidr_block = "152.40.4.0/24"

  tags = {
    Name = "four_private_subnet"
  }
}

#create private_route
resource "aws_route_table" "four_private_route" {
  vpc_id = aws_vpc.four_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.four_ngw.id

  }
  tags = {
    Name = "four_private_route"
  }
}

#route_table_association
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.four_private_subnet.id
  route_table_id = aws_route_table.four_private_route.id
}

#create private_ec2
resource "aws_instance" "four_private_ec2" {
  ami                         = "ami-082b1f4237bd816a1"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.four_key_pair.key_name
  subnet_id                   = aws_subnet.four_private_subnet.id
  vpc_security_group_ids  = [aws_security_group.four_security_group.id]
  associate_public_ip_address = true

  tags = {
    Name = "four_private_ec2"
  }
}

#output
output "four_public_ec2_public_ip"{
  value = aws_instance.four_public_ec2.public_ip 
}

output "four_priavte_ec2_private_ip"{
  value = aws_instance.four_private_ec2.private_ip
}
