#!/bin/bash

app_name=$1

if [[ -z "$app_name" ]]; then
  echo "É necessário um nome para aplicação"
  exit 1
fi

root_path="$(git rev-parse --show-toplevel)"

echo "Criando values files para $root_path/$app_name"

cp -r $root_path/chart/values*.yaml "$root_path/$app_name/"

cd "$root_path/$app_name"
if [ "$(uname)" == "Darwin" ]; then
  LC_ALL=C find ./*.yaml -type f -exec sed -i '' -e "s/APP_NAME/$app_name/g" {} \;
else
  find ./*.yaml -type f -exec sed -i "s/APP_NAME/$app_name/g" {} \;
fi
