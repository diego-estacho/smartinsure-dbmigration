-- RN-204 (regras-de-negocio/usuarios.md): último acesso do Usuário — instante do último login
-- concluído (RN-005). Coluna NULLABLE: Usuários que nunca acessaram (ou anteriores à regra) ficam NULL.
SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.Users', N'LastAccessAtUtc') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD LastAccessAtUtc DATETIME2 NULL;
END
