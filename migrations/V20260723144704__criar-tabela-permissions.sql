-- RN-033 (regras-de-negocio/perfis-e-permissoes.md): catálogo de Permissões.
-- Espelha o mapping EF PermissionMapping do backend (mesma janela de release).
-- Code único; IsSystem marca a Permissão declarada em código (catálogo fixo).
-- Nesta fatia (exec-plan 0008) a tabela nasce vazia — códigos e enforcement entram na fatia de enforcement.
IF OBJECT_ID(N'dbo.Permissions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Permissions
    (
        Id           UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Permissions PRIMARY KEY,
        Code         NVARCHAR(100)    NOT NULL,
        Description  NVARCHAR(500)    NULL,
        IsSystem     BIT              NOT NULL,
        CreatedAt    DATETIME2        NOT NULL,
        CreatedBy    NVARCHAR(100)    NOT NULL,
        UpdatedAt    DATETIME2        NULL,
        UpdatedBy    NVARCHAR(100)    NULL
    );

    CREATE UNIQUE INDEX IX_Permissions_Code ON dbo.Permissions (Code);
END
