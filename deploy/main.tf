module "my-ecr" {
  source                  = "./modules/ecr"
  repository_name         = "django-app"
}

module "my-lightsail" {
  source                  = "./modules/lightsail"
  repository_url          = module.my-ecr.repository_url
}