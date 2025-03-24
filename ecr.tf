resource "aws_ecr_repository" "basic_app_web_ecr" {
  name = "basic-app-web-ecr"
}

resource "aws_ecr_lifecycle_policy" "web_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.basic_app_web_ecr.name
  policy     = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 10 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}

resource "aws_ecr_repository" "basic_app_app_ecr" {
  name = "basic-app-app-ecr"
}

resource "aws_ecr_lifecycle_policy" "app_ecr_lifecycle_policy" {
  repository = aws_ecr_repository.basic_app_app_ecr.name
  policy     = <<EOF
  {
    "rules": [
      {
        "rulePriority": 1,
        "description": "Keep last 10 release tagged images",
        "selection": {
          "tagStatus": "tagged",
          "tagPrefixList": ["release"],
          "countType": "imageCountMoreThan",
          "countNumber": 10
        },
        "action": {
          "type": "expire"
        }
      }
    ]
  }
EOF
}

