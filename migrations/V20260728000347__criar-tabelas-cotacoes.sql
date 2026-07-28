-- RN-056..061 (regras-de-negocio/cotacao.md) — Cotação (Quotation) e a etapa de cotações.
-- O retorno de UMA Seguradora para um Grupo de Cotação: classificação estável do resultado
-- (ADR-064), esteira/motivos, prêmio/condições (quando aplicável) e veredito de CCG.
-- Espelha os mappings EF QuotationMapping / QuotationReasonMapping (mesma janela de release) e
-- adiciona SelectedQuotationId ao Grupo (RN-059). Fan-out assíncrono (ADR-050). ADR-058: artefatos em inglês.

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.Quotations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Quotations (
        Id                     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Quotations PRIMARY KEY,
        QuotationGroupId       UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_Quotations_QuotationGroup REFERENCES dbo.QuotationGroups (Id),
        BrokerageId            UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_Quotations_Brokerage REFERENCES dbo.Persons (Id),
        InsurerId              UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_Quotations_Insurer REFERENCES dbo.Insurers (Id),
        ProcessingStatus       NVARCHAR(20)     NOT NULL, -- Requested | Obtained | Failed (RN-057)
        Result                 NVARCHAR(20)     NULL,     -- Automatic | Analysis | Unavailable | Unrecognized (ADR-064)
        AnalysisTrack          NVARCHAR(20)     NULL,     -- Underwriting | Credit | Pep | Reinsurance | Registration
        Premium                DECIMAL(18,2)    NULL,
        CommissionPercentage   DECIMAL(9,4)     NULL,
        CommissionValue        DECIMAL(18,2)    NULL,
        Tax                    DECIMAL(18,2)    NULL,
        AvailableLimit         DECIMAL(18,2)    NULL,
        CcgMaxLimitWithoutNeed DECIMAL(18,2)    NULL,
        ProposalExternalId     NVARCHAR(100)    NULL,
        ProposalNumber         NVARCHAR(50)     NULL,
        RequiresCcg            BIT              NOT NULL,
        CcgSigned              BIT              NOT NULL,
        ObtainedAt             DATETIME2        NULL,
        CreatedAt              DATETIME2        NOT NULL,
        CreatedBy              NVARCHAR(100)    NOT NULL,
        UpdatedAt              DATETIME2        NULL,
        UpdatedBy              NVARCHAR(100)    NULL
    );

    -- Uma Cotação por (Grupo, Seguradora) — o fan-out não duplica (RN-057).
    CREATE UNIQUE INDEX UX_Quotations_GroupInsurer ON dbo.Quotations (QuotationGroupId, InsurerId);

    -- Varredura do reconciliador: Requested por antiguidade (ADR-050).
    CREATE INDEX IX_Quotations_ProcessingStatus_CreatedAt ON dbo.Quotations (ProcessingStatus, CreatedAt);
END

IF OBJECT_ID(N'dbo.QuotationReasons', N'U') IS NULL
BEGIN
    -- Motivos informados pela Seguradora numa Cotação Indisponível/Recusada (RN-058). Lista como dado.
    CREATE TABLE dbo.QuotationReasons (
        Id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_QuotationReasons PRIMARY KEY,
        QuotationId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QuotationReasons_Quotation REFERENCES dbo.Quotations (Id),
        Text        NVARCHAR(1000)   NOT NULL,
        CreatedAt   DATETIME2        NOT NULL,
        CreatedBy   NVARCHAR(100)    NOT NULL,
        UpdatedAt   DATETIME2        NULL,
        UpdatedBy   NVARCHAR(100)    NULL
    );

    CREATE INDEX IX_QuotationReasons_QuotationId ON dbo.QuotationReasons (QuotationId);
END

-- RN-059: a Cotação escolhida do Grupo. Referência simples (sem FK — evita ciclo com Quotations.QuotationGroupId).
IF COL_LENGTH(N'dbo.QuotationGroups', N'SelectedQuotationId') IS NULL
BEGIN
    ALTER TABLE dbo.QuotationGroups ADD SelectedQuotationId UNIQUEIDENTIFIER NULL;
END
