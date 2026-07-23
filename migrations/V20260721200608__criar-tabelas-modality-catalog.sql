-- RN-029/RN-036 (regras-de-negocio/modalidades.md): catálogo curado de Modalidades — lado Smart.
-- Tabelas ModalityGroups (Grupo de Modalidade) e Modalities (Modalidade), ADR-058: artefatos em inglês.
-- Espelha os mappings EF ModalityGroupMapping/ModalityMapping do backend (mesma janela de release).
-- Curado, não descoberto (ADR-060): a importação NUNCA cria estes itens. Nada é excluído (RN-036).

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.ModalityGroups', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ModalityGroups
    (
        Id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ModalityGroups PRIMARY KEY,
        Name         NVARCHAR(200)    NOT NULL,
        Description  NVARCHAR(1000)   NULL,
        Status       NVARCHAR(20)     NOT NULL,
        DisplayOrder INT              NOT NULL,
        CreatedAt    DATETIME2        NOT NULL,
        CreatedBy    NVARCHAR(100)    NOT NULL,
        UpdatedAt    DATETIME2        NULL,
        UpdatedBy    NVARCHAR(100)    NULL
    );

    CREATE UNIQUE INDEX IX_ModalityGroups_Name ON dbo.ModalityGroups (Name);
END

IF OBJECT_ID(N'dbo.Modalities', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Modalities
    (
        Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Modalities PRIMARY KEY,
        Name            NVARCHAR(200)    NOT NULL,
        ModalityGroupId UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_Modalities_ModalityGroups REFERENCES dbo.ModalityGroups (Id),
        Description     NVARCHAR(1000)   NULL,
        Status          NVARCHAR(20)     NOT NULL,
        CreatedAt       DATETIME2        NOT NULL,
        CreatedBy       NVARCHAR(100)    NOT NULL,
        UpdatedAt       DATETIME2        NULL,
        UpdatedBy       NVARCHAR(100)    NULL
    );

    CREATE UNIQUE INDEX IX_Modalities_Name ON dbo.Modalities (Name);
    CREATE INDEX IX_Modalities_ModalityGroupId ON dbo.Modalities (ModalityGroupId);
END
