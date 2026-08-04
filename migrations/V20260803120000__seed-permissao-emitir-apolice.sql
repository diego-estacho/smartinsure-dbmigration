-- RN-513 (regras-de-negocio/emissao.md): emitir Apólice exige Permissão própria, separada de criar e
-- editar o Grupo de Cotação — é o ato que gera obrigação financeira. Declara a Permissão no catálogo
-- fixo (mesma lista de PermissionCodes.All) e faz a concessão inicial: todo Perfil que já pode abrir
-- Grupo de Cotação passa a poder emitir. Quais Perfis efetivamente emitem é ajuste de configuração
-- pelo Administrador do Sistema (RN-073) e segue sob OPEN-03.
-- IsSystem = 1: Permissão fixa em código. Idempotente por Code e pelo par Perfil×Permissão.
DECLARE @permissionId UNIQUEIDENTIFIER = N'D0000000-0000-7000-8000-00000000001C';
DECLARE @issueCode NVARCHAR(100) = N'policies.issue';
DECLARE @sourceCode NVARCHAR(100) = N'quotation-groups.create';

IF NOT EXISTS (SELECT 1 FROM dbo.Permissions WHERE Code = @issueCode)
BEGIN
    INSERT INTO dbo.Permissions (Id, Code, Description, IsSystem, CreatedAt, CreatedBy)
    VALUES (@permissionId, @issueCode, N'Solicitar a emissão da Apólice', 1, SYSUTCDATETIME(), N'sqlcmd-seed');
END

INSERT INTO dbo.ProfilePermissions (Id, ProfileId, PermissionId, CreatedAt, CreatedBy)
SELECT NEWID(), source.ProfileId, target.Id, SYSUTCDATETIME(), N'sqlcmd-seed'
FROM dbo.ProfilePermissions source
     INNER JOIN dbo.Permissions sourcePermission
         ON sourcePermission.Id = source.PermissionId
        AND sourcePermission.Code = @sourceCode
     CROSS JOIN dbo.Permissions target
WHERE target.Code = @issueCode
  AND NOT EXISTS (SELECT 1
                  FROM dbo.ProfilePermissions granted
                  WHERE granted.ProfileId = source.ProfileId
                    AND granted.PermissionId = target.Id);
