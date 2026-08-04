-- RN-104 (AB#0007) — remove do Grupo de Cotação os booleanos provisórios de Cobertura Adicional.
-- A escolha do corretor passa a viver em dbo.QuotationGroupAdditionalCoverages (V20260804090100),
-- como relação com a Cobertura Adicional canônica.
--
-- SOMENTE DDL, de propósito. A conversão dos valores antigos para a relação NÃO é feita aqui:
-- ela dependeria de resolver a Cobertura Adicional canônica equivalente, e o catálogo canônico é
-- CURADO por ambiente (RN-040) — nome, id e até a existência da cobertura diferem entre
-- desenvolvimento, QA e produção. Migration que resolvesse canônica por nome converteria errado (ou
-- abortaria o deploy) em qualquer ambiente cujo catálogo não fosse igual ao de dev.
--
-- ATENÇÃO OPERACIONAL: em ambiente onde exista Grupo de Cotação com algum dos booleanos marcado, o
-- valor é PERDIDO por este DROP. Se a informação precisar ser preservada, a conversão é passo de
-- operação, executado no ambiente ANTES desta migration, por quem conhece o catálogo canônico daquele
-- ambiente (inserindo as linhas correspondentes em dbo.QuotationGroupAdditionalCoverages).
--
-- Idempotente: os guards de COL_LENGTH protegem `ALTER TABLE ... DROP COLUMN`, que o SQL Server
-- resolve depois da compilação do batch. Cada DROP em seu próprio batch (GO).

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.QuotationGroups', N'IncludesPenaltyCoverage') IS NOT NULL
    ALTER TABLE dbo.QuotationGroups DROP COLUMN IncludesPenaltyCoverage;
GO

IF COL_LENGTH(N'dbo.QuotationGroups', N'IncludesLaborCoverage') IS NOT NULL
    ALTER TABLE dbo.QuotationGroups DROP COLUMN IncludesLaborCoverage;
