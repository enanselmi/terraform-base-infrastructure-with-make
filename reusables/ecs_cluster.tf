module "ecs_cluster" {
  source = "./modules/tf-aws-ecs-cluster"

  vpc_id = module.vpc.vpc_id

  ecs_cluster_name = var.ecs_cluster["name"]

  cloud_init_template_prefix = "ecs"

  launch_config_key_name      = var.env["key_name"]
  launch_config_instance_type = var.ecs_cluster["launch_config_instance_type"]
  launch_config_image_id      = module.amazon_linux_ami.ami_id

  asg_ec2_subnet_ids   = module.vpc.private_subnet_ids
  asg_min_size         = var.ecs_cluster["asg_min_size"]
  asg_max_size         = var.ecs_cluster["asg_max_size"]
  asg_desired_capacity = var.ecs_cluster["asg_desired_capacity"]
  asg_tag_names        = var.asg_tag_names

  tags = module.ecs_cluster_label.tags
}
