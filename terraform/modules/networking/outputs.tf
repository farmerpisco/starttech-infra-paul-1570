# output "st_ec2_profile_name" {
#   value = aws_iam_instance_profile.st_ec2_profile.name
#   description = "The name of the EC2 instance profile for CloudWatch access"
# }

output "st_vpc_id" {
  value = aws_vpc.st_vpc.id
}

output "st_sg_id" {
  value = aws_security_group.st_sg.id
}

output "st_alb_sg_id" {
  value = aws_security_group.st_alb_sg.id
}

output "redis_sg_id" {
  value = aws_security_group.redis_sg.id
}

output "st_private_subnets_ids" {
  value = aws_subnet.st_private_subnets[*].id
}

output "st_public_subnets_ids" {
  value = aws_subnet.st_public_subnets[*].id
}