variable "token_github" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true  # This ensures the token is not exposed in logs
}

terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 5.0"  # Adjust to the desired version
    }
  }

  backend "s3" {
    bucket         = "cicdplan"               # Your S3 bucket name
    key            = "terraform/state.tfstate"  # Path inside the S3 bucket for the state file
    region         = "eu-west-2"              # Your AWS region (adjust as needed)
    use_lockfile   = true                     # Enable DynamoDB state locking (replaces dynamodb_table)
    encrypt        = true                     # Enable encryption for the state file
  }
}

provider "github" {
  token = var.token_github  # Fetch the token from the environment variable passed by GitHub Actions
  owner = "mabrar-hybytes"  # GitHub organization or username
}

# Fetch repository_id dynamically from the repository name
data "github_repository" "branchprotection_repo" {
  full_name = "mabrar-hybytes/branchprotection"  # Your repository's full name (owner/repo)
}

# Branch protection rule for the 'master' branch
resource "github_branch_protection" "master_protection" {
  repository_id = data.github_repository.branchprotection_repo.id  # Use the repository ID dynamically fetched

  pattern = "master"  # The branch to protect (use pattern instead of branch)

  # Enforcing Pull Request Reviews
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1  # Number of approvals required before merging
  }

  # Require Status Checks (for CI/CD)
  required_status_checks {
    strict   = true                  # Merging only allowed if all checks pass
    contexts = ["github-actions"]    # Replace with your actual GitHub Actions job name
  }

  # Require Signed Commits
  require_signed_commits = true
}
