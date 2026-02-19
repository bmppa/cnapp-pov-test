#
# Create security group
#

# Retrieves the public IP address you're using
data "external" "current_ip" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

resource "aws_security_group" "internet_sg" {
  name        = "my-tasky-app-nsg-${random_string.random.result}"
  description = "Allow MongoDB Access, SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #cidr_blocks = ["${data.external.current_ip.result.ip}/32"]
  }

  ingress {
    description = "MongoDB Access"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    #cidr_blocks = ["${data.external.current_ip.result.ip}/32"]
    cidr_blocks = [var.priv_net_1_cidr, var.priv_net_2_cidr]
  }

  egress {
    description = "Egress Traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
