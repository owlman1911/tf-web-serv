resource "aws_instance" "webserv" {
    ami         = "ami-0323c3dd2da7fb37d"
    instance_type = "t2.micro"

    tags = {
        Name = "web-app",
        Environment = "test"
    }

    user_data = <<- EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF

 
}