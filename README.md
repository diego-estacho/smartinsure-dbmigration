# smartinsure-dbmigration

Repositório dedicado de migrations do banco SmartInsure (SQL Server). O Flyway é o **único dono do schema** — EF Migrations são proibidas no backend (ADR-041).

> As decisões normativas vivem nos ADRs do repositório do backend: [ADR-041](../smartinsure-backend/docs/adr/041-flyway-dono-schema.md), [ADR-042](../smartinsure-backend/docs/adr/042-migration-timestamp.md) e [ADR-043](../smartinsure-backend/docs/adr/043-migrations-forward-only.md). Este README resume; em conflito, o ADR prevalece.

## Regras

- **Nomenclatura** (ADR-042): `V{yyyyMMddHHmmss}__descricao-em-kebab-case.sql` — timestamp puro de criação, nunca prefixo sequencial. Descrição em kebab-case, sem espaços nem caracteres especiais.
- **`outOfOrder=false`** sempre (config + comando do CI): migration com timestamp anterior à última aplicada é rejeitada — recrie com timestamp novo.
- **Imutáveis / forward-only** (ADR-043): migration aplicada em qualquer ambiente nunca é editada ou removida. Correção é sempre uma migration nova. Sem scripts de undo/rollback.
- **Guards de existência** em DDL onde aplicável (`IF OBJECT_ID(...) IS NULL`, `IF COL_LENGTH(...) IS NULL`): segurança de reexecução conceitual.
- **Aplicação exclusiva pelo CI** (ADR-041): push em `migrations/**` nas branches `develop`, `qa` e `master` aplica no banco do ambiente correspondente. Aplicação manual em qa/produção é proibida.
- Scripts nunca são copiados para outros repositórios — este repo é a fonte única.
- Mudança de mapping EF no backend e a migration correspondente andam na mesma janela de release; o banco migra **antes** do código que o consome.

## Fluxo de branches

`develop` → `qa` → `master` (uma branch por ambiente, promoção por PR).

## Desenvolvimento local

O `docker-compose.yml` do repositório `smartinsure-backend` (clonado como irmão desta pasta, ADR-001) aplica estas migrations no SQL Server local:

```
cd ../smartinsure-backend
docker compose --profile migrations up -d
```

O serviço `flyway` monta `./migrations` deste repo como volume, roda `migrate` (idempotente — só aplica o pendente) e encerra. O database `SmartInsure` é criado pelo serviço `mssql-init` se não existir.

## Criando uma migration

1. Gere o timestamp: `Get-Date -Format yyyyMMddHHmmss` (PowerShell) ou `date +%Y%m%d%H%M%S`.
2. Crie `migrations/V{timestamp}__minha-mudanca.sql` com guards de existência.
3. Valide localmente com o compose acima.
4. PR para `develop`; a promoção segue develop → qa → master.

## Configuração

`flyway.conf` versiona apenas o que não é secret (locations, outOfOrder, naming). URL, usuário e senha vêm de variáveis de ambiente (`FLYWAY_URL`, `FLYWAY_USER`, `FLYWAY_PASSWORD`) — em CI, dos secrets do GitHub Environment correspondente à branch; nunca versionados (ADR-054).
