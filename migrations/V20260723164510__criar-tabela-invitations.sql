-- RN-035: Convite de primeiro acesso (token de uso único, 7 dias, reenviável).
-- Guarda apenas o HASH do token (segurança); o token plaintext viaja no link do e-mail.
-- Um convite ativo por Usuário (ConsumedAtUtc IS NULL); reenvio invalida o anterior.
SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.Invitations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Invitations
    (
        Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Invitations PRIMARY KEY,
        UserId          UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_Invitations_Users REFERENCES dbo.Users (Id),
        TokenHash       NVARCHAR(64)     NOT NULL,
        ExpiresAtUtc    DATETIME2        NOT NULL,
        ConsumedAtUtc   DATETIME2        NULL,
        CreatedAt       DATETIME2        NOT NULL,
        CreatedBy       NVARCHAR(100)    NOT NULL,
        UpdatedAt       DATETIME2        NULL,
        UpdatedBy       NVARCHAR(100)    NULL
    );

    -- RN-035: no máximo um convite ativo (não consumido) por Usuário.
    CREATE UNIQUE INDEX UX_Invitations_ActivePerUser
        ON dbo.Invitations (UserId)
        WHERE ConsumedAtUtc IS NULL;

    CREATE INDEX IX_Invitations_TokenHash ON dbo.Invitations (TokenHash);
    CREATE INDEX IX_Invitations_ExpiresAtUtc ON dbo.Invitations (ExpiresAtUtc);
END
