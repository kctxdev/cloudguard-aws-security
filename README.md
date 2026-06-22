# CloudGuard — Detecção e Resposta a Incidentes em AWS

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

Plataforma de segurança em nuvem provisionada com **Terraform**, pipeline DevSecOps via **GitHub Actions** e resposta automática a incidentes com **AWS Lambda + GuardDuty**.

---

## Visão Geral

![Diagrama de Arquitetura do CloudGuard](./diagrams/architecture.png)

O CloudGuard implementa uma infraestrutura de segurança completa na AWS, cobrindo desde o isolamento de rede até a contenção automática de ameaças em tempo real.

| Capacidade | Serviço AWS | Módulo Terraform |
|---|---|---|
| Rede isolada sem exposição pública | VPC, Subnets, IGW | `modules/vpc` |
| Controle de acesso por menor privilégio | IAM Roles, Instance Profile | `modules/iam` |
| Servidor hardened sem SSH | EC2, SSM, IMDSv2 | `modules/ec2` |
| Logs imutáveis e criptografados | S3, Versioning, SSE | `modules/s3` |
| Detecção de ameaças e auditoria | GuardDuty, CloudTrail, SNS | `modules/monitoring` |
| Contenção automática de instâncias | Lambda, EventBridge, SG | `modules/security-response` |

---

## Pré-requisitos

- **Git** e conta ativa no **GitHub**
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configurado (`aws configure`)
- Conta AWS com permissões de administrador
- Python 3.12+ _(opcional — apenas para testar a Lambda localmente)_

---

## Estrutura do Projeto

```text
cloudguard-aws-security/
├── terraform/
│   ├── versions.tf                  # Versões do Terraform e providers
│   ├── providers.tf                 # Configuração do provider AWS + variáveis globais
│   ├── backend.tf                   # Backend remoto S3 + DynamoDB
│   ├── modules/
│   │   ├── vpc/                     # VPC, subnets públicas/privadas, IGW
│   │   ├── iam/                     # Roles para EC2, Lambda e CloudTrail
│   │   ├── ec2/                     # Instância hardened com SSM e IMDSv2
│   │   ├── s3/                      # Bucket de auditoria criptografado
│   │   ├── monitoring/              # GuardDuty, CloudTrail, SNS, alarmes
│   │   └── security-response/       # Lambda de isolamento + EventBridge
│   │       └── lambda/
│   │           └── handler.py       # Função Python de resposta a incidentes
│   └── envs/
│       ├── dev/                     # Ambiente de desenvolvimento
│       └── prod/                    # Ambiente de produção
├── .github/
│   └── workflows/
│       └── terraform-ci.yml         # Pipeline CI/CD com validação e deploy
├── docs/
│   ├── threat-model.md              # Modelagem de ameaças (STRIDE)
│   ├── incident-scenarios.md        # Cenários e playbooks de resposta
│   └── decisions.md                 # ADRs — registro de decisões técnicas
└── diagrams/
    └── architecture.png             # Diagrama de arquitetura
```

---

## Configuração Inicial (Bootstrap)

Antes do primeiro `terraform apply`, crie manualmente o bucket S3 e a tabela DynamoDB para o estado remoto:

```bash
# 1. Criar o bucket de state
aws s3api create-bucket \
  --bucket cloudguard-terraform-state \
  --region us-east-1

# 2. Habilitar versionamento
aws s3api put-bucket-versioning \
  --bucket cloudguard-terraform-state \
  --versioning-configuration Status=Enabled

# 3. Criar tabela DynamoDB para lock
aws dynamodb create-table \
  --table-name cloudguard-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

> **GitHub Actions:** para que o pipeline funcione, configure previamente o provedor de identidade OIDC na sua conta AWS. Isso permite que o GitHub assuma as roles de deploy sem o uso de chaves estáticas. Veja como: [GitHub OIDC + AWS](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services).

---

## Deploy

> ⚠️ Os comandos abaixo são recomendados apenas para **testes locais**. O deploy oficial deve ser feito pela esteira de CI/CD via GitHub Actions.

**Ambiente DEV**

```bash
cd terraform/envs/dev
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

**Ambiente PROD**

```bash
cd terraform/envs/prod
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

> O ambiente `prod` exige **aprovação manual** no GitHub antes do `apply`, conforme configurado no workflow.

---

## Variáveis

Edite o arquivo `terraform.tfvars` do ambiente desejado:

| Variável | Descrição | Padrão |
|---|---|---|
| `aws_region` | Região AWS onde os recursos serão criados | `us-east-1` |
| `alert_email` | Email para receber alertas de segurança via SNS | `""` (desabilitado) |

---

## Pipeline CI/CD

O arquivo `.github/workflows/terraform-ci.yml` executa as seguintes etapas automaticamente:

```
Push/PR em develop ou main
         │
         ▼
   [ validate ]          → terraform fmt + init + validate (dev e prod)
         │
    ┌────┴────┐
    ▼         ▼
[plan-dev] [plan-prod]   → terraform plan por ambiente
    │
    ▼
[apply-dev]              → apply automático ao fazer push em develop
    │
    ▼
[apply-prod]             → apply em main (requer aprovação manual no GitHub)
```

### Secrets necessários

Configure em **Settings → Secrets and variables → Actions**:

| Secret | Descrição |
|---|---|
| `AWS_ROLE_ARN_DEV` | ARN da role IAM para deploy no DEV (via OIDC) |
| `AWS_ROLE_ARN_PROD` | ARN da role IAM para deploy no PROD (via OIDC) |
| `ALERT_EMAIL` | Email para alertas de segurança |

O pipeline usa OIDC para autenticar na AWS — sem access keys hardcoded.

---

## Resposta Automática a Incidentes

O fluxo de resposta funciona da seguinte forma:

1. **GuardDuty** detecta uma ameaça (ex: mineração de criptomoeda, backdoor ativo).
2. **EventBridge** captura o finding com severidade >= 7.
3. **Lambda** (`handler.py`) executa automaticamente:
   - Troca o Security Group da instância comprometida pelo SG de isolamento (sem tráfego de entrada ou saída).
   - Salva o finding completo no S3 como evidência forense.
   - Envia notificação via SNS com os detalhes do incidente.
4. O time de segurança recebe o alerta e conduz a investigação manual.

---

## Práticas de Segurança Aplicadas

- **EC2 sem SSH e sem IP público** — acesso somente via AWS SSM Session Manager.
- **IMDSv2 obrigatório** — previne ataques SSRF que roubam credenciais da instância.
- **IAM com menor privilégio** — cada recurso possui apenas as permissões necessárias.
- **S3 com Block Public Access** — nenhum dado de auditoria exposto publicamente.
- **Criptografia em repouso** — volumes EC2 e objetos S3 criptografados com AES-256.
- **CloudTrail multi-região** — todas as chamadas de API registradas e com integridade validada.

---

## Destruir a Infraestrutura

```bash
cd terraform/envs/dev
terraform destroy -var-file="terraform.tfvars"
```

> O bucket S3 de auditoria tem `force_destroy = true` apenas no ambiente **DEV**. No **PROD**, ele não será destruído automaticamente, preservando logs e evidências forenses.

---

## Próximos Passos

- [ ] Adicionar `tfsec` ou `checkov` ao pipeline para análise estática de segurança.
- [ ] Configurar AWS Organizations + SCPs para restringir ações em nível de conta.
- [ ] Implementar AWS Security Hub para centralizar findings.
- [ ] Adicionar notificação no Slack via Lambda ou SNS subscription HTTP.
- [ ] Preencher os documentos em `/docs` com o threat model e os playbooks do seu contexto.

---

## Autor

Criado e mantido por **Johnata**

🔗 [LinkedIn](#) · 💻 [GitHub](#)
