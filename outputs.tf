output "instance_id" {
  description = "ID of the EC2 instance used in the chaos experiment"
  value       = aws_instance.chaovate_chaos_instance.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.chaovate_chaos_instance.public_ip
}

output "fis_template_id" {
  description = "AWS FIS Experiment Template ID"
  value       = aws_fis_experiment_template.ec2_shutdown.id
}
