-- RN-034 (regras-de-negocio/modalidades.md): marcador "Ignorada" da Modalidade Importada.
-- Item ignorado na Fila de Revisão não é oferecido e não volta à fila nas próximas importações
-- (a importação não altera este marcador). ADR-058: artefatos em inglês.

IF OBJECT_ID(N'dbo.ImportedModalities', N'U') IS NOT NULL
    AND COL_LENGTH(N'dbo.ImportedModalities', N'IsIgnored') IS NULL
BEGIN
    ALTER TABLE dbo.ImportedModalities
        ADD IsIgnored BIT NOT NULL CONSTRAINT DF_ImportedModalities_IsIgnored DEFAULT 0;
END
