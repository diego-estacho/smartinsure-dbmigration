-- RN-013/RN-014/RN-016 (regras-de-negocio/pessoas.md): Pessoa única por CNPJ,
-- importada do Birô com endereço principal. Espelha os mappings EF PersonMapping e
-- PersonAddressMapping do backend (mesma janela de release).
IF OBJECT_ID(N'dbo.Persons', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Persons
    (
        Id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Persons PRIMARY KEY,
        Cnpj           NVARCHAR(14)     NOT NULL,
        CorporateName  NVARCHAR(200)    NOT NULL,
        TradeName      NVARCHAR(200)    NULL,
        LegalNatureId  UNIQUEIDENTIFIER NOT NULL,
        CreatedAt      DATETIME2        NOT NULL,
        CreatedBy      NVARCHAR(100)    NOT NULL,
        UpdatedAt      DATETIME2        NULL,
        UpdatedBy      NVARCHAR(100)    NULL,

        CONSTRAINT FK_Persons_LegalNatures FOREIGN KEY (LegalNatureId)
            REFERENCES dbo.LegalNatures (Id)
    );

    -- RN-013/RN-014: uma Pessoa Jurídica por CNPJ.
    CREATE UNIQUE INDEX IX_Persons_Cnpj ON dbo.Persons (Cnpj);

    -- RN-013: busca por "contém" em razão social e nome fantasia.
    CREATE INDEX IX_Persons_CorporateName ON dbo.Persons (CorporateName);
END

IF OBJECT_ID(N'dbo.PersonAddresses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PersonAddresses
    (
        Id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_PersonAddresses PRIMARY KEY,
        PersonId  UNIQUEIDENTIFIER NOT NULL,
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

        CONSTRAINT FK_PersonAddresses_Persons FOREIGN KEY (PersonId)
            REFERENCES dbo.Persons (Id)
    );

    CREATE INDEX IX_PersonAddresses_PersonId ON dbo.PersonAddresses (PersonId);
END
