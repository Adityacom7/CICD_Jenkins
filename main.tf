provider "aws" {
  region = "us-east-1"  # Adjust as necessary
}

# Security Group allowing inbound access to the required ports
resource "aws_security_group" "jenkins_sonarqube_docker_sg" {
  name        = "jenkins_sonarqube_docker_sg"
  description = "Allow ports 8080, 9000, 8087 inbound access"

  ingress {
    description      = "Allow Jenkins HTTP (8080)"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow SonarQube HTTP (9000)"
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow Docker HTTP (8087)"
    from_port        = 8087
    to_port          = 8087
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sonarqube-docker-sg"
  }
}

# Common AMI and Instance type variables (update AMI as per region)
variable "ami" {
  description = "AMI ID for EC2 instances"
  default     = "ami-0c02fb55956c7d316" # Ubuntu Server 22.04 LTS (us-east-1)
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

# Launch 3 Jenkins instances with port 8080
resource "aws_instance" "jenkins" {
  count         = 3
  ami           = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.jenkins_sonarqube_docker_sg.name]

  tags = {
    Name = "jenkins-${count.index + 1}"
  }
}

# Launch 1 SonarQube instance with port 9000
resource "aws_instance" "sonarqube" {
  ami           = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.jenkins_sonarqube_docker_sg.name]

  tags = {
    Name = "sonarqube"
  }
}

# Launch 1 Docker instance with port 8087
resource "aws_instance" "docker" {
  ami           = var.ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.jenkins_sonarqube_docker_sg.name]

  tags = {
    Name = "docker"
  }
}
