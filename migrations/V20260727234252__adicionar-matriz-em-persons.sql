-- RN-052 (regras-de-negocio/tomadores.md) — Filial do Tomador.
-- ADR-063: a Filial é uma Pessoa jurídica como qualquer outra; o vínculo com a matriz é persistido
-- (não derivado por raiz de CNPJ). Matriz tem HeadquartersPersonId NULL. Sem backfill.

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.Persons', N'HeadquartersPersonId') IS NULL
BEGIN
    ALTER TABLE dbo.Persons
        ADD HeadquartersPersonId UNIQUEIDENTIFIER NULL
            CONSTRAINT FK_Persons_Headquarters REFERENCES dbo.Persons (Id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Persons_HeadquartersPersonId')
BEGIN
    CREATE INDEX IX_Persons_HeadquartersPersonId
        ON dbo.Persons (HeadquartersPersonId)
        WHERE HeadquartersPersonId IS NOT NULL;
END
