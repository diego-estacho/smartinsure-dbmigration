-- RN-001/RN-002 (regras-de-negocio/usuarios.md): tabela Users (ADR-058: artefatos em inglês).
-- Espelha o mapping EF UserMapping do backend (mesma janela de release);
-- e-mail e identidade externa únicos na plataforma (RN-001).
IF OBJECT_ID(N'dbo.Users', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Users
    (
        Id                UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
        Name              NVARCHAR(200)    NOT NULL,
        Email             NVARCHAR(320)    NOT NULL,
        ExternalIdentity  NVARCHAR(100)    NOT NULL,
        Status            NVARCHAR(20)     NOT NULL,
        CreatedAt         DATETIME2        NOT NULL,
        CreatedBy         NVARCHAR(100)    NOT NULL,
        UpdatedAt         DATETIME2        NULL,
        UpdatedBy         NVARCHAR(100)    NULL
    );

    CREATE UNIQUE INDEX IX_Users_Email ON dbo.Users (Email);
    CREATE UNIQUE INDEX IX_Users_ExternalIdentity ON dbo.Users (ExternalIdentity);
END
