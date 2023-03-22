#!/bin/bash
set -e

echo "Para adicionar mais recuros consulte o README.md edite o arquivo $APP_NAME/terragrunt.hcl"

mkdir "$APP_NAME"
touch "$APP_NAME/terragrunt.hcl"

prod_subdomain=""
if [[ ! -z "$BETRYBE_SUBDOMAIN" ]]; then
  prod_subdomain="\"$BETRYBE_SUBDOMAIN\""
fi

# Create Terragrunt file
cat > "$APP_NAME/terragrunt.hcl" << EOF
include root {
  path = find_in_parent_folders()
}

inputs = {
  name  = "$APP_NAME"
  squad = "$SQUAD_NAME"

  argocd_deployment = {
    homologation = false
    staging      = true
    production   = false
  }

  production_subdomains = [$prod_subdomain]
}
EOF

# Create Helm values files
"$ACTION_PATH/create-values-files.sh" $APP_NAME

git config --global user.name 'trybe-tech-ops'
git config --global user.email 'trybe-tech-ops@users.noreply.github.com'
git checkout -b $APP_NAME
git add $APP_NAME
git commit -m "Cria nova aplicação $APP_NAME"
git push origin $APP_NAME
