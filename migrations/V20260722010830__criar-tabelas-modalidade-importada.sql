-- RN-030/RN-031/RN-032/RN-035 (regras-de-negocio/modalidades.md): lado da fonte do catálogo.
-- ImportedGroups (Grupo Importado), ImportedModalities (Modalidade Importada) e ModalityMappings
-- (Mapeamento de Modalidade). ADR-058: artefatos em inglês. Espelha os mappings EF do backend.
-- Nada é excluído (RN-036); Importada some da operação por Inativação (RN-035).

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.ImportedGroups', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ImportedGroups
    (
        Id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ImportedGroups PRIMARY KEY,
        InsurerId  UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_ImportedGroups_Insurers REFERENCES dbo.Insurers (Id),
        SourceId   NVARCHAR(100)    NOT NULL,
        Name       NVARCHAR(200)    NOT NULL,
        Type       NVARCHAR(100)    NULL,
        CreatedAt  DATETIME2        NOT NULL,
        CreatedBy  NVARCHAR(100)    NOT NULL,
        UpdatedAt  DATETIME2        NULL,
        UpdatedBy  NVARCHAR(100)    NULL
    );

    -- RN-030: o Grupo Importado é reencontrado pelo identificador de origem, por Seguradora.
    CREATE UNIQUE INDEX UX_ImportedGroups_InsurerId_SourceId ON dbo.ImportedGroups (InsurerId, SourceId);
END

IF OBJECT_ID(N'dbo.ImportedModalities', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ImportedModalities
    (
        Id                  UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ImportedModalities PRIMARY KEY,
        InsurerId           UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_ImportedModalities_Insurers REFERENCES dbo.Insurers (Id),
        SourceId            NVARCHAR(100)    NOT NULL,
        OriginName          NVARCHAR(300)    NOT NULL,
        Branch              NVARCHAR(20)     NOT NULL,
        EngineModalityId    NVARCHAR(100)    NULL,
        EngineModalityName  NVARCHAR(300)    NULL,
        ImportedGroupId     UNIQUEIDENTIFIER NULL CONSTRAINT FK_ImportedModalities_ImportedGroups REFERENCES dbo.ImportedGroups (Id),
        CommercialParameters NVARCHAR(MAX)   NULL,
        Status              NVARCHAR(20)     NOT NULL,
        LastImportedAt      DATETIME2        NOT NULL,
        CreatedAt           DATETIME2        NOT NULL,
        CreatedBy           NVARCHAR(100)    NOT NULL,
        UpdatedAt           DATETIME2        NULL,
        UpdatedBy           NVARCHAR(100)    NULL
    );

    -- RN-030: reencontro pelo identificador de origem, por Seguradora.
    CREATE UNIQUE INDEX UX_ImportedModalities_InsurerId_SourceId ON dbo.ImportedModalities (InsurerId, SourceId);
    -- RN-032: mapeamento automático herdado pelo identificador do motor.
    CREATE INDEX IX_ImportedModalities_EngineModalityId ON dbo.ImportedModalities (EngineModalityId);
    CREATE INDEX IX_ImportedModalities_InsurerId ON dbo.ImportedModalities (InsurerId);
    CREATE INDEX IX_ImportedModalities_ImportedGroupId ON dbo.ImportedModalities (ImportedGroupId);
END

IF OBJECT_ID(N'dbo.ModalityMappings', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ModalityMappings
    (
        Id                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ModalityMappings PRIMARY KEY,
        ImportedModalityId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_ModalityMappings_ImportedModalities REFERENCES dbo.ImportedModalities (Id),
        ModalityId         UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_ModalityMappings_Modalities REFERENCES dbo.Modalities (Id),
        Establishment      NVARCHAR(20)     NOT NULL,
        Confidence         INT              NULL,
        Status             NVARCHAR(20)     NOT NULL,
        ConfirmedBy        NVARCHAR(100)    NULL,
        ConfirmedAt        DATETIME2        NULL,
        CreatedAt          DATETIME2        NOT NULL,
        CreatedBy          NVARCHAR(100)    NOT NULL,
        UpdatedAt          DATETIME2        NULL,
        UpdatedBy          NVARCHAR(100)    NULL
    );

    -- RN-032/RN-034: no máximo um mapeamento Confirmado por Modalidade Importada.
    CREATE UNIQUE INDEX UX_ModalityMappings_Confirmed
        ON dbo.ModalityMappings (ImportedModalityId)
        WHERE Status = 'Confirmed';

    CREATE INDEX IX_ModalityMappings_ImportedModalityId ON dbo.ModalityMappings (ImportedModalityId);
    CREATE INDEX IX_ModalityMappings_ModalityId ON dbo.ModalityMappings (ModalityId);
END
