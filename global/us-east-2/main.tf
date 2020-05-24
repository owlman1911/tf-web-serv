resource "aws_instance" "webserv" {
  ami           = "ami-01d025118d8e760db"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg-web.id]

  tags = {
    Name        = "web-app",
    Environment = "test"
  }

  user_data = <<-EOF
                #!/bin/bash
                yum install httpd -y
                echo "Hello, World" > index.html
                systemctl start httpd
                nohup busybox httpd -fp 8080 &
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