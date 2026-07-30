-- TD-008 / RN-069 / RN-070: o nome do Perfil é único **por Escopo**, não globalmente.
-- Até aqui só existiam Perfis fixos globais, então `IX_Profiles_Name` único global bastava.
-- Com Perfis customizados por Corretora e por Tomador, duas Corretoras podem ter "Operador".
-- Substitui o índice global por três índices únicos filtrados, um por tipo de Escopo:
--   System        → nome único entre os Perfis de Sistema
--   Brokerage     → nome único dentro da mesma Corretora (e entre os globais de Corretora)
--   PolicyHolder  → nome único dentro do mesmo Tomador (e entre os globais de Tomador)
-- Perfil global de Escopo Corretora/Tomador tem dono NULL: cai no índice do próprio tipo, com
-- BrokerageId/PolicyHolderId como coluna do índice — dois globais não repetem nome.
-- Nota de operação: índice FILTRADO exige QUOTED_IDENTIFIER ON. O driver JDBC usado pelo Flyway
-- já conecta com essa opção ligada, então o CI aplica sem ajuste. Aplicação manual por sqlcmd
-- precisa do flag `-I` — sem ele o CREATE falha com "SET options have incorrect settings".
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Profiles_Name' AND object_id = OBJECT_ID(N'dbo.Profiles'))
BEGIN
    DROP INDEX IX_Profiles_Name ON dbo.Profiles;
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Profiles_Name_System' AND object_id = OBJECT_ID(N'dbo.Profiles'))
BEGIN
    CREATE UNIQUE INDEX IX_Profiles_Name_System
        ON dbo.Profiles (Name)
        WHERE Scope = N'System';
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Profiles_Name_Brokerage' AND object_id = OBJECT_ID(N'dbo.Profiles'))
BEGIN
    CREATE UNIQUE INDEX IX_Profiles_Name_Brokerage
        ON dbo.Profiles (BrokerageId, Name)
        WHERE Scope = N'Brokerage';
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Profiles_Name_PolicyHolder' AND object_id = OBJECT_ID(N'dbo.Profiles'))
BEGIN
    CREATE UNIQUE INDEX IX_Profiles_Name_PolicyHolder
        ON dbo.Profiles (PolicyHolderId, Name)
        WHERE Scope = N'PolicyHolder';
END
