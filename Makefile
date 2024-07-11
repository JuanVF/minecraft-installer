create_tfvars:
	@file_path="./$(NAME)-variables.tfvars"; \
	touch $$file_path; \
	echo "" > $$file_path; \
	echo "minecraft_version_url          = \"$(URL)\"" >> $$file_path; \
	echo "aws_region                     = \"us-east-1\"" >> $$file_path; \
	echo "aws_access_key                 = \"${AWS_ACCESS_KEY}\"" >> $$file_path; \
	echo "aws_secret_key                 = \"${AWS_SECRET_KEY}\"" >> $$file_path; \
	echo "aws_host_ami_id                = \"ami-0eb01a520e67f7f20\"" >> $$file_path; \
	echo "aws_host_type                  = \"$(HOST_TYPE)\"" >> $$file_path; \
	echo "pem_file                       = \"minecraft\"" >> $$file_path; \
	echo "node_exporter_ip_origin_access = \"$(NODE_IP)\"" >> $$file_path; \
	echo "minecraft_server_name          = \"$(NAME)\"" >> $$file_path;

clean_tfvars:
	rm $(NAME)-variables.tfvars