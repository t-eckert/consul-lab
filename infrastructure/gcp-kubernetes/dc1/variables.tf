variable "project" {
  type        = string
  description = "Google Cloud project"
}

variable "dc1_zone" {
  type        = string
  description = "Google Cloud zone for first cluster"
  default     = "us-central1-a"
}
