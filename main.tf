terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.route_cidr
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allow_ssh" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_tag
  }
}

resource "aws_instance" "chaovate_chaos_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  key_name               = var.key_name

  tags = {
    Name = var.instance_name
  }
}

resource "aws_key_pair" "chaovate_chaos_key" {
  key_name   = var.key_name
  public_key = file("~/.ssh/chaovate-chaos-key.pub")
}

resource "aws_iam_role" "fis_role" {
  name = var.fis_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "fis.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "fis_policy" {
  name = var.fis_policy_name
  role = aws_iam_role.fis_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "instance_down" {
  alarm_name          = var.cw_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = var.cw_alarm_description
  actions_enabled     = false

  dimensions = {
    InstanceId = aws_instance.chaovate_chaos_instance.id
  }
}

resource "aws_fis_experiment_template" "ec2_shutdown" {
  description = var.fis_experiment_description
  role_arn    = aws_iam_role.fis_role.arn

  stop_condition {
    source = "none"
  }

  action {
    name      = var.fis_action_name
    action_id = "aws:ec2:terminate-instances"

    target {
      key   = "Instances"
      value = var.fis_target_name
    }
  }
  target {
    name           = var.fis_target_name
    resource_type  = "aws:ec2:instance"
    selection_mode = "ALL"
    resource_arns  = [aws_instance.chaovate_chaos_instance.arn]
  }
}

resource "null_resource" "start_experiment" {
  provisioner "local-exec" {
    # Pass the experiment template ID as the first argument to the script
    command = "bash start_experiment.sh ${aws_fis_experiment_template.ec2_shutdown.id}"
  }

  depends_on = [aws_fis_experiment_template.ec2_shutdown]
}
