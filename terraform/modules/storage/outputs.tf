output "redis_endpoint" {
  value = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "s3_bucket_name" {
  description = "Name of S3 bucket created for frontend files"
  value       = aws_s3_bucket.st_s3.bucket
}

output "cloudfront_dist_id" {
  description = "Cloundfront distribution ID"
  value       = aws_cloudfront_distribution.st_frontend_cdn.id
}