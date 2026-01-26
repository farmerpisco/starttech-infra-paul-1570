output "alb_dns_name" {
  value       = module.compute.alb_dns_name
  description = "The domain name of the load balancer"
}

output "redis_endpoint" {
  value = module.storage.redis_endpoint
}

output "s3_bucket_name" {
  description = "Name of S3 bucket created for frontend files"
  value       = module.storage.s3_bucket_name
}

output "cloudfront_dist_id" {
  description = "Cloundfront distribution ID"
  value       = module.storage.cloudfront_dist_id
}
