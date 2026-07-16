-- RN-010 (regras-de-negocio/usuarios.md): Perfil opcional do Usuário; NULL = usuário comum.
-- O primeiro Administrador do Sistema nasce por operação interna (runbook no exec-plan 0003),
-- nunca por migration — dado de ambiente não entra em migration imutável.
IF COL_LENGTH(N'dbo.Users', N'Profile') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD Profile NVARCHAR(30) NULL;
END
