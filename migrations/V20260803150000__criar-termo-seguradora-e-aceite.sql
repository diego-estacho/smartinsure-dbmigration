-- RN-506 (regras-de-negocio/emissao.md): Termo e declaração da Seguradora + registro do aceite.
-- Emitir exige aceite explícito do Termo vigente da Seguradora; o aceite guarda quem aceitou, quando,
-- o CONTEÚDO EXATO exibido e o agente de acesso — sem o conteúdo não há como provar o que foi aceito.
-- Uma versão vigente por Seguradora (índice único filtrado em IsActive); versões anteriores ficam para
-- os aceites já registrados. Espelha InsurerTermMapping e TermAcceptanceMapping 1:1.
-- Seed: nesta fase o catálogo nasce com o MESMO texto para as Seguradoras ativas (decisão do dono);
-- a curadoria por Seguradora e a origem jurídica do texto seguem em OPEN-23.
IF OBJECT_ID(N'dbo.InsurerTerms', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.InsurerTerms
    (
        Id        UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_InsurerTerms PRIMARY KEY,
        InsurerId UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_InsurerTerms_Insurers REFERENCES dbo.Insurers (Id),
        Content   NVARCHAR(MAX)    NOT NULL,
        IsActive  BIT              NOT NULL,
        CreatedAt DATETIME2        NOT NULL,
        CreatedBy NVARCHAR(100)    NOT NULL,
        UpdatedAt DATETIME2        NULL,
        UpdatedBy NVARCHAR(100)    NULL
    );

    CREATE INDEX IX_InsurerTerms_InsurerId ON dbo.InsurerTerms (InsurerId);
END

-- Índice único filtrado via EXEC: a coluna pode ter acabado de ser criada neste mesmo arquivo, e o
-- batch é compilado inteiro antes de executar (`GO` no meio não é opção neste repositório).
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = N'UX_InsurerTerms_ActiveByInsurer'
                 AND object_id = OBJECT_ID(N'dbo.InsurerTerms'))
BEGIN
    EXEC sp_executesql N'
        CREATE UNIQUE INDEX UX_InsurerTerms_ActiveByInsurer
            ON dbo.InsurerTerms (InsurerId)
            WHERE IsActive = 1;';
END

IF OBJECT_ID(N'dbo.TermAcceptances', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.TermAcceptances
    (
        Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_TermAcceptances PRIMARY KEY,
        InsurerTermId   UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_TermAcceptances_InsurerTerms REFERENCES dbo.InsurerTerms (Id),
        UserId          UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_TermAcceptances_Users REFERENCES dbo.Users (Id),
        AcceptedContent NVARCHAR(MAX)    NOT NULL,
        UserAgent       NVARCHAR(400)    NULL,
        AcceptedAt      DATETIME2        NOT NULL,
        CreatedAt       DATETIME2        NOT NULL,
        CreatedBy       NVARCHAR(100)    NOT NULL,
        UpdatedAt       DATETIME2        NULL,
        UpdatedBy       NVARCHAR(100)    NULL
    );

    CREATE INDEX IX_TermAcceptances_UserId ON dbo.TermAcceptances (UserId);
    CREATE INDEX IX_TermAcceptances_InsurerTermId ON dbo.TermAcceptances (InsurerTermId);
END

-- Carga inicial: Seguradora ativa sem Termo vigente recebe o texto padrão. Idempotente — não duplica
-- nem sobrescreve Termo já cadastrado (inclusive um texto próprio que venha depois pela curadoria).
DECLARE @defaultTerm NVARCHAR(MAX) = N'O tomador, por meio próprio ou por seu corretor de seguros, declara ter lido, compreendido e estar de acordo com as condições aqui estabelecidas, incluindo as condições contratuais deste seguro, autorizando a emissão da apólice oriunda desta proposta por meio deste pedido de emissão digital de Seguro Garantia.';

INSERT INTO dbo.InsurerTerms (Id, InsurerId, Content, IsActive, CreatedAt, CreatedBy)
SELECT NEWID(), i.Id, @defaultTerm, 1, SYSUTCDATETIME(), N'sqlcmd-seed'
FROM dbo.Insurers i
WHERE i.Status = N'Active'
  AND NOT EXISTS (SELECT 1
                  FROM dbo.InsurerTerms t
                  WHERE t.InsurerId = i.Id
                    AND t.IsActive = 1);
