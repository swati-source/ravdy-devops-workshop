provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "demo_sg" {
  name        = "demo_sg"
  description = "SSH Access"

  ingress {
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
}

resource "aws_instance" "demo-server" {
  ami           = "ami-08a0d1e16fc3f61ea"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  key_name = "terraform"
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  tags = {
    Name = "demo-server"
  }
}


