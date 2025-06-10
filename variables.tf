# AWS Region
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The AWS region to deploy resources in."
}

# VPC Configuration
variable "vpc_name" {
  type        = string
  default     = "chaovate-chaos-vpc"
  description = "Name tag for the VPC."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC."
}

variable "subnet_name" {
  type        = string
  default     = "chaovate-chaos-subnet"
  description = "Name tag for the subnet."
}

variable "subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for the subnet."
}

variable "route_cidr" {
  type        = string
  default     = "0.0.0.0/0"
  description = "CIDR block for the default route."
}

variable "route_table_name" {
  type        = string
  default     = "chaovate-chaos-rt"
  description = "Name tag for the route table."
}

variable "igw_name" {
  type        = string
  default     = "chaovate-chaos-igw"
  description = "Name tag for the Internet Gateway."
}

# EC2 Configuration
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type."
}

variable "ami_id" {
  type        = string
  default     = "ami-0e449927258d45bc4"
  description = "AMI ID for the EC2 instance (Amazon Linux 2 in us-east-1)."
}

variable "key_name" {
  type        = string
  default     = "chaovate-chaos-key"
  description = "Name of the EC2 key pair for SSH access."
}

variable "instance_name" {
  type        = string
  default     = "chaovate-chaos-instance"
  description = "Name tag for the EC2 instance."
}

# Security Group
variable "sg_name" {
  type        = string
  default     = "chaovate-chaos-sg"
  description = "Name of the security group."
}

variable "sg_description" {
  type        = string
  default     = "Security group for SSH access"
  description = "Description of the security group."
}

variable "sg_tag" {
  type        = string
  default     = "chaovate-chaos-sg-tag"
  description = "Tag value for the security group."
}

variable "ssh_port" {
  type        = number
  default     = 22
  description = "Port number for SSH access."
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of allowed CIDR blocks for SSH ingress."
}

# IAM Role for FIS
variable "fis_role_name" {
  type        = string
  default     = "chaovate-chaos-fis-role"
  description = "Name of the IAM role for AWS FIS."
}

variable "fis_policy_name" {
  type        = string
  default     = "chaovate-chaos-fis-policy"
  description = "Name of the IAM policy for AWS FIS."
}

# CloudWatch Alarm
variable "cw_alarm_name" {
  type        = string
  default     = "chaovate-chaos-ec2-alarm"
  description = "Chaos Experiment - EC2"
}

variable "cw_alarm_description" {
  type        = string
  default     = "Triggers when EC2 instance is unavailable"
  description = "Description of the CloudWatch alarm."
}

# FIS Experiment
variable "fis_experiment_description" {
  type        = string
  default     = "Simulates EC2 failure"
  description = "Description of the FIS experiment template."
}

variable "fis_target_name" {
  type        = string
  default     = "chaovate-chaos-target"
  description = "Name of the target resource in the FIS experiment."
}

variable "fis_action_name" {
  type        = string
  default     = "terminate-chaos-instance"
  description = "Name of the action in the FIS experiment."
}

variable "fis_template_tag" {
  type        = string
  default     = "chaos-fis-template"
  description = "Tag value for the FIS experiment template."
}
