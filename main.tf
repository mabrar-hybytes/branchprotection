terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.token_github
  owner = var.owner
}

data "github_repository" "branchprotection_repo" {
  name = var.repository
}

resource "github_branch_protection" "master_protection" {
  repository_id                   = data.github_repository.branchprotection_repo.id
  pattern                         = "master"
  enforce_admins                  = false
  allows_deletions                = false
  allows_force_pushes            = false
  blocks_creations                = false
  require_signed_commits         = true
  require_conversation_resolution = false
  required_linear_history        = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    required_approving_review_count = 1
    require_last_push_approval      = false
  }

  required_status_checks {
    strict   = true
    contexts = ["github-actions"]
  }
}
