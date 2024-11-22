terraform {
  backend "s3" {
    bucket       = "dm-my-terrafrom-state"
    key          = "global/s3/terrafrom.tfstate"
    region       = "eu-west-2"
    dynamo_table = "terrafrom-lock-fule"
  }
}