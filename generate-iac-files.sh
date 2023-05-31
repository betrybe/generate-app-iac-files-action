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
    staging      = false
    production   = false
  }

  production_subdomains = [$prod_subdomain]
}
EOF
echo "::endgroup::"

echo "::group::Criando values files do Helm para '$APP_NAME'"

fetch_template_file() {
  curl -s "https://x-access-token:$ADMIN_TOKEN@raw.githubusercontent.com/betrybe/infrastructure-templates/main/helm-values-files/$1" -O
}
fetch_template_file values.yaml
fetch_template_file values-homologation.yaml
fetch_template_file values-production.yaml
fetch_template_file values-staging.yaml
fetch_template_file values-preview-apps.yaml

# Adc nome do projeto nos values files
find ./*.yaml -type f -exec sed -i "s/APP_NAME/$APP_NAME/g" {} \;

# Configura ingressRoute default
ingress_route_subdomain="api"
ingress_route_path_prefix="&& PathPrefix('/$APP_NAME')"
if [[ ! -z "$BETRYBE_SUBDOMAIN" ]]; then
  ingress_route_subdomain=$BETRYBE_SUBDOMAIN
  ingress_route_path_prefix=""
fi

find ./*.yaml -type f -exec sed -i "s/INGRESS_ROUTE_PATH_PREFIX/$ingress_route_path_prefix/g" {} \;
find ./*.yaml -type f -exec sed -i "s/INGRESS_ROUTE_SUBDOMAIN/$ingress_route_subdomain/g" {} \;

echo "::endgroup::"

echo "::group::Criando nova branch, fazendo commit e push no repositório @$GITHUB_REPOSITORY"
git config --global user.name 'trybe-tech-ops'
git config --global user.email 'trybe-tech-ops@users.noreply.github.com'
git checkout -b "$APP_NAME"
git add .
git commit -m "Cria nova aplicação $APP_NAME"
git push origin "$APP_NAME"
echo "::endgroup::"
