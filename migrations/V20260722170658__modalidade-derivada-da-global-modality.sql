-- RN-029/RN-032/RN-034/RN-036 (regras-de-negocio/modalidades.md): retrabalho do catálogo de
-- Modalidades para o modelo do ADR-061 (supersede o ADR-060). A Modalidade passa a ser derivada
-- da Modalidade Global da OnPoint (id global único) ou criada manualmente; o vínculo
-- Importada→Modalidade vira referência direta (com origem Automatic/Manual); some o Grupo de
-- Modalidade e a tabela de Mapeamento do lado Smart. ADR-058: artefatos em inglês. Forward-only,
-- guardado, imutável (ADRs 041–043). Espelha os mappings EF do backend.
-- Batches separados por GO: a coluna nova só é referenciável por índice/constraint no batch seguinte.

SET QUOTED_IDENTIFIER ON;
GO

-- (a) Modalities: id da Modalidade Global (único quando presente).
IF OBJECT_ID(N'dbo.Modalities', N'U') IS NOT NULL
    AND COL_LENGTH(N'dbo.Modalities', N'GlobalModalityExternalId') IS NULL
BEGIN
    ALTER TABLE dbo.Modalities ADD GlobalModalityExternalId NVARCHAR(100) NULL;
END
GO

IF OBJECT_ID(N'dbo.Modalities', N'U') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Modalities_GlobalModalityExternalId'
                    AND object_id = OBJECT_ID(N'dbo.Modalities'))
BEGIN
    -- RN-032: uma Modalidade derivada é única por id de Modalidade Global; manuais (NULL) não colidem.
    CREATE UNIQUE INDEX UX_Modalities_GlobalModalityExternalId
        ON dbo.Modalities (GlobalModalityExternalId)
        WHERE GlobalModalityExternalId IS NOT NULL;
END
GO

-- (b) ImportedModalities: vínculo direto com a Modalidade e origem do vínculo (RN-032/RN-034).
IF OBJECT_ID(N'dbo.ImportedModalities', N'U') IS NOT NULL
    AND COL_LENGTH(N'dbo.ImportedModalities', N'ModalityId') IS NULL
BEGIN
    ALTER TABLE dbo.ImportedModalities
        ADD ModalityId UNIQUEIDENTIFIER NULL
            CONSTRAINT FK_ImportedModalities_Modalities REFERENCES dbo.Modalities (Id);
END
GO

IF OBJECT_ID(N'dbo.ImportedModalities', N'U') IS NOT NULL
    AND COL_LENGTH(N'dbo.ImportedModalities', N'ModalityLinkSource') IS NULL
BEGIN
    ALTER TABLE dbo.ImportedModalities ADD ModalityLinkSource NVARCHAR(20) NULL;
END
GO

IF OBJECT_ID(N'dbo.ImportedModalities', N'U') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ImportedModalities_ModalityId'
                    AND object_id = OBJECT_ID(N'dbo.ImportedModalities'))
BEGIN
    CREATE INDEX IX_ImportedModalities_ModalityId ON dbo.ImportedModalities (ModalityId);
END
GO

-- (c) Remoção do Mapeamento próprio (ADR-061): o vínculo agora é intrínseco em ImportedModalities.
IF OBJECT_ID(N'dbo.ModalityMappings', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.ModalityMappings;
END
GO

-- (a cont.) Remoção do Grupo de Modalidade do lado Smart (ADR-061): índice, FK e coluna, depois a tabela.
IF OBJECT_ID(N'dbo.Modalities', N'U') IS NOT NULL
    AND EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Modalities_ModalityGroupId'
                AND object_id = OBJECT_ID(N'dbo.Modalities'))
BEGIN
    DROP INDEX IX_Modalities_ModalityGroupId ON dbo.Modalities;
END
GO

IF OBJECT_ID(N'dbo.FK_Modalities_ModalityGroups', N'F') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Modalities DROP CONSTRAINT FK_Modalities_ModalityGroups;
END
GO

IF OBJECT_ID(N'dbo.Modalities', N'U') IS NOT NULL
    AND COL_LENGTH(N'dbo.Modalities', N'ModalityGroupId') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Modalities DROP COLUMN ModalityGroupId;
END
GO

IF OBJECT_ID(N'dbo.ModalityGroups', N'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.ModalityGroups;
END
GO
