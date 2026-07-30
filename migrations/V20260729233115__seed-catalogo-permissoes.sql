-- RN-063 (regras-de-negocio/perfis-e-permissoes.md, seção "Catálogo declarado — v1"): catálogo fixo de
-- Permissões, declarado pela plataforma a partir das funcionalidades que já existem. Ninguém cria
-- Permissão por tela; o seed apenas declara — a marcação em cada Perfil é decisão do Administrador
-- do Sistema (RN-073). Funcionalidade ainda não construída (Apólices, Relatórios, Configurações)
-- não entra aqui: declara sua Permissão quando nascer.
-- IsSystem = 1: Permissão fixa em código (todas nesta v1).
-- Idempotente por Code (chave natural, índice único); GUIDs estáveis para reaplicação segura.
DECLARE @catalog TABLE
(
    Id          UNIQUEIDENTIFIER NOT NULL,
    Code        NVARCHAR(100)    NOT NULL,
    Description NVARCHAR(500)    NOT NULL
);

INSERT INTO @catalog (Id, Code, Description)
VALUES
    (N'D0000000-0000-7000-8000-000000000001', N'quotation-groups.view',           N'Consultar Ofertas e Grupos de Cotação'),
    (N'D0000000-0000-7000-8000-000000000002', N'quotation-groups.create',         N'Abrir nova Oferta/Grupo de Cotação'),
    (N'D0000000-0000-7000-8000-000000000003', N'quotation-groups.edit',           N'Editar Oferta/Grupo de Cotação'),
    (N'D0000000-0000-7000-8000-000000000004', N'credit-inquiries.view',           N'Consultar Consultas de Crédito'),
    (N'D0000000-0000-7000-8000-000000000005', N'credit-inquiries.create',         N'Solicitar Consulta de Crédito'),
    (N'D0000000-0000-7000-8000-000000000006', N'policy-holders.view',             N'Consultar Tomadores'),
    (N'D0000000-0000-7000-8000-000000000007', N'policy-holders.create',           N'Cadastrar Tomador'),
    (N'D0000000-0000-7000-8000-000000000008', N'policy-holders.edit',             N'Editar Tomador'),
    (N'D0000000-0000-7000-8000-000000000009', N'policy-holder-appointments.manage', N'Criar e encerrar Nomeação de Tomador'),
    (N'D0000000-0000-7000-8000-00000000000A', N'brokerages.view',                 N'Consultar Corretoras'),
    (N'D0000000-0000-7000-8000-00000000000B', N'brokerages.create',               N'Cadastrar Corretora'),
    (N'D0000000-0000-7000-8000-00000000000C', N'brokerages.edit',                 N'Editar Corretora'),
    (N'D0000000-0000-7000-8000-00000000000D', N'brokerages.change-status',        N'Ativar e inativar Corretora'),
    (N'D0000000-0000-7000-8000-00000000000E', N'insurer-enablements.manage',      N'Manter Habilitação de Seguradora por Corretora'),
    (N'D0000000-0000-7000-8000-00000000000F', N'insurers.view',                   N'Consultar o catálogo de Seguradoras'),
    (N'D0000000-0000-7000-8000-000000000010', N'modalities.view',                 N'Consultar Modalidades'),
    (N'D0000000-0000-7000-8000-000000000011', N'modalities.edit',                 N'Editar Modalidade'),
    (N'D0000000-0000-7000-8000-000000000012', N'modality-map.manage',             N'Manter o Mapa de Modalidades'),
    (N'D0000000-0000-7000-8000-000000000013', N'additional-coverages.view',       N'Consultar Coberturas Adicionais'),
    (N'D0000000-0000-7000-8000-000000000014', N'additional-coverages.edit',       N'Editar Cobertura Adicional'),
    (N'D0000000-0000-7000-8000-000000000015', N'additional-coverage-map.manage',  N'Manter o Mapa de Coberturas Adicionais'),
    (N'D0000000-0000-7000-8000-000000000016', N'imports.run',                     N'Disparar importação de Modalidades e Coberturas'),
    (N'D0000000-0000-7000-8000-000000000017', N'users.view',                      N'Consultar Usuários'),
    (N'D0000000-0000-7000-8000-000000000018', N'users.create',                    N'Criar e convidar Usuário'),
    (N'D0000000-0000-7000-8000-000000000019', N'users.change-activation',         N'Inativar e reativar Usuário'),
    (N'D0000000-0000-7000-8000-00000000001A', N'profiles.view',                   N'Consultar Perfis de acesso'),
    (N'D0000000-0000-7000-8000-00000000001B', N'profiles.manage',                 N'Criar, editar e remover Perfis de acesso');

INSERT INTO dbo.Permissions (Id, Code, Description, IsSystem, CreatedAt, CreatedBy)
SELECT c.Id, c.Code, c.Description, 1, SYSUTCDATETIME(), N'flyway-seed'
FROM @catalog c
WHERE NOT EXISTS (SELECT 1 FROM dbo.Permissions p WHERE p.Code = c.Code);
