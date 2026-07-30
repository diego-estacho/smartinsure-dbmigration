-- RN-053 (regras-de-negocio/grupo-de-cotacao.md) — estabelecimento cotado do Grupo de Cotação.
-- ADR-063: ausente significa matriz; não há valor sentinela. Sem backfill — Rascunhos existentes
-- seguem válidos com a matriz como estabelecimento.
-- Batch separado por GO: a coluna nova só é referenciável por índice no batch seguinte (mesmo
-- problema do V20260727234252__adicionar-matriz-em-persons.sql — SQL Server resolve nomes de
-- coluna na compilação do batch, e falha com o erro 207 se ADD e a referência convivem no mesmo).

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.QuotationGroups', N'BranchPersonId') IS NULL
BEGIN
    ALTER TABLE dbo.QuotationGroups
        ADD BranchPersonId UNIQUEIDENTIFIER NULL
            CONSTRAINT FK_QuotationGroups_Branch REFERENCES dbo.Persons (Id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_QuotationGroups_BranchPersonId'
                AND object_id = OBJECT_ID(N'dbo.QuotationGroups'))
BEGIN
    CREATE INDEX IX_QuotationGroups_BranchPersonId
        ON dbo.QuotationGroups (BranchPersonId)
        WHERE BranchPersonId IS NOT NULL;
END
