project  = "dev"
vpc_cidr = "10.0.0.0/16"
public_subnets = {
  public-1a = {
    name = "public-1a"
    cidr = "10.0.1.0/24"
    az   = "ap-northeast-1a"
  },
  public-1c = {
    name = "public-1c"
    cidr = "10.0.2.0/24"
    az   = "ap-northeast-1c"
  }
}

private_subnets = {
  private-1a = {
    name = "private-1a"
    cidr = "10.0.10.0/24"
    az   = "ap-northeast-1a"
  },
  private-1c = {
    name = "private-1c"
    cidr = "10.0.20.0/24"
    az   = "ap-northeast-1c"
  }
}