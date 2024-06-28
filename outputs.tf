output "minecraft_server_ip" {
  value = aws_instance.minecraft_host.public_ip
}

resource "local_file" "minecraft_server_ip_file" {
  filename = "${var.minecraft_server_name}-ip-address.log"
  content  = aws_instance.minecraft_host.public_ip
}
