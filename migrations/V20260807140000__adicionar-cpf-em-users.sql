-- RN-082 (regras-de-negocio/usuarios.md): CPF do Usuário — identifica a pessoa, imutável e único.
-- Obrigatório nos fluxos de convite novos; coluna NULLABLE porque Usuários pré-existentes à RN-082
-- não têm CPF. Unicidade por índice FILTRADO (ignora os NULL), como o convite ativo por Usuário.
SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.Users', N'DocumentNumber') IS NULL
BEGIN
    ALTER TABLE dbo.Users ADD DocumentNumber NVARCHAR(11) NULL;
END

-- EXEC difere a compilação do CREATE INDEX para depois do ALTER (a coluna já existe em tempo de
-- execução) e roda com QUOTED_IDENTIFIER ON herdado da sessão (exigência do índice filtrado).
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_Users_DocumentNumber' AND object_id = OBJECT_ID(N'dbo.Users'))
BEGIN
    EXEC(N'CREATE UNIQUE INDEX UX_Users_DocumentNumber
        ON dbo.Users (DocumentNumber)
        WHERE DocumentNumber IS NOT NULL;');
END
