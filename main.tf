data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

############################################## VPC Creation ##############################################

resource "aws_vpc" "default" {
  cidr_block                       = "${var.cidr_block}"
  instance_tenancy                 = "${var.tenancy}"
  enable_classiclink               = false

  tags = {
    Name = "${var.name}"
  }
}
############################################## Creating Internet Gateway ##############################################

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "${var.name}"
  }
}


############################################## Creating NAT Gateway ##############################################

resource "aws_eip" "default" {
  vpc   = true
  count = "${var.enable_nat_gw ? length(split(",",var.AZs)) : 0}"
}

resource "aws_nat_gateway" "default" {
  allocation_id = "${element(aws_eip.default.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  count         = "${var.enable_nat_gw ? length(split(",",var.AZs)) : 0}"
  depends_on = ["aws_internet_gateway.default"]
}


############################################## Subnets Creation ##############################################

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.default.cidr_block, 8, 30 + count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(sort(data.aws_availability_zones.available.names), count.index)}"
  count                   = "${length(split(",",var.AZs))}"

  tags = {
    Name = "${var.name}-public-${substr(element(sort(data.aws_availability_zones.available.names), count.index),-1,1)}"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.default.cidr_block, 8, 40 + count.index)}"
  map_public_ip_on_launch = false
  availability_zone       = "${element(sort(data.aws_availability_zones.available.names), count.index)}"
  count                   = "${ length(split(",",var.AZs))}"

  tags = {
    Name = "${var.name}-private-${substr(element(sort(data.aws_availability_zones.available.names), count.index),-1,1)}"
  }
}

############################################## Creating Routes Table ##############################################

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.default.id}"
  count  = "${ length(split(",",var.AZs)) }"
  
  tags = {
    Name = "${var.name}-public-${substr(element(data.aws_availability_zones.available.names, count.index),-1,1)}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.default.id}"
  count  = "${ length(split(",",var.AZs)) }"
  
  tags = {
    Name = "${var.name}-private-${substr(element(data.aws_availability_zones.available.names, count.index),-1,1)}"
  }
}


############################################## Creating Routes ##############################################

resource "aws_route_table_association" "public" {
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
  count          = "${ length(split(",",var.AZs))}"
}

resource "aws_route_table_association" "private" {
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  count          = "${ length(split(",",var.AZs))}"
}

resource "aws_route" "public" {
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
  count                  = "${length(split(",",var.AZs))}"
}

resource "aws_route" "private" {
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.default.*.id, count.index)}"
  count                  = "${(var.enable_nat_gw ? length(split(",",var.AZs)) : 0)}"
}

############################################## Network ACL Creation ##############################################

resource "aws_network_acl" "public" {
  vpc_id     = "${aws_vpc.default.id}"
  subnet_ids = aws_subnet.public.*.id

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_network_acl_rule" "public_ingress" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0

}

resource "aws_network_acl_rule" "public_egress" {
  network_acl_id = "${aws_network_acl.public.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0

}

resource "aws_network_acl" "private" {
  vpc_id     = "${aws_vpc.default.id}"
  subnet_ids = aws_subnet.private.*.id
  tags = {
    Name = "${var.name}-private"
  }
}

resource "aws_network_acl_rule" "private_ingress" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0

}

resource "aws_network_acl_rule" "private_egress" {
  network_acl_id = "${aws_network_acl.private.id}"
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0

}


############################################## Private Security Group ##############################################

resource "aws_security_group" "private_sg" {
  vpc_id = "${aws_vpc.default.id}"
  tags = {
    Name = "${var.name}-private_sg"
  }
}

resource "aws_security_group_rule" "egress" {
  description       = "Allow all egress traffic to other subnet"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.private_sg.id}"
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_ssh" {
  description       = "Allow all ingress SSH traffic from other subnet"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.private_sg.id}"
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_https" {
  description       = "Allow all ingress HTTPS traffic other subnet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.private_sg.id}"
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_http" {
  description       = "Allow all ingress HTTP traffic other subnet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.private_sg.id}"
  type              = "ingress"
}

############################################## Public Security Group ##############################################

resource "aws_security_group" "public_sg" {
  vpc_id = "${aws_vpc.default.id}"
  tags = {
    Name = "${var.name}-public_sg"
  }
}

resource "aws_security_group_rule" "egress_public_sg" {
  description       = "Allow all egress traffic to Internet"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.public_sg.id}"
  type              = "egress"
}

resource "aws_security_group_rule" "ingress_ssh_public_sg" {
  description       = "Allow all ingress SSH traffic from Internet"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.public_sg.id}"
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_https_public_sg" {
  description       = "Allow all ingress HTTPS traffic from Internet"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.public_sg.id}"
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_http_public_sg" {
  description       = "Allow all ingress HTTP traffic from Internet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.public_sg.id}"
  type              = "ingress"
}


############################################## K8s Cluster Creation ##############################################

module "cluster" {
  source = "./modules/cluster"

  name                    = "${var.name}"
  eks_version             = "${var.eks_version}"
  vpc_id                  = "${aws_vpc.default.id}"
  subnet_ids              = flatten(["${aws_subnet.private.*.id}","${aws_subnet.public.*.id}",])
  cidr_block              = ["${var.cidr_block}"]
  ssh_cidr                = "${var.ssh_cidr}"
  enable_kubectl          = "${var.enable_kubectl}"
  enable_dashboard        = "${var.enable_dashboard}"
}


############################################# K8s Nodes Creation ##############################################

module "nodes" {
  source = "./modules/nodes"

  name                = "${var.name}"
  cluster_name        = "${module.cluster.name}"
  cluster_endpoint    = "${module.cluster.endpoint}"
  cluster_certificate = "${module.cluster.certificate}"
  security_groups     = ["${module.cluster.node_security_group}"]
  instance_profile    = "${module.cluster.node_instance_profile}"
  subnet_ids          = "${aws_subnet.private.*.id}"
  ami_id              = "${var.node_ami_id}"
  ami_lookup          = "${var.node_ami_lookup}"
  instance_type       = "${var.node_instance_type}"
  user_data           = "${var.eks_node_user_data}"
  bootstrap_arguments = "${var.eks_node_bootstrap_arguments}"
  min_size            = "${var.eks_node_min_size}"
  max_size            = "${var.eks_node_max_size}"
  key_pair            = "${var.key_pair}"
}