-- Perfis de acesso (exec-plan 0019). Backfill de Área e DependsOn do catálogo de Permissões v1
-- (RN-063, revisão 2026-08-07). Chave natural = Code; UPDATE por Code é no-op quando a Permissão
-- não existe neste ambiente (ex.: policies.issue, semeado por outra frente). DependsOn NULL = leitura.
-- Seis áreas em v1: quotations, credit-inquiries, policy-holders, brokerages, catalog, users-access.
-- (imports.run -> insurers.view: dependência a confirmar com a PO.)

SET QUOTED_IDENTIFIER ON;

UPDATE dbo.Permissions SET Area = N'quotations',       DependsOn = NULL                          WHERE Code = N'quotation-groups.view';
UPDATE dbo.Permissions SET Area = N'quotations',       DependsOn = N'quotation-groups.view'      WHERE Code = N'quotation-groups.create';
UPDATE dbo.Permissions SET Area = N'quotations',       DependsOn = N'quotation-groups.view'      WHERE Code = N'quotation-groups.edit';
UPDATE dbo.Permissions SET Area = N'quotations',       DependsOn = N'quotation-groups.view'      WHERE Code = N'policies.issue';

UPDATE dbo.Permissions SET Area = N'credit-inquiries', DependsOn = NULL                          WHERE Code = N'credit-inquiries.view';
UPDATE dbo.Permissions SET Area = N'credit-inquiries', DependsOn = N'credit-inquiries.view'      WHERE Code = N'credit-inquiries.create';

UPDATE dbo.Permissions SET Area = N'policy-holders',   DependsOn = NULL                          WHERE Code = N'policy-holders.view';
UPDATE dbo.Permissions SET Area = N'policy-holders',   DependsOn = N'policy-holders.view'        WHERE Code = N'policy-holders.create';
UPDATE dbo.Permissions SET Area = N'policy-holders',   DependsOn = N'policy-holders.view'        WHERE Code = N'policy-holders.edit';
UPDATE dbo.Permissions SET Area = N'policy-holders',   DependsOn = N'policy-holders.view'        WHERE Code = N'policy-holder-appointments.manage';

UPDATE dbo.Permissions SET Area = N'brokerages',       DependsOn = NULL                          WHERE Code = N'brokerages.view';
UPDATE dbo.Permissions SET Area = N'brokerages',       DependsOn = N'brokerages.view'            WHERE Code = N'brokerages.create';
UPDATE dbo.Permissions SET Area = N'brokerages',       DependsOn = N'brokerages.view'            WHERE Code = N'brokerages.edit';
UPDATE dbo.Permissions SET Area = N'brokerages',       DependsOn = N'brokerages.view'            WHERE Code = N'brokerages.change-status';
UPDATE dbo.Permissions SET Area = N'brokerages',       DependsOn = N'brokerages.view'            WHERE Code = N'insurer-enablements.manage';

UPDATE dbo.Permissions SET Area = N'catalog',          DependsOn = NULL                          WHERE Code = N'insurers.view';
UPDATE dbo.Permissions SET Area = N'catalog',          DependsOn = NULL                          WHERE Code = N'modalities.view';
UPDATE dbo.Permissions SET Area = N'catalog',          DependsOn = N'modalities.view'            WHERE Code = N'modalities.edit';
UPDATE dbo.Permissions SET Area = N'catalog',          DependsOn = N'modalities.view'            WHERE Code = N'modality-map.manage';
UPDATE dbo.Permissions SET Area = N'catalog',          DependsOn = NULL                          WHERE Code = N'additional-coverages.view';
UPDATE dbo.Permissions SET Area = N'catalog',          DependsOn = N'additional-coverages.view'  WHERE Code = N'additional-coverages.edit';
UPDATE dbo.Permissions SET Area = N'catalog',          DependsOn = N'additional-coverages.view'  WHERE Code = N'additional-coverage-map.manage';
UPDATE dbo.Permissions SET Area = N'catalog',          DependsOn = N'insurers.view'              WHERE Code = N'imports.run';

UPDATE dbo.Permissions SET Area = N'users-access',     DependsOn = NULL                          WHERE Code = N'users.view';
UPDATE dbo.Permissions SET Area = N'users-access',     DependsOn = N'users.view'                 WHERE Code = N'users.create';
UPDATE dbo.Permissions SET Area = N'users-access',     DependsOn = N'users.view'                 WHERE Code = N'users.change-activation';
UPDATE dbo.Permissions SET Area = N'users-access',     DependsOn = NULL                          WHERE Code = N'profiles.view';
UPDATE dbo.Permissions SET Area = N'users-access',     DependsOn = N'profiles.view'              WHERE Code = N'profiles.manage';
