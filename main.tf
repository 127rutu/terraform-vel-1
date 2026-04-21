#creating vpc
resource "aws_vpc" "testvpc" {
  cidr_block = "10.10.0.0/16"
}
#creating subnets
resource "aws_subnet" "subneta" {
  cidr_block = "10.10.1.0/24"
  vpc_id = aws_vpc.testvpc.id
  availability_zone = "ap-south-1a"
}
resource "aws_subnet" "subnetb" {
  cidr_block = "10.10.2.0/24"
  vpc_id = aws_vpc.testvpc.id
  availability_zone = "ap-south-1b"
}
#creating IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.testvpc.id
}
#creating routetable
resource "aws_route_table" "testrt" {
  vpc_id = aws_vpc.testvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
#rt association
resource "aws_route_table_association" "a1" {
  subnet_id = aws_subnet.subneta.id
  route_table_id = aws_route_table.testrt.id
}
resource "aws_route_table_association" "a2" {
  subnet_id = aws_subnet.subnetb.id
  route_table_id = aws_route_table.testrt.id
}
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.testvpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }

}
resource "aws_instance" "webserver" {

        ami = "ami-0e12ffc2dd465f6e4"
        instance_type = "t3.micro"
        key_name = "mumbai-key"
        subnet_id = aws_subnet.subneta.id
         associate_public_ip_address = true
         vpc_security_group_ids = [aws_security_group.web_sg.id]
         user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello Rutuja" > /var/www/html/index.html
              EOF
        tags = {
                     Name = "webserver"
                     domain = "telecom"
            }
    }
