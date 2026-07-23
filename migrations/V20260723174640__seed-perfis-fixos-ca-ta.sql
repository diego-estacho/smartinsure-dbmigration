-- RN-032/RN-036 (regras-de-negocio/perfis-e-permissoes.md): Perfis fixos globais Corretor Administrador
-- e Tomador Administrador (dado de catálogo — precedente SystemAdministrator/LegalNatures; GUIDs estáveis,
-- resolvidos no backend por chave natural IsFixed+Scope+Name, nunca pelo GUID).
-- Fixos e GLOBAIS (BrokerageId/PolicyHolderId NULL): as permissões valem para todas as Corretoras/Tomadores (RN-043).
DECLARE @brokerageAdministratorId UNIQUEIDENTIFIER = N'C0000000-0000-7000-8000-000000000002';
DECLARE @policyHolderAdministratorId UNIQUEIDENTIFIER = N'C0000000-0000-7000-8000-000000000003';

IF NOT EXISTS (SELECT 1 FROM dbo.Profiles WHERE Id = @brokerageAdministratorId)
BEGIN
    INSERT INTO dbo.Profiles (Id, Name, Scope, IsFixed, CreatedAt, CreatedBy)
    VALUES (@brokerageAdministratorId, N'BrokerageAdministrator', N'Brokerage', 1, SYSUTCDATETIME(), N'flyway-seed');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Profiles WHERE Id = @policyHolderAdministratorId)
BEGIN
    INSERT INTO dbo.Profiles (Id, Name, Scope, IsFixed, CreatedAt, CreatedBy)
    VALUES (@policyHolderAdministratorId, N'PolicyHolderAdministrator', N'PolicyHolder', 1, SYSUTCDATETIME(), N'flyway-seed');
END
