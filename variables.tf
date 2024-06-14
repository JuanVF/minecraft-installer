variable "minecraft_version_url" {
  description = "Enter the Minecraft Version URL to be used. Check the docs to see the URLs"
  # this is 1.21
  default = "https://piston-data.mojang.com/v1/objects/450698d1863ab5180c25d7c804ef0fe6369dd1ba/server.jar"
}

variable "aws_host_ami_id" {
  description = "The Minecraft AMIs to use for the host"
  # Default is Amazon Linux 2023 AMI for ARM
  default = "ami-0eb01a520e67f7f20"
}

variable "aws_host_type" {
  description = "The Minecraft host Type to use"
  # Default is t4g.small which should be enough
  default = "t4g.small"
}

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

# Please create a tfvar with this value
variable "aws_access_key" {
  description = "AWS Access Key"
  # default     = "XXXXXXXXXXXXXXXXXXX"
}

# Please create a tfvar with this value
variable "aws_secret_key" {
  description = "AWS Secret Key"
  # default     = "XXXXXXXXXXXXXXXXXXX"
}

# Please create a tfvar with this value
variable "pem_file" {
  description = "The PEM file to be able to access"
  #default     = "file_name_without_pem_extension"
}
