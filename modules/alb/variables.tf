variable "project" {
  type        = string
  description = "プロジェクト名"
}

variable "public_subnet_ids" {
  type = list(string)
  description = "パブリックサブネット"
}

variable "vpc_id" {
  type        = string
  description = "vpcid"
}