data "aws_cloudwatch_log_group" "ec2_app_error" {
  name = "/${var.project}/ec2/app/error.log"
}

data "aws_cloudwatch_log_group" "ec2_nginx_error" {
  name = "/${var.project}/ec2/nginx/error.log"
}
