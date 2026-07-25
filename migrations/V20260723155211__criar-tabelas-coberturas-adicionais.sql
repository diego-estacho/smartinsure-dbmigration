-- RN-040/RN-041/RN-043/RN-044 (regras-de-negocio/coberturas-adicionais.md): Coberturas Adicionais.
-- AdditionalCoverages: o catálogo canônico do Smart (curado pelo Administrador, nome único, RN-040).
-- ImportedAdditionalCoverages: a versão de cada Seguradora (por Modalidade Importada), trazida por
-- importação e vinculada manualmente à canônica (RN-043); sem vínculo fica pendente de mapeamento.
-- ADR-058: artefatos em inglês; espelha os mappings EF. Nada é excluído; sai por Inativação (RN-044).

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.AdditionalCoverages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdditionalCoverages
    (
        Id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_AdditionalCoverages PRIMARY KEY,
        Name       NVARCHAR(300)    NOT NULL,
        Status     NVARCHAR(20)     NOT NULL,
        CreatedAt  DATETIME2        NOT NULL,
        CreatedBy  NVARCHAR(100)    NOT NULL,
        UpdatedAt  DATETIME2        NULL,
        UpdatedBy  NVARCHAR(100)    NULL
    );

    -- RN-040: nome canônico único no catálogo.
    CREATE UNIQUE INDEX UX_AdditionalCoverages_Name ON dbo.AdditionalCoverages (Name);
END

IF OBJECT_ID(N'dbo.ImportedAdditionalCoverages', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ImportedAdditionalCoverages
    (
        Id                           UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ImportedAdditionalCoverages PRIMARY KEY,
        ImportedModalityId           UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_ImportedAdditionalCoverages_ImportedModalities REFERENCES dbo.ImportedModalities (Id),
        Name                         NVARCHAR(300)    NOT NULL,
        SourceUniqueId               NVARCHAR(100)    NULL,
        InsuredAmountCalculationType INT              NOT NULL,
        AllowManualEdit              BIT              NOT NULL,
        AdditionalCoverageId         UNIQUEIDENTIFIER NULL CONSTRAINT FK_ImportedAdditionalCoverages_AdditionalCoverages REFERENCES dbo.AdditionalCoverages (Id),
        IsIgnored                    BIT              NOT NULL,
        Status                       NVARCHAR(20)     NOT NULL,
        LastImportedAt               DATETIME2        NOT NULL,
        CreatedAt                    DATETIME2        NOT NULL,
        CreatedBy                    NVARCHAR(100)    NOT NULL,
        UpdatedAt                    DATETIME2        NULL,
        UpdatedBy                    NVARCHAR(100)    NULL
    );

    -- RN-041: identidade e reencontro do upsert por (Modalidade Importada, nome).
    CREATE UNIQUE INDEX UX_ImportedAdditionalCoverages_ImportedModalityId_Name ON dbo.ImportedAdditionalCoverages (ImportedModalityId, Name);
    -- RN-043: consulta por vínculo (Fila de pendências e matriz de curadoria).
    CREATE INDEX IX_ImportedAdditionalCoverages_AdditionalCoverageId ON dbo.ImportedAdditionalCoverages (AdditionalCoverageId);
    CREATE INDEX IX_ImportedAdditionalCoverages_ImportedModalityId ON dbo.ImportedAdditionalCoverages (ImportedModalityId);
END
