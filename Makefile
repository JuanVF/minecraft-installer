create_tfvars:
	@file_path="./$(NAME)-variables.tfvars"; \
	touch $$file_path; \
	echo "" > $$file_path; \
	echo "minecraft_version_url = \"$(URL)\"" >> $$file_path; \
	echo "aws_region            = \"us-east-1\"" >> $$file_path; \
	echo "aws_access_key        = \"${AWS_ACCESS_KEY}\"" >> $$file_path; \
	echo "aws_secret_key        = \"${AWS_SECRET_KEY}\"" >> $$file_path; \
	echo "aws_host_ami_id       = \"ami-0eb01a520e67f7f20\"" >> $$file_path; \
	echo "aws_host_type         = \"t4g.small\"" >> $$file_path; \
	echo "pem_file              = \"minecraft.pem\"" >> $$file_path; \
	echo "minecraft_server_name = \"$(NAME)\"" >> $$file_path;