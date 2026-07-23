-- RN-032/RN-033 (regras-de-negocio/perfis-e-permissoes.md): vínculo N:N entre Perfil e Permissão.
-- Espelha o mapping EF ProfilePermissionMapping. FKs Restrict (ADR-034); par único.
IF OBJECT_ID(N'dbo.ProfilePermissions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProfilePermissions
    (
        Id            UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_ProfilePermissions PRIMARY KEY,
        ProfileId     UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_ProfilePermissions_Profiles REFERENCES dbo.Profiles (Id),
        PermissionId  UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_ProfilePermissions_Permissions REFERENCES dbo.Permissions (Id),
        CreatedAt     DATETIME2        NOT NULL,
        CreatedBy     NVARCHAR(100)    NOT NULL,
        UpdatedAt     DATETIME2        NULL,
        UpdatedBy     NVARCHAR(100)    NULL
    );

    CREATE UNIQUE INDEX UX_ProfilePermissions_Pair ON dbo.ProfilePermissions (ProfileId, PermissionId);
    CREATE INDEX IX_ProfilePermissions_ProfileId ON dbo.ProfilePermissions (ProfileId);
    CREATE INDEX IX_ProfilePermissions_PermissionId ON dbo.ProfilePermissions (PermissionId);
END
