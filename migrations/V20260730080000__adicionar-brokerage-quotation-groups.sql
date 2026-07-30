-- RN-057/ADR-050 — Corretora da solicitação de Cotações no Grupo de Cotação (BrokerageId).
-- O fan-out enfileira itens num canal in-process (volátil); o reconciliador reenfileira as Cotações que
-- ficaram em Requested após restart/deploy e, para reconstruir o work item, precisa da Corretora dona da
-- solicitação. Guardamos essa Corretora no Grupo. FK opcional a Persons (a Corretora é uma Pessoa) — nula
-- enquanto o Grupo nunca foi cotado. Espelha o mapping EF QuotationGroupMapping. Artefatos em inglês (ADR-058).

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.QuotationGroups', N'BrokerageId') IS NULL
BEGIN
    ALTER TABLE dbo.QuotationGroups
        ADD BrokerageId UNIQUEIDENTIFIER NULL
            CONSTRAINT FK_QuotationGroups_Brokerage REFERENCES dbo.Persons (Id);
END
