
# This resource does nothing except provide a unique ID
resource "null_resource" "id" {
}

# This resource takes care of executing the command and storing the output
# to a local file. This will only ever happen a single time.
resource "null_resource" "shell" {
  provisioner "local-exec" {
    command     = format("%s > %s/%s.output", var.command, path.module, null_resource.id.id)
    environment = var.environment
  }

  provisioner "local-exec" {
    when       = destroy
    command    = format("rm %s/%s.output", path.module, null_resource.id.id)
    on_failure = continue
  }
}

# This reads the file into the state. If the file is missing (common if the
# deployment of this module occurs on multiple hosts) then the data defaults
# to {}
data "external" "output" {
  depends_on = [null_resource.shell]
  program    = ["bash", "${path.module}/read.sh", format("%s/%s.output", path.module, null_resource.id.id)]
}


# This resource will store the command outputs in the trigger block. This will only
# ever happen once.
#
# This is the magic that allows the local-exec output to be stored in the Terraform State.
resource "null_resource" "contents" {
  triggers = {
    output = jsonencode(data.external.output.result)
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}
