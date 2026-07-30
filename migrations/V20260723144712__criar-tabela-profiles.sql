-- RN-032 (regras-de-negocio/perfis-e-permissoes.md): Perfil como entidade (antes era o enum EUserProfile).
-- Espelha o mapping EF ProfileMapping. Scope: System/Brokerage/PolicyHolder (nome estável, ADR-031 string).
-- IsFixed marca os Perfis fixos da plataforma (SystemAdministrator). BrokerageId/PolicyHolderId
-- nascem nullable e sem FK nesta fatia (exec-plan 0008) — os vínculos entram na fatia 1.
IF OBJECT_ID(N'dbo.Profiles', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Profiles
    (
        Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Profiles PRIMARY KEY,
        Name            NVARCHAR(100)    NOT NULL,
        Scope           NVARCHAR(20)     NOT NULL,
        IsFixed         BIT              NOT NULL,
        BrokerageId     UNIQUEIDENTIFIER NULL,
        PolicyHolderId  UNIQUEIDENTIFIER NULL,
        CreatedAt       DATETIME2        NOT NULL,
        CreatedBy       NVARCHAR(100)    NOT NULL,
        UpdatedAt       DATETIME2        NULL,
        UpdatedBy       NVARCHAR(100)    NULL
    );

    -- RN-039/RN-040: nome de Perfil único por escopo; nesta fatia só há escopo System, unique global basta.
    CREATE UNIQUE INDEX IX_Profiles_Name ON dbo.Profiles (Name);
    CREATE INDEX IX_Profiles_Scope ON dbo.Profiles (Scope);
END
