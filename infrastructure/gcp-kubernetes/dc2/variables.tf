variable "project" {
  type        = string
  description = "Google Cloud project"
}

variable "dc2_zone" {
  type        = string
  description = "Google Cloud zone for second cluster"
  default     = "us-west1-b"
}
