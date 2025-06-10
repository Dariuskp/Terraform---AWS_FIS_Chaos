Terraform AWS FIS EC2 Shutdown Chaos Experiment
This repository contains Terraform configurations to deploy an AWS Fault Injection Service (FIS) experiment template designed to simulate an EC2 instance shutdown. This is a foundational step for practicing chaos engineering principles and testing the resilience of your applications to unexpected EC2 instance failures.

⚠️ Important Warning ⚠️
This project creates AWS Fault Injection Service (FIS) resources that perform real actions on your AWS infrastructure. Running an FIS experiment can terminate or stop EC2 instances, introduce network latency, or other disruptive actions.

DO NOT run this in a production environment without fully understanding its impact and having robust recovery mechanisms in place.

ALWAYS test in a non-production or isolated environment first.

Ensure your IAM permissions are scoped appropriately to prevent unintended broad impact.

Features
Automated FIS Template Creation: Deploys an AWS FIS Experiment Template via Terraform.

IAM Role & Policy Setup: Configures the necessary IAM role and policy for FIS to execute experiments.

EC2 Instance Shutdown Action: The experiment template is configured to target and shut down a specified number of EC2 instances.

null_resource for Experiment Execution: Uses a null_resource with local-exec to trigger the FIS experiment directly after the template is created.

Bash Script for Experiment Management: Includes a helper script to initiate the experiment and fetch results.

Prerequisites
Before deploying this configuration, ensure you have the following:

AWS Account: An active AWS account.

AWS CLI Configured: The AWS Command Line Interface (CLI) should be installed and configured with appropriate credentials and a default region.

Ensure your AWS credentials have permissions to create IAM roles/policies, FIS experiment templates, and perform EC2 actions (e.g., ec2:StopInstances).

Terraform Installed: Terraform (v1.0.0 or later recommended) installed on your local machine.

Project Structure
.
├── main.tf                 # Main Terraform configuration file
├── variables.tf            # Input variables for the Terraform configuration
├── outputs.tf              # Output values from the Terraform deployment
├── start_experiment.sh     # Bash script to initiate and fetch FIS experiment results
└── README.md               # This file

Usage
Follow these steps to deploy and run the EC2 shutdown chaos experiment:

1. Clone the Repository
git clone https://github.com/Dariuskp/Terraform---AWS_FIS_Chaos.git
cd Terraform---AWS_FIS_Chaos

2. Configure Variables (Optional)
Review variables.tf and update main.tf to customize values like instance_tags if you want to target specific EC2 instances (e.g., by name, environment, or role). By default, it will look for instances with the tag fis-test: true.

# In main.tf, modify the target selection in aws_fis_experiment_template
# Example: Targeting instances with a specific tag
resource "aws_fis_experiment_template" "ec2_shutdown" {
  # ... other configuration ...

  target {
    key          = "my_instances"
    resource_type = "aws:ec2:instance"
    selection_mode = "COUNT(1)" # or "ALL"

    resource_tag {
      key   = "Environment"
      value = "dev"
    }
  }
  # ...
}

3. Initialize Terraform
terraform init

4. Review the Plan
Always review the execution plan before applying changes to understand what resources will be created, modified, or destroyed.

terraform plan

5. Apply the Configuration & Run Experiment
This command will create the IAM resources, the FIS experiment template, and then execute the start_experiment.sh script to trigger the FIS experiment.

terraform apply --auto-approve

The start_experiment.sh script will output the experiment ID, wait for a short period, and then save the experiment results to results.txt in the same directory where you run Terraform.

6. Monitor the Experiment
You can monitor the experiment's status in the AWS FIS Console:
https://console.aws.amazon.com/fis/home#/experiments

Or using the AWS CLI:

aws fis get-experiment --id <EXPERIMENT_ID_FROM_OUTPUT> --query 'experiment.state.status' --output text

7. Clean Up
To remove all resources created by this Terraform configuration and stop any running experiments (if they haven't completed), run:

terraform destroy --auto-approve

This will also clean up the dead.letter file if it was created due to previous email attempts.
