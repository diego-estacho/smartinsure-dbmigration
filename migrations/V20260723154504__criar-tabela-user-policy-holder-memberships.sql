-- RN-034 (regras-de-negocio/perfis-e-permissoes.md): vínculo do Usuário com um Tomador,
-- portador do Perfil do Usuário naquele Tomador. Um Usuário pode ter vários (N por Usuário).
-- Tomador é uma Person com papel PolicyHolder (mesmo padrão de FK do PolicyHolderAppointment).
-- Espelha o mapping EF UserPolicyHolderMembershipMapping. FKs Restrict (ADR-034); par único.
IF OBJECT_ID(N'dbo.UserPolicyHolderMemberships', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserPolicyHolderMemberships
    (
        Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UserPolicyHolderMemberships PRIMARY KEY,
        UserId          UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_UserPolicyHolderMemberships_Users REFERENCES dbo.Users (Id),
        PolicyHolderId  UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_UserPolicyHolderMemberships_Persons REFERENCES dbo.Persons (Id),
        ProfileId       UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_UserPolicyHolderMemberships_Profiles REFERENCES dbo.Profiles (Id),
        CreatedAt       DATETIME2        NOT NULL,
        CreatedBy       NVARCHAR(100)    NOT NULL,
        UpdatedAt       DATETIME2        NULL,
        UpdatedBy       NVARCHAR(100)    NULL
    );

    -- RN-034: no máximo um vínculo (um Perfil) por Usuário × Tomador.
    CREATE UNIQUE INDEX UX_UserPolicyHolderMemberships_Pair
        ON dbo.UserPolicyHolderMemberships (UserId, PolicyHolderId);
    CREATE INDEX IX_UserPolicyHolderMemberships_UserId ON dbo.UserPolicyHolderMemberships (UserId);
    CREATE INDEX IX_UserPolicyHolderMemberships_PolicyHolderId
        ON dbo.UserPolicyHolderMemberships (PolicyHolderId);
    CREATE INDEX IX_UserPolicyHolderMemberships_ProfileId
        ON dbo.UserPolicyHolderMemberships (ProfileId);
END
