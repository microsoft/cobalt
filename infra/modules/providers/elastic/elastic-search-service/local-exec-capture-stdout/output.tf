output "output" {
  description = "JSON output of the command"
  value       = jsondecode(null_resource.contents.triggers["output"])
}