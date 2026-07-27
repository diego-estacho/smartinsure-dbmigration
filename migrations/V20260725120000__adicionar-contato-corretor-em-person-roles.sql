-- RN-054 (regras-de-negocio/corretoras.md): os dados de contato complementares da Corretora
-- (e-mail, telefone e responsável) moram no vínculo PersonRole do papel Corretor, como a
-- situação Ativa/Inativa já mora (RN-018/RN-021). Nulos para os demais papéis da Pessoa.
-- Espelha o mapping EF PersonRoleMapping do backend (mesma janela de release).
-- A data de cadastro da Corretora reaproveita PersonRoles.CreatedAt (sem coluna nova).
IF OBJECT_ID(N'dbo.PersonRoles', N'U') IS NOT NULL
    AND COL_LENGTH(N'dbo.PersonRoles', N'ContactEmail') IS NULL
BEGIN
    ALTER TABLE dbo.PersonRoles
        ADD ContactEmail    NVARCHAR(200) NULL,
            ContactPhone    NVARCHAR(20)  NULL,
            ResponsibleName NVARCHAR(200) NULL;
END
