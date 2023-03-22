#!/bin/bash
set -e

echo "::group::Gerando arquivo '$APP_NAME/terragrunt.hcl'"
mkdir "$APP_NAME"
cd "$APP_NAME"
touch terragrunt.hcl

prod_subdomain=""
if [[ ! -z "$BETRYBE_SUBDOMAIN" ]]; then
  prod_subdomain="\"$BETRYBE_SUBDOMAIN\""
fi

cat > terragrunt.hcl << EOF
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
echo "::endgroup::"

echo "::group::Criando values files do Helm para '$APP_NAME'"
cp -r ../chart/values*.yaml ./

find ./*.yaml -type f -exec sed -i "s/APP_NAME/$APP_NAME/g" {} \;
echo "::endgroup::"

echo "::group::Criando nova branch, fazendo commit e push no repositório @$GITHUB_REPOSITORY"
git config --global user.name 'trybe-tech-ops'
git config --global user.email 'trybe-tech-ops@users.noreply.github.com'
git checkout -b "$APP_NAME"
git add .
git commit -m "Cria nova aplicação $APP_NAME"
git push origin "$APP_NAME"
echo "::endgroup::"
