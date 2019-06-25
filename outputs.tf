output "AZs"                          { 
    value = "${var.AZs}"                                              
    description = "azs used in the VPC" 
    }
output "vpc_id"                       { 
    value = "${aws_vpc.default.id}"                                       
    description = "vpc id" 
    }
output "vpc_name"                     { 
    value = "${var.name}"                                            
    description = "vpc name" 
    }
output "nat_ids"                      { 
    value = "${join(",", aws_nat_gateway.default.*.id) }"                 
    description = "nat gw ids" 
    }
output "nat_private_ips"              { 
    value = "${join(",", aws_nat_gateway.default.*.private_ip) }"         
    description = "nat gw private ip" 
    }
output "nat_public_ips"               { 
    value = "${join(",", aws_nat_gateway.default.*.public_ip) }"          
    description = "nat gw public ip" 
    }
output "subnets_private_ids"          { 
    value = "${join(",", aws_subnet.private.*.id) }"                  
    description = "private subnet ids" 
    }
output "subnets_private_cidr_block"   { 
    value = "${join(",", aws_subnet.private.*.cidr_block) }"          
    description = "private cidr block" 
    }
output "subnets_public_ids"           { 
    value = "${join(",", aws_subnet.public.*.id) }"                   
    description = "Public subnet ids" 
    }
output "subnets_public_cidr_block"    { 
    value = "${join(",", aws_subnet.public.*.cidr_block) }"           
    description = "public cidr block" 
    }
output "rtb_private_ids"              { 
    value = "${join(",", aws_route_table.private.*.id) }"            
    description = "routing table private ids." 
    }
output "rtb_public_ids"               { 
    value = "${join(",", aws_route_table.public.*.id) }"              
    description = "routing table public ids" 
    }