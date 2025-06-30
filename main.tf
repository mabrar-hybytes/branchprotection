terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "cicdplan"
    key            = "terraform/state.tfstate"
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "github" {
  token = var.token_github
  owner = "mabrar-hybytes"
}

data "github_repository" "branchprotection_repo" {
  full_name = "mabrar-hybytes/branchprotection"
}

resource "github_branch_protection" "master_protection" {
  repository_id = data.github_repository.branchprotection_repo.id
  pattern       = "master"

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
  }

  required_status_checks {
    strict   = true
    contexts = ["github-actions"]
  }

  require_signed_commits = true
}

variable "token_github" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}
