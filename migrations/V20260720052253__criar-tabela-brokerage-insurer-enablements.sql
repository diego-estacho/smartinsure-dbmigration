-- RN-022..RN-023 (regras-de-negocio/motor-de-calculo.md): tabela BrokerageInsurerEnablements (ADR-058: artefatos em inglês).
-- Habilitação de Seguradora: vínculo Corretora(Person)×Seguradora com Motor de Cálculo e parâmetros de conexão.
-- Espelha o mapping EF BrokerageInsurerEnablementMapping do backend (mesma janela de release); par único (RN-022).
IF OBJECT_ID(N'dbo.BrokerageInsurerEnablements', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.BrokerageInsurerEnablements
    (
        Id                   UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_BrokerageInsurerEnablements PRIMARY KEY,
        BrokerageId          UNIQUEIDENTIFIER NOT NULL,
        InsurerId            UNIQUEIDENTIFIER NOT NULL,
        CalculationEngine    NVARCHAR(50)     NOT NULL,
        ConnectionParameters NVARCHAR(MAX)    NULL,
        Status               NVARCHAR(20)     NOT NULL,
        CreatedAt            DATETIME2        NOT NULL,
        CreatedBy            NVARCHAR(100)    NOT NULL,
        UpdatedAt            DATETIME2        NULL,
        UpdatedBy            NVARCHAR(100)    NULL,
        CONSTRAINT FK_BrokerageInsurerEnablements_Persons FOREIGN KEY (BrokerageId) REFERENCES dbo.Persons (Id),
        CONSTRAINT FK_BrokerageInsurerEnablements_Insurers FOREIGN KEY (InsurerId) REFERENCES dbo.Insurers (Id)
    );

    CREATE UNIQUE INDEX IX_BrokerageInsurerEnablements_BrokerageId_InsurerId
        ON dbo.BrokerageInsurerEnablements (BrokerageId, InsurerId);
END
