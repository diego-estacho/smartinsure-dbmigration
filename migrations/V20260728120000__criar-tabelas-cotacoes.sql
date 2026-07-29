-- RN-056..063 (regras-de-negocio/cotacao.md), ADR-064 — etapa de cotações (Passo 4).
-- dbo.Quotations: uma Cotação por Seguradora dentro de um Grupo de Cotação; resultado classificado
--   de forma estável (Result) + esteira (AnalysisTrack) + prêmio/comissão/limite e veredito de CCG
--   (RN-058, ADR-064), estado de processamento (Requested/Obtained/Failed — RN-057) e a minuta
--   capturada da Cotação selecionada (Tags/Cláusulas — RN-062).
-- dbo.QuotationReasons: motivos de indisponibilidade/recusa (do provedor ou locais — RN-056/RN-058).
-- QuotationGroups.SelectedQuotationId: a Cotação escolhida do Grupo (RN-059).
-- Espelha os mappings EF (mesma janela de release). Enums como string (ADR-031). Artefatos em inglês (ADR-058).
-- Validade por tempo (RN-061) e cancelamento das Cotações seguem deferidos (fora de escopo — OPEN-07).

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.Quotations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Quotations (
        Id                     UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Quotations PRIMARY KEY,
        QuotationGroupId       UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_Quotations_QuotationGroup REFERENCES dbo.QuotationGroups (Id),
        InsurerId              UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_Quotations_Insurer REFERENCES dbo.Insurers (Id),
        ProcessingStatus       NVARCHAR(20)     NOT NULL, -- Requested | Obtained | Failed (RN-057)
        Result                 NVARCHAR(20)     NULL,     -- Automatic | Analysis | Unavailable | Unrecognized (RN-058/ADR-064)
        AnalysisTrack          NVARCHAR(20)     NULL,     -- Underwriting | Credit | Pep | Reinsurance | Registration (RN-058)
        Premium                DECIMAL(18,2)    NULL,     -- apenas quando Automatic (RN-058)
        CommissionPercentage   DECIMAL(9,4)     NULL,
        CommissionValue        DECIMAL(18,2)    NULL,
        Tax                    DECIMAL(9,4)     NULL,
        AvailableLimit         DECIMAL(18,2)    NULL,
        ProposalExternalId     NVARCHAR(100)    NULL,     -- ProposalUniqueId do provedor
        ProposalNumber         NVARCHAR(50)     NULL,
        RequiresCcg            BIT              NOT NULL, -- veredito de CCG, ortogonal à classificação (ADR-064)
        CcgMaxLimitWithoutNeed DECIMAL(18,2)    NULL,
        CcgSigned              BIT              NOT NULL,
        MinutaTagsJson         NVARCHAR(MAX)    NULL,     -- Tags preenchidas da selecionada (RN-062)
        MinutaClausesJson      NVARCHAR(MAX)    NULL,     -- Cláusulas particulares marcadas da selecionada (RN-062)
        ObtainedAt             DATETIME2        NULL,     -- instante da resposta da Seguradora (RN-057)
        CreatedAt              DATETIME2        NOT NULL,
        CreatedBy              NVARCHAR(100)    NOT NULL,
        UpdatedAt              DATETIME2        NULL,
        UpdatedBy              NVARCHAR(100)    NULL
    );

    -- Uma Cotação por Seguradora dentro de um Grupo (idempotência do fan-out — RN-057).
    CREATE UNIQUE INDEX UX_Quotations_GroupInsurer ON dbo.Quotations (QuotationGroupId, InsurerId);
    CREATE INDEX IX_Quotations_InsurerId ON dbo.Quotations (InsurerId);
END

IF OBJECT_ID(N'dbo.QuotationReasons', N'U') IS NULL
BEGIN
    -- Motivos de indisponibilidade/recusa de uma Cotação (RN-056/RN-058). Source: Provider | Local.
    CREATE TABLE dbo.QuotationReasons (
        Id          UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_QuotationReasons PRIMARY KEY,
        QuotationId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QuotationReasons_Quotation REFERENCES dbo.Quotations (Id),
        Text        NVARCHAR(500)    NOT NULL,
        Source      NVARCHAR(20)     NOT NULL, -- Provider | Local
        CreatedAt   DATETIME2        NOT NULL,
        CreatedBy   NVARCHAR(100)    NOT NULL,
        UpdatedAt   DATETIME2        NULL,
        UpdatedBy   NVARCHAR(100)    NULL
    );

    CREATE INDEX IX_QuotationReasons_QuotationId ON dbo.QuotationReasons (QuotationId);
END

-- A Cotação escolhida do Grupo (RN-059). FK Restrict: a escolha aponta uma Cotação existente do Grupo.
IF COL_LENGTH(N'dbo.QuotationGroups', N'SelectedQuotationId') IS NULL
BEGIN
    ALTER TABLE dbo.QuotationGroups
        ADD SelectedQuotationId UNIQUEIDENTIFIER NULL
            CONSTRAINT FK_QuotationGroups_SelectedQuotation REFERENCES dbo.Quotations (Id);
END
