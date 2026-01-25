resource "aws_cloudwatch_log_group" "st_cw_lg" {
  name              = "${var.project_name}-Log-Group"
  retention_in_days = 30

  tags = {
    Environment = "dev"
    Application = "serviceA"
  }
}

resource "aws_iam_role" "st_ec2_cw_role" {
  name = "${var.project_name}-ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "st_cw_la" {
  role       = aws_iam_role.st_ec2_cw_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "st_ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.st_ec2_cw_role.name
}