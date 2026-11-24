variable "project" {
  type        = string
  description = "プロジェクト名"
}

variable "vpc_cidr" {
  type        = string
  description = "VPCのCIDR"
}

variable "public_subnets" {
  type = map(object({
    name = string
    cidr = string
    az   = string
  }))
  description = "パブリックサブネット"
}

variable "private_subnets" {
  type = map(object({
    name = string
    cidr = string
    az   = string
  }))
  description = "プライベートサブネット"
}
