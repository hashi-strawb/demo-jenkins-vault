terraform {
  cloud {
    organization = "hashi_strawb_demo"

    workspaces {
      name = "vault_jenkins_demo"
    }
  }
}

provider "vault" {
  # Configuration provided by VAULT_ADDR, VAULT_NAMESPACE env vars
  # Credentials provided by VAULT_TOKEN env var
}

resource "vault_namespace" "jenkins" {
  path      = "jenkins"
  namespace = "demos"
}




resource "vault_mount" "kv" {
  namespace = vault_namespace.jenkins.path_fq

  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_generic_secret" "example" {
  namespace = vault_namespace.jenkins.path_fq
  path      = "kv/test"

  data_json = <<EOT
{
  "foo": "bar",
  "pizza": "cheese"
}
EOT
}



#
# AppRole and Policies
#

resource "vault_auth_backend" "approle" {
  namespace = vault_namespace.jenkins.path_fq

  type = "approle"

  tune {
    max_lease_ttl      = "90000s"
    listing_visibility = "unauth"
  }
}

resource "vault_policy" "kv-read" {
  namespace = vault_namespace.jenkins.path_fq
  name      = "kv-read"

  policy = <<EOT
path "kv/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_approle_auth_backend_role" "default" {
  namespace      = vault_namespace.jenkins.path_fq
  backend        = vault_auth_backend.approle.path
  role_name      = "default"
  token_policies = ["default"]
}

resource "vault_approle_auth_backend_role_secret_id" "default" {
  namespace = vault_namespace.jenkins.path_fq
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.default.role_name
}
resource "vault_approle_auth_backend_role" "kv-read" {
  namespace      = vault_namespace.jenkins.path_fq
  backend        = vault_auth_backend.approle.path
  role_name      = "kv-read"
  token_policies = ["kv-read"]
}

resource "vault_approle_auth_backend_role_secret_id" "kv-read" {
  namespace = vault_namespace.jenkins.path_fq
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.kv-read.role_name
}


output "approle_creds" {
  value = {
    default = {
      role_id   = vault_approle_auth_backend_role.default.role_id
      secret_id = vault_approle_auth_backend_role_secret_id.default.secret_id
    }
    kv-read = {
      role_id   = vault_approle_auth_backend_role.kv-read.role_id
      secret_id = vault_approle_auth_backend_role_secret_id.kv-read.secret_id
    }
  }
  sensitive = true
}
