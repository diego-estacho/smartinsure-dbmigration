-- RN-018/RN-021 (regras-de-negocio/corretoras.md): situação Ativa/Inativa da
-- Corretora mora no vínculo PersonRole Broker, sem alterar a Pessoa.
IF OBJECT_ID(N'dbo.PersonRoles', N'U') IS NOT NULL
    AND COL_LENGTH(N'dbo.PersonRoles', N'Status') IS NULL
BEGIN
    ALTER TABLE dbo.PersonRoles
        ADD Status NVARCHAR(20) NOT NULL
            CONSTRAINT DF_PersonRoles_Status DEFAULT N'Active';
END
