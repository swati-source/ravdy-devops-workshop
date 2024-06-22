provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "dpp_vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
}

resource "aws_subnet" "dpp_public_subnet_01" {
  vpc_id                  = aws_vpc.dpp_vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "dpp-public-subnet-01"
  }
}

resource "aws_subnet" "dpp_public_subnet_02" {
  vpc_id                  = aws_vpc.dpp_vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "dpp-public-subnet-02"
  }
}

resource "aws_internet_gateway" "dpp_igw" {
  vpc_id = aws_vpc.dpp_vpc.id 
  tags = {
    Name = "dpp-igw"
  } 
}

resource "aws_route_table" "dpp_public_rt" {
  vpc_id = aws_vpc.dpp_vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp_igw.id 
  }
}

resource "aws_route_table_association" "dpp_rta_public_subnet_01" {
  subnet_id      = aws_subnet.dpp_public_subnet_01.id
  route_table_id = aws_route_table.dpp_public_rt.id   
}

resource "aws_route_table_association" "dpp_rta_public_subnet_02" {
  subnet_id      = aws_subnet.dpp_public_subnet_02.id 
  route_table_id = aws_route_table.dpp_public_rt.id   
}

resource "aws_security_group" "demo_sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id      = aws_vpc.dpp_vpc.id 
  
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-prot"
  }
}

resource "aws_instance" "demo_server" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  key_name               = "dpp"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  subnet_id              = aws_subnet.dpp_public_subnet_01.id 
  for_each = toset(["jenkins-master", "build-slave", "ansible"])
   tags = {
     Name = "${each.key}"
   }
}
