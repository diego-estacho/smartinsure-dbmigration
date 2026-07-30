-- RN-034 (regras-de-negocio/perfis-e-permissoes.md): vínculo do Usuário com uma Corretora,
-- portador do Perfil do Usuário naquela Corretora. Um Usuário pode ter vários (N por Usuário).
-- Corretora é uma Person com papel Broker (mesmo padrão de FK do PolicyHolderAppointment).
-- Espelha o mapping EF UserBrokerageMembershipMapping. FKs Restrict (ADR-034); par único.
IF OBJECT_ID(N'dbo.UserBrokerageMemberships', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.UserBrokerageMemberships
    (
        Id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_UserBrokerageMemberships PRIMARY KEY,
        UserId       UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_UserBrokerageMemberships_Users REFERENCES dbo.Users (Id),
        BrokerageId  UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_UserBrokerageMemberships_Persons REFERENCES dbo.Persons (Id),
        ProfileId    UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_UserBrokerageMemberships_Profiles REFERENCES dbo.Profiles (Id),
        CreatedAt    DATETIME2        NOT NULL,
        CreatedBy    NVARCHAR(100)    NOT NULL,
        UpdatedAt    DATETIME2        NULL,
        UpdatedBy    NVARCHAR(100)    NULL
    );

    -- RN-034: no máximo um vínculo (um Perfil) por Usuário × Corretora.
    CREATE UNIQUE INDEX UX_UserBrokerageMemberships_Pair
        ON dbo.UserBrokerageMemberships (UserId, BrokerageId);
    CREATE INDEX IX_UserBrokerageMemberships_UserId ON dbo.UserBrokerageMemberships (UserId);
    CREATE INDEX IX_UserBrokerageMemberships_BrokerageId ON dbo.UserBrokerageMemberships (BrokerageId);
    CREATE INDEX IX_UserBrokerageMemberships_ProfileId ON dbo.UserBrokerageMemberships (ProfileId);
END
