-- RN-013/RN-014/RN-016 (regras-de-negocio/pessoas.md): Pessoa Jurídica única por CNPJ,
-- importada do Birô com endereço principal. Espelha os mappings EF LegalEntityMapping e
-- LegalEntityAddressMapping do backend (mesma janela de release).
IF OBJECT_ID(N'dbo.LegalEntities', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LegalEntities
    (
        Id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_LegalEntities PRIMARY KEY,
        Cnpj           NVARCHAR(14)     NOT NULL,
        CorporateName  NVARCHAR(200)    NOT NULL,
        TradeName      NVARCHAR(200)    NULL,
        LegalNatureId  UNIQUEIDENTIFIER NOT NULL,
        CreatedAt      DATETIME2        NOT NULL,
        CreatedBy      NVARCHAR(100)    NOT NULL,
        UpdatedAt      DATETIME2        NULL,
        UpdatedBy      NVARCHAR(100)    NULL,

        CONSTRAINT FK_LegalEntities_LegalNatures FOREIGN KEY (LegalNatureId)
            REFERENCES dbo.LegalNatures (Id)
    );

    -- RN-013/RN-014: uma Pessoa Jurídica por CNPJ.
    CREATE UNIQUE INDEX IX_LegalEntities_Cnpj ON dbo.LegalEntities (Cnpj);

    -- RN-013: busca por "contém" em razão social e nome fantasia.
    CREATE INDEX IX_LegalEntities_CorporateName ON dbo.LegalEntities (CorporateName);
END

IF OBJECT_ID(N'dbo.LegalEntityAddresses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LegalEntityAddresses
    (
        Id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_LegalEntityAddresses PRIMARY KEY,
        LegalEntityId  UNIQUEIDENTIFIER NOT NULL,
        ZipCode        NVARCHAR(8)      NULL,
        Street         NVARCHAR(200)    NULL,
        Number         NVARCHAR(20)     NULL,
        Complement     NVARCHAR(200)    NULL,
        Neighborhood   NVARCHAR(100)    NULL,
        City           NVARCHAR(100)    NULL,
        State          NVARCHAR(2)      NULL,
        IsMain         BIT              NOT NULL,
        CreatedAt      DATETIME2        NOT NULL,
        CreatedBy      NVARCHAR(100)    NOT NULL,
        UpdatedAt      DATETIME2        NULL,
        UpdatedBy      NVARCHAR(100)    NULL,

        CONSTRAINT FK_LegalEntityAddresses_LegalEntities FOREIGN KEY (LegalEntityId)
            REFERENCES dbo.LegalEntities (Id)
    );

    CREATE INDEX IX_LegalEntityAddresses_LegalEntityId ON dbo.LegalEntityAddresses (LegalEntityId);
END
