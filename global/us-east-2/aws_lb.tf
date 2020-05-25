resource "aws_lb" "web-lb" {
    name                = "app-lb-web"
    load_balancer_type  = "application"
    subnets             = data.aws_subnet_ids.df-sub.ids
    security_groups     = [aws_security_group.sg-weblb.id]
}

resource "aws_lb_listener" "http" { 
    load_balancer_arn = aws_lb.web-lb.arn
    port                = 80
    protocol            = "HTTP"

    #by default, return a simple 404 page
    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "404: page not found"
            status_code  = 404
        }
    }
  
}

resource "aws_security_group" "sg-weblb" { 
    name = "app_lb_sg"

    #Allow HTTP inbound request
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    #Allow All outbound request
    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}

resource "aws_lb_target_group" "tar-grp-asg" {
    name            = "lb-tar-asg"
    port            = var.web-srv-prt
    protocol        = "HTTP"
    vpc_id          = data.aws_vpc.df-vpc.id


    health_check {
        path            = "/"
        protocol        = "HTTP"
        matcher         = "200"
        interval        = 15
        timeout         = 3
        healthy_threshold = 2
        unhealthy_threshold = 2

    } 
  
}

resource "aws_lb_listener_rule" "lb_lst_rule" { 
    listener_arn = aws_lb_listener.http.arn
    priority        = 100

    condition {
        field = "path-pattern"
        values = ["*"]
    }

    action {
        type                    = "forward"
        target_group_arn        = aws_lb_target_group.tar-grp-asg.arn
    }
  
}

output "alb_dns_name" {
    value                       = aws_lb.web-lb.dns_name
    description                 = "The domain name of the load balancer"
}