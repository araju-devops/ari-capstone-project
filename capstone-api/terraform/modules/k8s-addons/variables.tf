variable "aks_host" {
  description = "AKS cluster endpoint"
  type        = string
}

variable "aks_client_certificate" {
  description = "AKS client certificate"
  type        = string
  sensitive   = true
}

variable "aks_client_key" {
  description = "AKS client key"
  type        = string
  sensitive   = true
}

variable "aks_cluster_ca_certificate" {
  description = "AKS cluster CA certificate"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name (dev/qa/prod)"
  type        = string
  default     = "dev"
}
