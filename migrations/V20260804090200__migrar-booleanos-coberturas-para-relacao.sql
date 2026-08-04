-- RN-104 (AB#0007) — converte os booleanos provisórios do Grupo de Cotação para a relação com a
-- Cobertura Adicional canônica e remove as colunas.
-- Depende de V20260804090100 (tabelas) e de V20260804090000 (nome da canônica corrigido).
--
-- FALHA ALTO de propósito quando a canônica não existe: a seleção de cobertura afeta o prêmio, então
-- é preferível quebrar o deploy a converter errado ou perder a escolha em silêncio.
--
-- NEWID() e não UUIDv7 porque estas linhas são criadas pela migração, não pela aplicação — o padrão
-- UUIDv7 (ADR-029) vale para o que a aplicação insere.
--
-- Batches separados por GO: a coluna só deixa de ser referenciável no batch seguinte ao DROP, e o
-- SQL Server resolve nomes de coluna na compilação do batch (mesmo motivo dos ADD em migrations
-- anteriores, ex.: V20260730125555).

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.QuotationGroups', N'IncludesPenaltyCoverage') IS NOT NULL
BEGIN
    DECLARE @multa UNIQUEIDENTIFIER =
        (SELECT Id FROM dbo.AdditionalCoverages WHERE Name = N'Multas');
    DECLARE @trab UNIQUEIDENTIFIER =
        (SELECT Id FROM dbo.AdditionalCoverages WHERE Name = N'Trabalhista e Previdenciária');

    IF @multa IS NULL OR @trab IS NULL
    BEGIN
        THROW 50017, N'AB#0007: Coberturas Adicionais canonicas "Multas" e/ou "Trabalhista e Previdenciaria" ausentes - conversao dos booleanos abortada.', 1;
    END;

    INSERT INTO dbo.QuotationGroupAdditionalCoverages
        (Id, QuotationGroupId, AdditionalCoverageId, CreatedAt, CreatedBy)
    SELECT NEWID(), g.Id, @multa, SYSUTCDATETIME(), N'migration-ab-0007'
      FROM dbo.QuotationGroups g
     WHERE g.IncludesPenaltyCoverage = 1
       AND NOT EXISTS (SELECT 1
                         FROM dbo.QuotationGroupAdditionalCoverages x
                        WHERE x.QuotationGroupId = g.Id
                          AND x.AdditionalCoverageId = @multa);

    INSERT INTO dbo.QuotationGroupAdditionalCoverages
        (Id, QuotationGroupId, AdditionalCoverageId, CreatedAt, CreatedBy)
    SELECT NEWID(), g.Id, @trab, SYSUTCDATETIME(), N'migration-ab-0007'
      FROM dbo.QuotationGroups g
     WHERE g.IncludesLaborCoverage = 1
       AND NOT EXISTS (SELECT 1
                         FROM dbo.QuotationGroupAdditionalCoverages x
                        WHERE x.QuotationGroupId = g.Id
                          AND x.AdditionalCoverageId = @trab);
END
GO

IF COL_LENGTH(N'dbo.QuotationGroups', N'IncludesPenaltyCoverage') IS NOT NULL
    ALTER TABLE dbo.QuotationGroups DROP COLUMN IncludesPenaltyCoverage;
GO

IF COL_LENGTH(N'dbo.QuotationGroups', N'IncludesLaborCoverage') IS NOT NULL
    ALTER TABLE dbo.QuotationGroups DROP COLUMN IncludesLaborCoverage;
