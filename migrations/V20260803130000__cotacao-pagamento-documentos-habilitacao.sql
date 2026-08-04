-- RN-505 / RN-510 / RN-512 (regras-de-negocio/emissao.md): a Cotação passa a registrar o que a
-- Seguradora informou sobre pagamento e documentos — opções de parcelamento, dias possíveis de
-- vencimento da primeira parcela e documentos exigidos — para a etapa de emissão escolher dentro
-- dessas listas sem acionar o provedor de novo; e a Habilitação de Seguradora que obteve a Cotação,
-- porque a emissão usa a MESMA Habilitação, mesmo que ela seja inativada depois de cotar.
-- Dados do provedor, somente leitura para a plataforma → serializados (mesma escolha da minuta).
-- Espelha o mapeamento por convenção da entidade Quotation. Guards de existência: reaplicação segura.
IF COL_LENGTH(N'dbo.Quotations', N'InstallmentOptionsJson') IS NULL
BEGIN
    ALTER TABLE dbo.Quotations ADD InstallmentOptionsJson NVARCHAR(MAX) NULL;
END

IF COL_LENGTH(N'dbo.Quotations', N'PossibleGracePeriodsInDaysJson') IS NULL
BEGIN
    ALTER TABLE dbo.Quotations ADD PossibleGracePeriodsInDaysJson NVARCHAR(MAX) NULL;
END

IF COL_LENGTH(N'dbo.Quotations', N'RequiredDocumentsJson') IS NULL
BEGIN
    ALTER TABLE dbo.Quotations ADD RequiredDocumentsJson NVARCHAR(MAX) NULL;
END

-- Habilitação: nulo aceito porque Cotações obtidas antes desta regra não têm o vínculo registrado —
-- a emissão dessas cai no bloqueio por ausência de credencial (RN-512), não em emissão indevida.
IF COL_LENGTH(N'dbo.Quotations', N'BrokerageInsurerEnablementId') IS NULL
BEGIN
    ALTER TABLE dbo.Quotations ADD BrokerageInsurerEnablementId UNIQUEIDENTIFIER NULL
        CONSTRAINT FK_Quotations_BrokerageInsurerEnablements
        REFERENCES dbo.BrokerageInsurerEnablements (Id);
END

-- CREATE INDEX via EXEC: o batch é compilado inteiro antes de executar, e a coluna acabou de ser
-- criada neste mesmo arquivo — sem o EXEC o batch falha com "Invalid column name". `GO` no meio do
-- arquivo não é opção (convenção deste repositório).
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'IX_Quotations_BrokerageInsurerEnablementId'
                 AND object_id = OBJECT_ID(N'dbo.Quotations'))
BEGIN
    EXEC sp_executesql N'
        CREATE INDEX IX_Quotations_BrokerageInsurerEnablementId
            ON dbo.Quotations (BrokerageInsurerEnablementId)
            WHERE BrokerageInsurerEnablementId IS NOT NULL;';
END
