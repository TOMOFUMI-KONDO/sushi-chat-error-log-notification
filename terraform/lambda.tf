resource "aws_lambda_function" "error-log-notification" {
  function_name    = "${var.project}-error-log-notification"
  filename         = "../out/function.zip"
  source_code_hash = filebase64sha256("../out/function.zip")
  role             = aws_iam_role.error-log-notification.arn
  runtime          = "go1.x"
  handler          = "main"

  environment {
    variables = {
      CHANNEL_ID = var.discord_channel_id
      TOKEN      = var.discord_token
    }
  }

  tags = {
    Project = var.project
  }
}

resource "aws_iam_role" "error-log-notification" {
  name = "${var.project}-error-log-notification"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : ""
        Effect : "Allow",
        Action : "sts:AssumeRole",
        Principal : {
          Service : "lambda.amazonaws.com"
        },
      }
    ]
  })

  tags = {
    Project = var.project
  }
}

resource "aws_lambda_permission" "cloudwatch_logs_app_error" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.error-log-notification.function_name
  principal     = "logs.ap-northeast-1.amazonaws.com"
  source_arn    = data.aws_cloudwatch_log_group.ec2_app_error.arn
}

resource "aws_lambda_permission" "cloudwatch_logs_nginx_error" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.error-log-notification.function_name
  principal     = "logs.ap-northeast-1.amazonaws.com"
  source_arn    = data.aws_cloudwatch_log_group.ec2_nginx_error.arn
}

resource "aws_lambda_permission" "cloudwatch_logs_app_info" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.error-log-notification.function_name
  principal     = "logs.ap-northeast-1.amazonaws.com"
  source_arn    = data.aws_cloudwatch_log_group.ec2_app_info.arn
}

resource "aws_lambda_permission" "cloudwatch_logs_nginx_access" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.error-log-notification.function_name
  principal     = "logs.ap-northeast-1.amazonaws.com"
  source_arn    = data.aws_cloudwatch_log_group.ec2_nginx_access.arn
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_logs_app_error" {
  name            = "${var.project}-cloudwatch_logs_app_error"
  destination_arn = aws_lambda_function.error-log-notification.arn
  log_group_name  = data.aws_cloudwatch_log_group.ec2_app_error.name
  filter_pattern  = ""
  depends_on      = [aws_lambda_permission.cloudwatch_logs_app_error]
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_logs_nginx_error" {
  name            = "${var.project}-cloudwatch_logs_nginx_error"
  destination_arn = aws_lambda_function.error-log-notification.arn
  log_group_name  = data.aws_cloudwatch_log_group.ec2_nginx_error.name
  filter_pattern  = ""
  depends_on      = [aws_lambda_permission.cloudwatch_logs_nginx_error]
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_logs_app_info" {
  name            = "${var.project}-cloudwatch_logs_app_info"
  destination_arn = aws_lambda_function.error-log-notification.arn
  log_group_name  = data.aws_cloudwatch_log_group.ec2_app_info.name
  filter_pattern  = ""
  depends_on      = [aws_lambda_permission.cloudwatch_logs_app_info]
}

resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_logs_nginx_access" {
  name            = "${var.project}-cloudwatch_logs_nginx_access"
  destination_arn = aws_lambda_function.error-log-notification.arn
  log_group_name  = data.aws_cloudwatch_log_group.ec2_nginx_access.name
  filter_pattern  = ""
  depends_on      = [aws_lambda_permission.cloudwatch_logs_nginx_access]
}
