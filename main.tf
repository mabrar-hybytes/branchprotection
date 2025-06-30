terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "cicdplan"                     # Replace with your actual S3 bucket name
    key            = "terraform/state.tfstate"      # Path inside the bucket
    region         = "eu-west-2"
    use_lockfile   = true
    encrypt        = true
  }
}

provider "github" {
  token = var.token_github                         # Uses the token passed via TF_VAR_token_github
  owner = "mabrar-hybytes"                         # Your GitHub username/org
}

# Fetch repository_id dynamically from the repository name
data "github_repository" "branchprotection_repo" {
  full_name = "mabrar-hybytes/branchprotection"
}

# Branch protection rule for the 'master' branch
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

# ✅ Declare the GitHub token input variable
variable "token_github" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}
