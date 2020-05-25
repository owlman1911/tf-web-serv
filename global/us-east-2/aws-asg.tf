resource "aws_launch_configuration" "lconf_web" {
    image_id    =   "ami-01d025118d8e760db"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.sg-web.id]

    user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y httpd busybox 
                sudo sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf 
                sudo usermod -a -G apache ec2-user
                sudo chown -R ec2-user:apache /var/www
                sudo chmod 2775 /var/www
                sudo find /var/www -type d -exec sudo chmod 2775 {} \;
                sudo find /var/www -type f -exec sudo chmod 0664 {} \;
                sudo echo "hello, world OK" > /var/www/html/index.html
                sudo service httpd start
                EOF
    
    lifecycle {
        create_before_destroy   = true
    }
        
}

resource "aws_autoscaling_group" "asg-web" {
    launch_configuration = aws_launch_configuration.lconf_web.name
    vpc_zone_identifier  = data.aws_subnet_ids.df-sub.ids

    target_group_arns   = [aws_lb_target_group.tar-grp-asg.arn]
    health_check_type   = "ELB"

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
