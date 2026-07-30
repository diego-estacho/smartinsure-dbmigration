-- RN-062/RN-072 (regras-de-negocio/perfis-e-permissoes.md): Perfis fixos globais Corretor e Tomador,
-- os dois que faltavam para fechar os cinco Perfis fixos da plataforma (Administrador do Sistema,
-- Corretor Administrador, Tomador Administrador, Corretor, Tomador).
-- Nomes técnicos BrokerageUser/PolicyHolderUser decididos pelo dono do produto em 2026-07-29
-- (OPEN-17): não colidem com o Papel da Pessoa Broker/PolicyHolder e mantêm a simetria com
-- BrokerageAdministrator/PolicyHolderAdministrator.
-- Fixos e GLOBAIS (BrokerageId/PolicyHolderId NULL): valem para todas as Corretoras/Tomadores.
-- GUIDs estáveis; o backend resolve por chave natural IsFixed+Scope+Name, nunca pelo GUID.
DECLARE @brokerageUserId UNIQUEIDENTIFIER = N'C0000000-0000-7000-8000-000000000004';
DECLARE @policyHolderUserId UNIQUEIDENTIFIER = N'C0000000-0000-7000-8000-000000000005';

IF NOT EXISTS (SELECT 1 FROM dbo.Profiles WHERE Id = @brokerageUserId)
BEGIN
    INSERT INTO dbo.Profiles (Id, Name, Scope, IsFixed, CreatedAt, CreatedBy)
    VALUES (@brokerageUserId, N'BrokerageUser', N'Brokerage', 1, SYSUTCDATETIME(), N'flyway-seed');
END

IF NOT EXISTS (SELECT 1 FROM dbo.Profiles WHERE Id = @policyHolderUserId)
BEGIN
    INSERT INTO dbo.Profiles (Id, Name, Scope, IsFixed, CreatedAt, CreatedBy)
    VALUES (@policyHolderUserId, N'PolicyHolderUser', N'PolicyHolder', 1, SYSUTCDATETIME(), N'flyway-seed');
END
