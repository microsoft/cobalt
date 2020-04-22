output "repo_clone_url" {
  description = "The Git repository where IaC templates are stored and watched for changes"
  value       = azuredevops_git_repository.repo.web_url
}
