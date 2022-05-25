# Como crear una instancia EC2 individual 
# resource "aws_instance" "webserver" {
#   ami                    = "ami-00dfe2c7ce89a450b"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.webserver.id]
#   user_data = "${file("user-data-apache.sh")}"
#   tags = {
#     Name = "onboarding-eanselmi-E"
#     Owner = "CloudEng/eanselmi"
#   }
# }


# resource "aws_launch_configuration" "webserver" {
#   image_id                   = "ami-08e4e35cccc6189f4"
#   instance_type          = "t2.micro"
#   security_groups = [aws_security_group.webserver.id]
#   user_data = "${file("user-data-apache.sh")}"
#   key_name = aws_key_pair.ssh.id
#   lifecycle {
#     create_before_destroy = true
#   }
# }
  
# resource "aws_autoscaling_group" "webserver" {
#   launch_configuration = aws_launch_configuration.webserver.id
#   //availability_zones   = data.aws_availability_zones.all.names
#   vpc_zone_identifier = [aws_subnet.cnb-subnet-private-1.id]

#   min_size = 2
#   max_size = 4

#   load_balancers    = [aws_elb.webserver.name]
#   health_check_type = "ELB"

#   tag {
#     key                 = "Name"
#     value               = "terraform-asg-example"
#     propagate_at_launch = true
#   }
# }

# resource "aws_elb" "webserver" {
#   name               = "terraform-elb-example"
#   security_groups    = [aws_security_group.elb-http.id,aws_security_group.elb-ssh.id]
#   //availability_zones = data.aws_availability_zones.all.names
#    subnets   = [aws_subnet.cnb-subnet-private-1.id]

#   health_check {
#     target              = "HTTP:${var.server_port}/"
#     interval            = 30
#     timeout             = 3
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
#   listener {
#     lb_port           = var.server_port
#     lb_protocol       = "http"
#     instance_port     = var.server_port
#     instance_protocol = "http"
#   }
  
# }

# resource "aws_security_group" "elb-http" {
#   vpc_id = "${aws_vpc.cnb-vpc.id}"
#   name = "ELB-HTTP"
#   # Allow all outbound
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # Inbound HTTP from anywhere
#   ingress {
#     from_port   = var.server_port
#     to_port     = var.server_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "elb-ssh" {
#   vpc_id = "${aws_vpc.cnb-vpc.id}"
#   name = "ELB-SSH"
#   # Allow all outbound
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # Inbound HTTP from anywhere
#   ingress {
#     from_port   = var.ssh_port
#     to_port     = var.ssh_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# resource "aws_security_group" "webserver" {
#   vpc_id = "${aws_vpc.cnb-vpc.id}"
#   name = "HTTP"
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = var.server_port
#     to_port     = var.server_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = var.ssh_port
#     to_port     = var.ssh_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


  
