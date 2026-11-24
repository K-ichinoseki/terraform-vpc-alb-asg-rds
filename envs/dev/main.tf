module "network" {
  source          = "../../modules/network"
  project         = var.project
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "alb" {
  source = "../../modules/alb"
  project = var.project
  public_subnet_ids = module.network.public_subnet_ids
  vpc_id = module.network.vpc_id

}