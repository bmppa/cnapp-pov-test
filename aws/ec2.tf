# Creates a PEM (and OpenSSH) formatted private key
resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Provides an EC2 key pair resource
resource "aws_key_pair" "generated_key" {
  key_name   = "myKey-${random_string.random.result}"
  public_key = tls_private_key.private-key.public_key_openssh
}

# Creates a generic Ubuntu server
resource "aws_instance" "server" {
  for_each                    = var.public_instances
  ami                         = each.value[1]
  instance_type               = each.value[0]
  subnet_id                   = aws_subnet.pub_net_1.id
  vpc_security_group_ids      = [aws_security_group.internet_sg.id]
  key_name                    = aws_key_pair.generated_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.mongodb-profile.name
  associate_public_ip_address = true
  monitoring                  = true
  ebs_optimized               = true
  private_ip                  = "10.0.0.28"
  user_data                   = templatefile("script.sh", { s3_bucket = "${aws_s3_bucket.db-bkp.bucket}" })

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 40
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${each.key}-${random_string.random.result}"
  }

  lifecycle {
    ignore_changes = [ami, user_data]
  }
}
