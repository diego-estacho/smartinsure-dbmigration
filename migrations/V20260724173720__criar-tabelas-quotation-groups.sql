-- RN-050/RN-051 (regras-de-negocio/grupo-de-cotacao.md) — Grupo de Cotação (QuotationGroup).
-- O pedido/estudo que o corretor monta no wizard de nova oferta (tomador, segurado, escopo de
-- Seguradoras, modalidade, valor segurado, vigência e coberturas), persistido em Rascunho (Draft).
-- Espelha os mappings EF QuotationGroupMapping / QuotationGroupInsurerMapping (mesma janela de release).
-- As coberturas são 2 booleanos provisórios (Multa, Trabalhista/Previdenciária) até existir o read de
-- coberturas ofertáveis por modalidade — quando migrarão para tabela própria (OPEN-07 / OPEN-16).
-- Cotar as Seguradoras e emitir seguem fora de escopo (mock no front). ADR-058: artefatos em inglês.

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.QuotationGroups', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.QuotationGroups (
        Id                      UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_QuotationGroups PRIMARY KEY,
        PolicyHolderId          UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QuotationGroups_PolicyHolder REFERENCES dbo.Persons (Id),
        InsuredId               UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QuotationGroups_Insured REFERENCES dbo.Persons (Id),
        ModalityId              UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QuotationGroups_Modality REFERENCES dbo.Modalities (Id),
        InsuredAmount           DECIMAL(18,2)    NOT NULL,
        CoverageStartDate       DATE             NOT NULL,
        CoverageEndDate         DATE             NOT NULL,
        ScopeMode               NVARCHAR(20)     NOT NULL, -- All | Specific (RN-050)
        IncludesPenaltyCoverage BIT              NOT NULL, -- Multa (provisório)
        IncludesLaborCoverage   BIT              NOT NULL, -- Trabalhista/Previdenciária (provisório)
        Status                  NVARCHAR(20)     NOT NULL, -- Draft (RN-050/RN-051)
        CreatedAt               DATETIME2        NOT NULL,
        CreatedBy               NVARCHAR(100)    NOT NULL,
        UpdatedAt               DATETIME2        NULL,
        UpdatedBy               NVARCHAR(100)    NULL
    );

    -- Histórico consultável por tomador e por segurado.
    CREATE INDEX IX_QuotationGroups_PolicyHolderId ON dbo.QuotationGroups (PolicyHolderId);
    CREATE INDEX IX_QuotationGroups_InsuredId ON dbo.QuotationGroups (InsuredId);
END

IF OBJECT_ID(N'dbo.QuotationGroupInsurers', N'U') IS NULL
BEGIN
    -- Seguradoras do escopo, quando o modo é Specific (RN-050). Escopo All não gera linhas.
    CREATE TABLE dbo.QuotationGroupInsurers (
        Id               UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_QuotationGroupInsurers PRIMARY KEY,
        QuotationGroupId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QuotationGroupInsurers_QuotationGroup REFERENCES dbo.QuotationGroups (Id),
        InsurerId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_QuotationGroupInsurers_Insurer REFERENCES dbo.Insurers (Id),
        CreatedAt        DATETIME2        NOT NULL,
        CreatedBy        NVARCHAR(100)    NOT NULL,
        UpdatedAt        DATETIME2        NULL,
        UpdatedBy        NVARCHAR(100)    NULL
    );

    -- Uma Seguradora aparece uma única vez por Grupo de Cotação.
    CREATE UNIQUE INDEX UX_QuotationGroupInsurers_GroupInsurer
        ON dbo.QuotationGroupInsurers (QuotationGroupId, InsurerId);

    CREATE INDEX IX_QuotationGroupInsurers_InsurerId
        ON dbo.QuotationGroupInsurers (InsurerId);
END
