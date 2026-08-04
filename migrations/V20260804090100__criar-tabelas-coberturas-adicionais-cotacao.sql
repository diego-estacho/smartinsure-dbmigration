-- RN-104/RN-105/RN-106 (AB#0007), ADR-103 — Coberturas Adicionais na Cotação.
--
-- dbo.QuotationGroupAdditionalCoverages: as Coberturas Adicionais CANÔNICAS que o corretor escolheu
--   na etapa de risco (RN-104), substituindo os booleanos provisórios IncludesPenaltyCoverage e
--   IncludesLaborCoverage — derrubados em V20260804090200.
-- dbo.QuotationAdditionalCoverages: por Cotação, a situação de cada cobertura escolhida —
--   Sent (o nome com que a Seguradora expõe a cobertura foi resolvido e enviado, RN-105) ou
--   NotOffered (a Seguradora não oferece na Modalidade cotada, ou o nome divergiu entre ramos —
--   RN-106/OPEN-22). Gravada em TODA Cotação, inclusive nas Indisponíveis e nas que falham.
--
-- Espelha os mappings EF (mesma janela de release). Enum como string (ADR-031). Id UUIDv7 gerado
-- pela aplicação (ADR-029/030). Artefatos em inglês (ADR-058). FK sem cascade (ADR-034).
-- SentName tem 300 para casar com ImportedAdditionalCoverages.Name.

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.QuotationGroupAdditionalCoverages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.QuotationGroupAdditionalCoverages (
        Id                   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_QuotationGroupAdditionalCoverages PRIMARY KEY,
        QuotationGroupId     UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QGAC_QuotationGroup     REFERENCES dbo.QuotationGroups (Id),
        AdditionalCoverageId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QGAC_AdditionalCoverage REFERENCES dbo.AdditionalCoverages (Id),
        CreatedAt            DATETIME2        NOT NULL,
        CreatedBy            NVARCHAR(100)    NOT NULL,
        UpdatedAt            DATETIME2        NULL,
        UpdatedBy            NVARCHAR(100)    NULL
    );

    -- RN-104: conjunto — a mesma cobertura aparece uma única vez por Grupo.
    CREATE UNIQUE INDEX UX_QGAC_GroupCoverage
        ON dbo.QuotationGroupAdditionalCoverages (QuotationGroupId, AdditionalCoverageId);

    CREATE INDEX IX_QGAC_AdditionalCoverageId
        ON dbo.QuotationGroupAdditionalCoverages (AdditionalCoverageId);
END
GO

IF OBJECT_ID(N'dbo.QuotationAdditionalCoverages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.QuotationAdditionalCoverages (
        Id                           UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_QuotationAdditionalCoverages PRIMARY KEY,
        QuotationId                  UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QAC_Quotation          REFERENCES dbo.Quotations (Id),
        AdditionalCoverageId         UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QAC_AdditionalCoverage REFERENCES dbo.AdditionalCoverages (Id),
        Status                       NVARCHAR(20)     NOT NULL, -- Sent | NotOffered (RN-106)
        SentName                     NVARCHAR(300)    NULL,     -- nome da Importada enviado; só quando Sent (RN-105)
        ImportedAdditionalCoverageId UNIQUEIDENTIFIER NULL      CONSTRAINT FK_QAC_ImportedAdditionalCoverage REFERENCES dbo.ImportedAdditionalCoverages (Id),
        CreatedAt                    DATETIME2        NOT NULL,
        CreatedBy                    NVARCHAR(100)    NOT NULL,
        UpdatedAt                    DATETIME2        NULL,
        UpdatedBy                    NVARCHAR(100)    NULL
    );

    -- RN-106: uma situação por (Cotação, Cobertura Adicional escolhida).
    CREATE UNIQUE INDEX UX_QAC_QuotationCoverage
        ON dbo.QuotationAdditionalCoverages (QuotationId, AdditionalCoverageId);

    CREATE INDEX IX_QAC_AdditionalCoverageId
        ON dbo.QuotationAdditionalCoverages (AdditionalCoverageId);
END
