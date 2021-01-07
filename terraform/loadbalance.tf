# Simple Load Balancer
resource "aws_elb"  "elb_frontend" {
  name               = "frontend"

  subnets            = [aws_subnet.subnet_public_a.id, aws_subnet.subnet_public_b.id]
  security_groups    = [aws_security_group.sg_public.id]
  listener {
    instance_port      = 8080
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl_cert
  }
    
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/"
    interval            = 30
  }

  instances                   = [aws_instance.skytest.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400


  tags = {
    Name = "frontend-lb"
  }
}

