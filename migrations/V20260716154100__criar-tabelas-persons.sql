-- RN-013/RN-014/RN-016 (regras-de-negocio/pessoas.md): Pessoa (física ou jurídica) única
-- por documento (CPF/CNPJ), importada do Birô com endereço principal quando jurídica.
-- Espelha os mappings EF PersonMapping e PersonAddressMapping do backend (mesma janela de release).
IF OBJECT_ID(N'dbo.Persons', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Persons
    (
        Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Persons PRIMARY KEY,
        DocumentNumber  NVARCHAR(14)     NOT NULL,
        Name            NVARCHAR(200)    NOT NULL,
        SocialName      NVARCHAR(200)    NULL,
        Type            NVARCHAR(1)      NOT NULL,
        LegalNatureId   UNIQUEIDENTIFIER NULL,
        CreatedAt       DATETIME2        NOT NULL,
        CreatedBy       NVARCHAR(100)    NOT NULL,
        UpdatedAt       DATETIME2        NULL,
        UpdatedBy       NVARCHAR(100)    NULL,

        -- RN-015: Natureza Jurídica só existe para pessoa jurídica (nula na física).
        CONSTRAINT FK_Persons_LegalNatures FOREIGN KEY (LegalNatureId)
            REFERENCES dbo.LegalNatures (Id)
    );

    -- RN-013/RN-014: uma Pessoa por documento (CPF/CNPJ).
    CREATE UNIQUE INDEX IX_Persons_DocumentNumber ON dbo.Persons (DocumentNumber);

    -- RN-013: busca por "contém" no nome e no nome social.
    CREATE INDEX IX_Persons_Name ON dbo.Persons (Name);
END

IF OBJECT_ID(N'dbo.PersonAddresses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PersonAddresses
    (
        Id             UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_PersonAddresses PRIMARY KEY,
        PersonId       UNIQUEIDENTIFIER NOT NULL,
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

    -- RN-014: no máximo um endereço principal por Pessoa.
    CREATE UNIQUE INDEX UX_PersonAddresses_MainAddress
        ON dbo.PersonAddresses (PersonId)
        WHERE IsMain = 1;
END
