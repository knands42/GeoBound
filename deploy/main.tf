module "my-ecr" {
  source                  = "./modules/ecr"
  repository_name         = "django-app"
}