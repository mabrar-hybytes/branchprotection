variable "token_github" {
  type        = string
  description = "GitHub personal access token"
  sensitive   = true
}

variable "owner" {
  type        = string
  description = "GitHub repository owner"
}

variable "repository" {
  type        = string
  description = "GitHub repository name"
}
