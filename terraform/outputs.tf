output "alb_dns_name" {  
  value= module.compute.alb_dns_name
  description = "The domain name of the load balancer"
}

output "redis_endpoint" {
  value = module.storage.redis_endpoint
}
