resource "aws_instance" "webserv" {
  ami           = "ami-01d025118d8e760db"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg-web.id]
  key_name      = "webtest"

  tags = {
    Name        = "web-app",
    Environment = "test"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y httpd
                sudo sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf 
                sudo usermod -a -G apache ec2-user
                sudo chown -R ec2-user:apache /var/www
                sudo chmod 2775 /var/www
                sudo find /var/www -type d -exec sudo chmod 2775 {} \;
                sudo find /var/www -type f -exec sudo chmod 0664 {} \;
                sudo echo "hello, world OK" > /var/www/html/index.html
                sudo service httpd start
                EOF
                
}

resource "aws_security_group" "sg-web" {
    name = "web01_sg"

    ingress {
        from_port = var.web-srv-prt
        to_port = var.web-srv-prt
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["71.105.226.132/32"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "security grp"
    }
}

variable "web-srv-prt" {
    description = "the HTTP port for web services"
    type = number
    default = 8080
}

output "public_ip" {
    value           = aws_instance.webserv.public_ip
    description     = "The public ip of the webserver"
}