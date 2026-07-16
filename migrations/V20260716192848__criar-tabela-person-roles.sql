-- RN-017 (regras-de-negocio/pessoas.md): vínculo N:N entre Pessoa e papel
-- (Insured/Broker/PolicyHolder). Uma Pessoa acumula papéis; vínculo nunca duplica.
-- Espelha o mapping EF PersonRoleMapping do backend (mesma janela de release).
IF OBJECT_ID(N'dbo.PersonRoles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PersonRoles
    (
        Id         UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_PersonRoles PRIMARY KEY,
        PersonId   UNIQUEIDENTIFIER NOT NULL,
        Role       NVARCHAR(20)     NOT NULL,
        CreatedAt  DATETIME2        NOT NULL,
        CreatedBy  NVARCHAR(100)    NOT NULL,
        UpdatedAt  DATETIME2        NULL,
        UpdatedBy  NVARCHAR(100)    NULL,

        CONSTRAINT FK_PersonRoles_Persons FOREIGN KEY (PersonId)
            REFERENCES dbo.Persons (Id)
    );

    -- RN-017: um vínculo por papel por Pessoa.
    CREATE UNIQUE INDEX UX_PersonRoles_PersonId_Role ON dbo.PersonRoles (PersonId, Role);
END
