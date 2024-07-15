locals {
  # CIDR block suggested by AWS for Minecraft
  # This is for us-east-1
  # make sure to change it based on this guide: https://aws.amazon.com/blogs/gametech/setting-up-a-minecraft-java-server-on-amazon-ec2/
  minecraft_cidr_block = "10.0.0.0"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# ------------------------
#     VPC Configuration
# ------------------------
resource "aws_vpc" "minecraft_vpc" {
  cidr_block = "${local.minecraft_cidr_block}/16"

  tags = {
    Name = "${var.minecraft_server_name} minecraft vpc"
  }
}

resource "aws_subnet" "minecraft_subnet" {
  vpc_id            = aws_vpc.minecraft_vpc.id
  cidr_block        = "${local.minecraft_cidr_block}/24"
  availability_zone = "${var.aws_region}a"

  depends_on = [aws_vpc.minecraft_vpc]
}

resource "aws_internet_gateway" "minecraft_internet_gateway" {
  vpc_id = aws_vpc.minecraft_vpc.id

  tags = {
    Name = "${var.minecraft_server_name} minecraft internet gateway"
  }

  depends_on = [aws_vpc.minecraft_vpc]
}

resource "aws_route_table" "minecraft_route_table" {
  vpc_id = aws_vpc.minecraft_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft_internet_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.minecraft_internet_gateway.id
  }

  tags = {
    Name = "${var.minecraft_server_name} minecraft route table"
  }

  depends_on = [aws_vpc.minecraft_vpc]
}

resource "aws_route_table_association" "minecraft_route_table_association" {
  subnet_id      = aws_subnet.minecraft_subnet.id
  route_table_id = aws_route_table.minecraft_route_table.id

  depends_on = [aws_subnet.minecraft_subnet, aws_route_table.minecraft_route_table]
}

resource "aws_security_group" "minecraft_security_group" {
  name   = "${var.minecraft_server_name} minecraft ports"
  vpc_id = aws_vpc.minecraft_vpc.id

  # internet protocol
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH Protocol
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Minecraft Connections anywhere
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Minecraft Query UDP Connections anywhere
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "udp"
    cidr_blocks = [var.ip_origin_access]
  }

  # Allow Minecraft Query UDP Connections anywhere
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = [var.ip_origin_access]
  }

  # Allow Node Exporter Access from certain IP
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.ip_origin_access]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.minecraft_vpc]
}

# ------------------------------------------------
#       Minecraft EC2 Host Configuration
# ------------------------------------------------

resource "aws_instance" "minecraft_host" {
  ami           = var.aws_host_ami_id
  subnet_id     = aws_subnet.minecraft_subnet.id
  instance_type = var.aws_host_type
  key_name      = var.pem_file

  associate_public_ip_address = true

  security_groups = [aws_security_group.minecraft_security_group.id]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = true
  }

  tags = {
    Name = "${var.minecraft_server_name} minecraft host"
  }

  user_data_base64 = base64encode("${templatefile("scripts/minecraft-setup.sh", {
    version = var.minecraft_version_url
  })}")

  depends_on = [aws_subnet.minecraft_subnet, aws_security_group.minecraft_security_group]
}
