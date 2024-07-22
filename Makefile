create_tfvars:
	@file_path="./${PROJECT_NAME}-variables.tfvars"; \
	touch $$file_path; \
	echo "" > $$file_path; \
	echo "minecraft_version_url          = \"${MINECRAFT_URL}\"" >> $$file_path; \
	echo "aws_region                     = \"us-east-1\"" >> $$file_path; \
	echo "aws_access_key                 = \"${AWS_ACCESS_KEY}\"" >> $$file_path; \
	echo "aws_secret_key                 = \"${AWS_SECRET_KEY}\"" >> $$file_path; \
	echo "aws_host_ami_id                = \"ami-0eb01a520e67f7f20\"" >> $$file_path; \
	echo "aws_host_type                  = \"${PROJECT_HOST_TYPE}\"" >> $$file_path; \
	echo "pem_file                       = \"minecraft\"" >> $$file_path; \
	echo "ip_origin_access               = \"${PROJECT_IP}\"" >> $$file_path; \
	echo "disk_space                     = \"${PROJECT_DISK_SPACE}\"" >> $$file_path; \
	echo "ftp_user                       = \"${PROJECT_FTP_USER}\"" >> $$file_path; \
	echo "ftp_password                   = \"${PROJECT_FTP_PASSWORD}\"" >> $$file_path; \
	echo "system_memory                  = \"${SYSTEM_MEMORY}\"" >> $$file_path; \
	echo "minecraft_server_name          = \"${PROJECT_NAME}\"" >> $$file_path;

clean_tfvars:
	rm ${PROJECT_NAME}-variables.tfvars