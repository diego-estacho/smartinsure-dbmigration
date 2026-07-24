-- Tags e Cláusulas Particulares da Modalidade Importada (RN-040, RN-041) — AB#0004
IF OBJECT_ID(N'dbo.ImportedModalityTags', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ImportedModalityTags (
        Id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ImportedModalityTags PRIMARY KEY,
        ImportedModalityId UNIQUEIDENTIFIER NOT NULL,
        JsonTag NVARCHAR(MAX) NOT NULL,
        ObjectText NVARCHAR(MAX) NULL,
        Status NVARCHAR(20) NOT NULL,
        CreatedAt DATETIME2 NOT NULL,
        CreatedBy NVARCHAR(100) NOT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy NVARCHAR(100) NULL,
        CONSTRAINT FK_ImportedModalityTags_ImportedModalities
            FOREIGN KEY (ImportedModalityId) REFERENCES dbo.ImportedModalities (Id)
    );
    CREATE UNIQUE INDEX UX_ImportedModalityTags_ImportedModalityId
        ON dbo.ImportedModalityTags (ImportedModalityId);
END;

IF OBJECT_ID(N'dbo.ImportedModalityParticularClauses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ImportedModalityParticularClauses (
        Id UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ImportedModalityParticularClauses PRIMARY KEY,
        ImportedModalityId UNIQUEIDENTIFIER NOT NULL,
        ExternalId NVARCHAR(100) NOT NULL,
        Name NVARCHAR(300) NOT NULL,
        ClauseText NVARCHAR(MAX) NULL,
        JsonTag NVARCHAR(MAX) NULL,
        Status NVARCHAR(20) NOT NULL,
        CreatedAt DATETIME2 NOT NULL,
        CreatedBy NVARCHAR(100) NOT NULL,
        UpdatedAt DATETIME2 NULL,
        UpdatedBy NVARCHAR(100) NULL,
        CONSTRAINT FK_ImportedModalityParticularClauses_ImportedModalities
            FOREIGN KEY (ImportedModalityId) REFERENCES dbo.ImportedModalities (Id)
    );
    CREATE UNIQUE INDEX UX_ImportedModalityParticularClauses_Modality_External
        ON dbo.ImportedModalityParticularClauses (ImportedModalityId, ExternalId);
END;
