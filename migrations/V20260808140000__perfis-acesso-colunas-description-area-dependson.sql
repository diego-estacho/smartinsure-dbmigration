-- Perfis de acesso (exec-plan 0019, AB# a definir).
-- RN-082: Descrição livre e opcional do Perfil (exibida na listagem e na seleção de Perfil do
--         Usuário; não participa de autorização nem de unicidade).
-- RN-063 (revisão 2026-08-07): cada Permissão do catálogo passa a declarar uma Área (agrupamento
--         por domínio) e, para ações de escrita, a Permissão de leitura de que depende (DependsOn).
-- Só as colunas aqui; o backfill do catálogo vem na migration seguinte (coluna precisa existir e
-- estar commitada antes do UPDATE que a referencia). Idempotente. Alinhar EF Profile/Permission mappings.

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.Profiles', N'Description') IS NULL
BEGIN
    ALTER TABLE dbo.Profiles ADD Description NVARCHAR(500) NULL;
END

IF COL_LENGTH(N'dbo.Permissions', N'Area') IS NULL
BEGIN
    ALTER TABLE dbo.Permissions ADD Area NVARCHAR(50) NULL;
END

IF COL_LENGTH(N'dbo.Permissions', N'DependsOn') IS NULL
BEGIN
    ALTER TABLE dbo.Permissions ADD DependsOn NVARCHAR(100) NULL;
END
