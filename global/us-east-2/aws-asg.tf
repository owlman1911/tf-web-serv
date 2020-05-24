resource "aws_launch_configuration" "lconf_web" {
    image_id    =   "ami-01d025118d8e760db"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.sg-web.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.web-srv-prt} &
                EOF
    
    lifecycle {
        create_before_destroy   = true
    }
        
}

resource "aws_autoscaling_group" "asg-web" {
    launch_configuration = aws_launch_configuration.lconf_web.name
    vpc_zone_identifier  = data.aws_subnet_ids.df-sub.ids

    min_size = 2
    max_size = 4

    tag {
        key     = "Name"
        value   = "tf-asg-web"
        propagate_at_launch = true
    }
}

data "aws_vpc" "df-vpc" {
    default = true
}

data "aws_subnet_ids" "df-sub" {
    vpc_id = data.aws_vpc.df-vpc.id
}
