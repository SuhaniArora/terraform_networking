provider "aws" {
  profile = "Admin"
  region  = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
}


resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = "${aws_vpc.main.id}"
}


resource "aws_subnet" "public_subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "192.168.1.0/24"
  
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_route_table" "route_table" {
    vpc_id = "${aws_vpc.main.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.internet_gateway.id}"
    }

    tags = {
        Name = "ig_route_table"
    }
}

resource "aws_route_table_association" "route_table_associate" {
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id = "${aws_route_table.route_table.id}"
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "192.168.2.0/24"

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_eip" "eip" {
  vpc              = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"

  tags = {
    Name = "gw NAT"
  }
  depends_on = ["aws_internet_gateway.internet_gateway"]
}


resource "aws_route_table" "route_table_2" {
    vpc_id = "${aws_vpc.main.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat.id}"
    }

    tags = {
        Name = "nat_route_table"
    }
}

resource "aws_route_table_association" "route_table_2_associate" {
    subnet_id = "${aws_subnet.private_subnet.id}"
    route_table_id = "${aws_route_table.route_table_2.id}"
}

variable "key_name" { default = "key2" }

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  depends_on = [
    tls_private_key.example
  ]
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress_sg"
  description = "Allow TLS inbound traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    description = "IMCP"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wordpress_sg"
  }
}

resource "aws_security_group" "bastion_host_sg" {
  name        = "bastion_host_sg"
  description = "Allow TLS inbound traffic"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_host_sg"
  }
}

resource "aws_security_group" "MySQL_sg" {
  name        = "MySQL_sg"
  description = "Allow TLS inbound traffic"
  vpc_id = "${aws_vpc.main.id}"
  
  tags = {
    Name = "wordpress_sg"
  }
}

resource "aws_security_group_rule" "mysql_sg_rule_in_1" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = "${aws_security_group.MySQL_sg.id}"
  source_security_group_id = "${aws_security_group.wordpress_sg.id}"
}

resource "aws_security_group_rule" "mysql_sg_rule_in_2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.MySQL_sg.id}"
  source_security_group_id = "${aws_security_group.wordpress_sg.id}"
}

resource "aws_security_group_rule" "mysql_sg_rule_eg" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.MySQL_sg.id}"
}

resource "aws_security_group" "MySQL_sg_2" {
  name        = "MySQL_sg_bastion"
  description = "Allow TLS inbound traffic"
  vpc_id = "${aws_vpc.main.id}"
  
  tags = {
    Name = "wordpress_sg"
  }
}

resource "aws_security_group_rule" "bastion_rule_in_1" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = "${aws_security_group.MySQL_sg_2.id}"
  source_security_group_id = "${aws_security_group.bastion_host_sg.id}"
}

resource "aws_security_group_rule" "bastion_rule_in_2" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.MySQL_sg_2.id}"
  source_security_group_id = "${aws_security_group.bastion_host_sg.id}"
}

resource "aws_security_group_rule" "mysql_sg_rule_eg_2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.MySQL_sg_2.id}"
}

/*data "aws_ami" "sql" {
  executable_users = ["self"]
  most_recent      = true
  owners           = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["WordPress Certified by Bitnami and Automattic"]
  }
}*/

resource "aws_instance" "mysql_instance" {
  ami             = "ami-0428a02584750600f"
  instance_type   = "t2.micro"
  key_name        = "mykey2"
  vpc_security_group_ids = [ "${aws_security_group.MySQL_sg.id}", "${aws_security_group.MySQL_sg_2.id}" ]
  subnet_id = "${aws_subnet.private_subnet.id}"
  
  tags = {
    Name = "mysql_instance"
  }
}

/*data "aws_ami" "wrdprss" {
  executable_users = ["self"]
  most_recent      = true
  owners           = ["aws-marketplace"]

  filter {
    name   = "name"
    values = ["WordPress Certified by Bitnami and Automattic"]
  }
}*/

resource "aws_instance" "wordpress_instance" {
  ami             = "ami-004a955bfb611bf13"
  instance_type   = "t2.micro"
  key_name        = "mykey"
  vpc_security_group_ids = [ "${aws_security_group.wordpress_sg.id}" ]
  subnet_id = "${aws_subnet.public_subnet.id}"
  
  tags = {
    Name = "wordpress_instance"
  }
}

resource "aws_instance" "bastion_host_instance" {
  ami             = "ami-004a955bfb611bf13"
  instance_type   = "t2.micro"
  key_name        = "mykey"
  vpc_security_group_ids = [ "${aws_security_group.bastion_host_sg.id}" ]
  subnet_id = "${aws_subnet.public_subnet.id}"
  
  tags = {
    Name = "bastion_host_instance"
  }
}



output "public_subnet" {
  value = "${aws_subnet.public_subnet}"
}

output "private_subnet" {
  value = "${aws_subnet.private_subnet}"
}

output "m_inst" {
  value = "${aws_instance.mysql_instance}"
}

output "w_inst" {
  value = "${aws_instance.wordpress_instance}"
}


