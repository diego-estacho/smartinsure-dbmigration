-- RN-503 (regras-de-negocio/emissao.md): Endereço do Segurado da oferta — réplica, feita no Grupo de
-- Cotação, do endereço do Segurado escolhido pelo corretor. É esta cópia que abastece a emissão, para
-- que alteração posterior no cadastro da Pessoa não mude sozinha o que foi combinado na oferta.
-- Uma réplica por oferta (índice único em QuotationGroupId). Tamanhos espelham dbo.PersonAddresses —
-- é cópia dos mesmos campos. Espelha o mapping QuotationAddressMapping 1:1.
IF OBJECT_ID(N'dbo.QuotationAddresses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.QuotationAddresses
    (
        Id               UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_QuotationAddresses PRIMARY KEY,
        QuotationGroupId UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_QuotationAddresses_QuotationGroups REFERENCES dbo.QuotationGroups (Id),
        ZipCode          NVARCHAR(8)      NULL,
        Street           NVARCHAR(200)    NULL,
        Number           NVARCHAR(20)     NULL,
        Complement       NVARCHAR(100)    NULL,
        Neighborhood     NVARCHAR(100)    NULL,
        City             NVARCHAR(100)    NULL,
        State            NVARCHAR(2)      NULL,
        CreatedAt        DATETIME2        NOT NULL,
        CreatedBy        NVARCHAR(100)    NOT NULL,
        UpdatedAt        DATETIME2        NULL,
        UpdatedBy        NVARCHAR(100)    NULL
    );

    CREATE UNIQUE INDEX UX_QuotationAddresses_QuotationGroupId
        ON dbo.QuotationAddresses (QuotationGroupId);
END
