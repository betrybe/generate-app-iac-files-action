#!/bin/bash
set -e

fetch_template_file() {
  curl -s "https://x-access-token:$ADMIN_TOKEN@raw.githubusercontent.com/betrybe/infrastructure-templates/main/$1" -O
}

echo "::group::Criando arquivos de workflow para '$APP_NAME'"

cd $APP_NAME
mkdir .github
mkdir .github/workflows
cd .github/workflows

fetch_template_file github-cd-workflows-template/build-sync.yaml
fetch_template_file github-cd-workflows-template/production.yaml
fetch_template_file github-cd-workflows-template/staging.yaml
fetch_template_file github-cd-workflows-template/homologation.yaml
fetch_template_file github-cd-workflows-template/preview-apps.yaml

# Adc nome do projeto nos values files
find ./*.yaml -type f -exec sed -i "s/APP_NAME/$APP_NAME/g" {} \;

cd ../../

echo "::endgroup::"

echo "::group::Criando arquivo Dockerfile para '$APP_NAME'"
fetch_template_file "dockerfiles-templates/$DOCKERFILE_TEMPLATE"
echo "::endgroup::"

echo "::group::Fazendo commit e push na main do repositório @betrybe/$APP_NAME"

git config --global user.name 'trybe-tech-ops'
git config --global user.email 'trybe-tech-ops@users.noreply.github.com'
git add .
git commit -m "Cria workflows de deploy"
git push origin main

echo "::endgroup::"
