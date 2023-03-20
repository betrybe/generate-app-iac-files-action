# Generate IaC files to new app

Action que gera os arquivos IaC para uma nova aplicação no https://github.com/betrybe/infrastructure-projects

- Gera o arquivo `terragrunt.hcl`
- Gera os values files do Helm
  - `values.yaml`
  - `values-staging.yaml`
  - `values-homologation.yaml`
  - `values-preview-apps.yaml`
  - `values-production.yaml`
- Faz push em uma branch de mesmo nome do projeto
