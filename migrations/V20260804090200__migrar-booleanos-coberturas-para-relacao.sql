-- RN-104 (AB#0007) — converte os booleanos provisórios do Grupo de Cotação para a relação com a
-- Cobertura Adicional canônica e remove as colunas.
-- Depende de V20260804090100 (tabelas) e de V20260804090000 (nome da canônica corrigido).
--
-- DUAS ARMADILHAS TRATADAS AQUI:
--
-- 1) O catálogo canônico NÃO é semeado por migration — as Coberturas Adicionais canônicas nascem da
--    curadoria (RN-040), então "Multas" e "Trabalhista e Previdenciária" podem simplesmente não
--    existir no ambiente. Abortar nesse caso deixaria as colunas BIT NOT NULL sem DEFAULT numa base
--    cujo backend já não as preenche, quebrando a criação de Grupo de Cotação por inteiro. Portanto:
--    só há o que fazer quando existe Grupo com booleano marcado; se existir e a canônica faltar, ela
--    é semeada (guardada por nome) — perder a escolha do corretor é pior, e o schema é forward-only.
--
-- 2) O SQL Server resolve nome de COLUNA na compilação do batch, não em runtime: um
--    `IF COL_LENGTH(...) IS NOT NULL` NÃO protege DML que referencia a coluna (só protege
--    `ALTER TABLE ... DROP COLUMN`, que é resolvido depois). Todo o DML sobre as colunas antigas vai
--    dentro de `sp_executesql`, para o batch compilar mesmo quando as colunas já não existem —
--    o que acontece em qualquer reexecução após falha parcial (flyway repair + migrate).
--
-- NEWID() e não UUIDv7 porque estas linhas são criadas pela migração, não pela aplicação — o padrão
-- UUIDv7 (ADR-029) vale para o que a aplicação insere.

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.QuotationGroups', N'IncludesPenaltyCoverage') IS NOT NULL
   AND COL_LENGTH(N'dbo.QuotationGroups', N'IncludesLaborCoverage') IS NOT NULL
BEGIN
    EXEC sp_executesql N'
        DECLARE @temPenalty BIT = CASE WHEN EXISTS (
            SELECT 1 FROM dbo.QuotationGroups WHERE IncludesPenaltyCoverage = 1) THEN 1 ELSE 0 END;
        DECLARE @temLabor BIT = CASE WHEN EXISTS (
            SELECT 1 FROM dbo.QuotationGroups WHERE IncludesLaborCoverage = 1) THEN 1 ELSE 0 END;

        -- Nada marcado em nenhum Grupo: não há escolha a preservar e nada a semear.
        IF @temPenalty = 0 AND @temLabor = 0 RETURN;

        DECLARE @agora DATETIME2 = SYSUTCDATETIME();
        DECLARE @autor NVARCHAR(100) = N''migration-ab-0007'';

        IF @temPenalty = 1 AND NOT EXISTS (
            SELECT 1 FROM dbo.AdditionalCoverages WHERE Name = N''Multas'')
        BEGIN
            INSERT INTO dbo.AdditionalCoverages (Id, Name, Status, CreatedAt, CreatedBy)
            VALUES (NEWID(), N''Multas'', N''Active'', @agora, @autor);
        END

        IF @temLabor = 1 AND NOT EXISTS (
            SELECT 1 FROM dbo.AdditionalCoverages WHERE Name = N''Trabalhista e Previdenciária'')
        BEGIN
            INSERT INTO dbo.AdditionalCoverages (Id, Name, Status, CreatedAt, CreatedBy)
            VALUES (NEWID(), N''Trabalhista e Previdenciária'', N''Active'', @agora, @autor);
        END

        DECLARE @multa UNIQUEIDENTIFIER =
            (SELECT Id FROM dbo.AdditionalCoverages WHERE Name = N''Multas'');
        DECLARE @trab UNIQUEIDENTIFIER =
            (SELECT Id FROM dbo.AdditionalCoverages WHERE Name = N''Trabalhista e Previdenciária'');

        IF @temPenalty = 1
        BEGIN
            INSERT INTO dbo.QuotationGroupAdditionalCoverages
                (Id, QuotationGroupId, AdditionalCoverageId, CreatedAt, CreatedBy)
            SELECT NEWID(), g.Id, @multa, @agora, @autor
              FROM dbo.QuotationGroups g
             WHERE g.IncludesPenaltyCoverage = 1
               AND NOT EXISTS (SELECT 1
                                 FROM dbo.QuotationGroupAdditionalCoverages x
                                WHERE x.QuotationGroupId = g.Id
                                  AND x.AdditionalCoverageId = @multa);
        END

        IF @temLabor = 1
        BEGIN
            INSERT INTO dbo.QuotationGroupAdditionalCoverages
                (Id, QuotationGroupId, AdditionalCoverageId, CreatedAt, CreatedBy)
            SELECT NEWID(), g.Id, @trab, @agora, @autor
              FROM dbo.QuotationGroups g
             WHERE g.IncludesLaborCoverage = 1
               AND NOT EXISTS (SELECT 1
                                 FROM dbo.QuotationGroupAdditionalCoverages x
                                WHERE x.QuotationGroupId = g.Id
                                  AND x.AdditionalCoverageId = @trab);
        END
    ';
END
GO

IF COL_LENGTH(N'dbo.QuotationGroups', N'IncludesPenaltyCoverage') IS NOT NULL
    ALTER TABLE dbo.QuotationGroups DROP COLUMN IncludesPenaltyCoverage;
GO

IF COL_LENGTH(N'dbo.QuotationGroups', N'IncludesLaborCoverage') IS NOT NULL
    ALTER TABLE dbo.QuotationGroups DROP COLUMN IncludesLaborCoverage;
