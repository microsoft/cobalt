output "project_id" {
  value = local.project_id
}
output "project_name" {
  value = local.project_name
}
output "repo_clone_url" {
  value = azuredevops_git_repository.repo.web_url
}
