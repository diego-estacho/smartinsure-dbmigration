-- RN-032/RN-012 (regras-de-negocio/perfis-e-permissoes.md, usuarios.md): migração do Perfil de enum
-- (coluna Users.Profile string) para a entidade Profile (Users.ProfileId FK).
-- Passos (forward-only, com guards): 1) semear o Perfil fixo SystemAdministrator (dado de catálogo,
-- precedente LegalNatures — GUID estável, resolvido no backend por chave natural IsFixed+Scope+Name);
-- 2) adicionar Users.ProfileId + FK; 3) backfill dos Usuários que eram SystemAdministrator;
-- 4) remover a coluna Users.Profile antiga (dois padrões não convivem).
-- NÃO cria Usuário algum — o primeiro Administrador do Sistema segue nascendo por runbook (dado de ambiente).
DECLARE @systemAdministratorProfileId UNIQUEIDENTIFIER = N'B7E4C1A0-3F52-4D9E-9C77-000000000001';

-- 1) Perfil fixo SystemAdministrator (idempotente).
IF NOT EXISTS (SELECT 1 FROM dbo.Profiles WHERE Id = @systemAdministratorProfileId)
BEGIN
    INSERT INTO dbo.Profiles (Id, Name, Scope, IsFixed, CreatedAt, CreatedBy)
    VALUES (@systemAdministratorProfileId, N'SystemAdministrator', N'System', 1, SYSUTCDATETIME(), N'flyway-seed');
END

-- 2) Coluna ProfileId + FK Restrict.
IF COL_LENGTH(N'dbo.Users', N'ProfileId') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD ProfileId UNIQUEIDENTIFIER NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Users_Profiles')
BEGIN
    ALTER TABLE dbo.Users
        ADD CONSTRAINT FK_Users_Profiles FOREIGN KEY (ProfileId) REFERENCES dbo.Profiles (Id);
END

-- 3) Backfill: quem era SystemAdministrator (coluna antiga) passa a apontar para o Perfil fixo.
IF COL_LENGTH(N'dbo.Users', N'Profile') IS NOT NULL
BEGIN
    EXEC(N'UPDATE dbo.Users SET ProfileId = ''B7E4C1A0-3F52-4D9E-9C77-000000000001''
           WHERE Profile = N''SystemAdministrator'' AND ProfileId IS NULL;');
END

-- 4) Remover a coluna antiga Users.Profile.
IF COL_LENGTH(N'dbo.Users', N'Profile') IS NOT NULL
BEGIN
    ALTER TABLE dbo.Users DROP COLUMN Profile;
END
