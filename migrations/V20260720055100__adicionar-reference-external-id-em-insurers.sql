-- RN-008/RN-023 (regras-de-negocio/seguradoras.md, motor-de-calculo.md): identificador da
-- Seguradora no sistema de origem do Motor de Cálculo (ex.: InsuranceUniqueId no PlugV2).
-- Opcional e livre (NVARCHAR) — cada motor usa o formato do seu sistema de origem.
IF COL_LENGTH(N'dbo.Insurers', N'ReferenceExternalId') IS NULL
BEGIN
    ALTER TABLE dbo.Insurers
        ADD ReferenceExternalId NVARCHAR(100) NULL;
END
