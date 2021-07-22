resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.ecs_key_name
  public_key = tls_private_key.key.public_key_openssh
}

resource "aws_secretsmanager_secret" "secret_key" {
  name                    =  var.ecs_key_name
  description             = "EC2 instance key pair"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secret_key_value" {
  secret_id     = aws_secretsmanager_secret.secret_key.id
  secret_string = tls_private_key.key.private_key_pem
}
