-- RN-005..RN-008 (regras-de-negocio/seguradoras.md): tabela Insurers (ADR-058: artefatos em inglês).
-- Espelha o mapping EF InsurerMapping do backend (mesma janela de release); CNPJ único (RN-005).
IF OBJECT_ID(N'dbo.Insurers', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Insurers
    (
        Id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Insurers PRIMARY KEY,
        Cnpj          NVARCHAR(14)     NOT NULL,
        CorporateName NVARCHAR(200)    NOT NULL,
        TradeName     NVARCHAR(200)    NULL,
        LogoUrl       NVARCHAR(500)    NULL,
        Status        NVARCHAR(20)     NOT NULL,
        CreatedAt     DATETIME2        NOT NULL,
        CreatedBy     NVARCHAR(100)    NOT NULL,
        UpdatedAt     DATETIME2        NULL,
        UpdatedBy     NVARCHAR(100)    NULL
    );

    CREATE UNIQUE INDEX IX_Insurers_Cnpj ON dbo.Insurers (Cnpj);
END
