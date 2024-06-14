# Minecraft Installer with Terraform

![Minecraft Banner](https://github.com/JuanVF/minecraft-installer/blob/main/images/banner.webp "Minecraft Banner")

This project automates the setup of a Minecraft Server on AWS EC2 instances using Terraform and a bash script, you can run a Minecraft server with just a `terraform apply`.

The server is configured to run on ARM-based instances, so, if you want to run this on x86 arch, you need to do some customizations to the Shell Script.

## Prerequisites

- **AWS Account**: You need an active AWS account.
- **Terraform**: Terraform must be installed on your local machine. Download it from [Terraform's official website](https://www.terraform.io/downloads.html).
- **EC2 Key Pair**: An EC2 key pair should be available for SSH access to the instance.

## Setup Instructions

### Step 1: Configure Terraform Variables

1. **Create a `terraform.tfvars` file** in the same directory as your other Terraform files. This file will be used to set input variables that should be customized based on your environment.
2. **Edit the `terraform.tfvars` file** to include necessary details such as your EC2 instance type, key pair name, and other configurations. Here’s an example of what this file might look like:
   ```hcl
    minecraft_version_url = "<URL>" # Check the URL's at the end of the docs
    aws_region            = "us-east-1"
    aws_access_key        = "<ACCESS_KEY>"
    aws_secret_key        = "<SECRET_KEY>"
    aws_host_ami_id       = "ami-0eb01a520e67f7f20"
    aws_host_type         = "t4g.small"
    pem_file              = "minecraft"
   ```
3. Save the changes to your `terraform.tfvars` file.

### Step 2: Terraform Initialization

1. **Navigate to the project directory** where the Terraform files are located.
2. **Initialize Terraform**:
   ```bash
   terraform init
   ```
   This will download the necessary plugins and prepare your directory for Terraform deployment.

### Step 3: Deploying the EC2 Instance

1. **Plan the Terraform deployment** to see the resources that will be created:
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```
2. **Apply the Terraform configuration** to start the deployment:
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```
3. Confirm the action by typing `yes` when prompted.

4. After that let EC2 run the Shell script to start the Minecraft Server and you are good to go.

## Usage

Once the Minecraft server is set up, it will start automatically. You can manage the server using the following systemd commands:

- **Start the server**:
  ```bash
  sudo systemctl start minecraft.service
  ```
- **Stop the server**:
  ```bash
  sudo systemctl stop minecraft.service
  ```
- **Enable server to start on boot**:
  ```bash
  sudo systemctl enable minecraft.service
  ```

## Customizing Your Server

Modify the `variables.tf` and `minecraft-setup.sh` to adjust configurations such as the Minecraft version and server settings.

## Minecraft Server Versions

Credits to [@cliffano](https://github.com/cliffano) URLs are taken from his contribution [here](https://gist.github.com/cliffano/77a982a7503669c3e1acb0a0cf6127e9)

| Minecraft Version | URL                                                                                           |
| ----------------- | --------------------------------------------------------------------------------------------- |
| 1.20.6            | https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar |
| 1.20.5            | https://piston-data.mojang.com/v1/objects/79493072f65e17243fd36a699c9a96b4381feb91/server.jar |
| 1.20.4            | https://piston-data.mojang.com/v1/objects/8dd1a28015f51b1803213892b50b7b4fc76e594d/server.jar |
| 1.20.3            | https://piston-data.mojang.com/v1/objects/4fb536bfd4a83d61cdbaf684b8d311e66e7d4c49/server.jar |
| 1.20.2            | https://piston-data.mojang.com/v1/objects/5b868151bd02b41319f54c8d4061b8cae84e665c/server.jar |
| 1.19.4            | https://piston-data.mojang.com/v1/objects/8f3112a1049751cc472ec13e397eade5336ca7ae/server.jar |
| 1.19.3            | https://piston-data.mojang.com/v1/objects/c9df48efed58511cdd0213c56b9013a7b5c9ac1f/server.jar |
| 1.19.2            | https://piston-data.mojang.com/v1/objects/f69c284232d7c7580bd89a5a4931c3581eae1378/server.jar |
| 1.19.1            | https://piston-data.mojang.com/v1/objects/8399e1211e95faa421c1507b322dbeae86d604df/server.jar |
| 1.18.2            | https://launcher.mojang.com/v1/objects/c8f83c5655308435b3dcf03c06d9fe8740a77469/server.jar    |
| 1.18.1            | https://launcher.mojang.com/v1/objects/125e5adf40c659fd3bce3e66e67a16bb49ecc1b9/server.jar    |
| 1.17.1            | https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar    |

## Contributing

Feel free to fork this project and submit pull requests or create issues if you find bugs or have features you’d like to suggest.

## License

This project is released under the MIT License. See the LICENSE file for details.
