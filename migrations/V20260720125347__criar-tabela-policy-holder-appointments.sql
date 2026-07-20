-- RN-027/RN-028 — Nomeação de Tomador (PolicyHolderAppointment)
-- Vínculo Corretora×Tomador×Seguradora, independente de BrokerageInsurerEnablements.
-- No máximo uma Nomeação Vigente (Status='Active') por par Tomador×Seguradora.

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.PolicyHolderAppointments', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PolicyHolderAppointments
    (
        Id              UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_PolicyHolderAppointments PRIMARY KEY,
        PolicyHolderId  UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_PolicyHolderAppointments_Persons_PolicyHolder REFERENCES dbo.Persons (Id),
        BrokerageId     UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_PolicyHolderAppointments_Persons_Brokerage REFERENCES dbo.Persons (Id),
        InsurerId       UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_PolicyHolderAppointments_Insurers REFERENCES dbo.Insurers (Id),
        Status          NVARCHAR(20)     NOT NULL,
        StartedAt       DATETIME2        NOT NULL,
        EndedAt         DATETIME2        NULL,
        CreatedAt       DATETIME2        NOT NULL,
        CreatedBy       NVARCHAR(100)    NOT NULL,
        UpdatedAt       DATETIME2        NULL,
        UpdatedBy       NVARCHAR(100)    NULL
    );

    -- RN-027: uma única Nomeação Vigente por par Tomador×Seguradora
    CREATE UNIQUE INDEX UX_PolicyHolderAppointments_ActivePair
        ON dbo.PolicyHolderAppointments (PolicyHolderId, InsurerId)
        WHERE Status = 'Active';

    CREATE INDEX IX_PolicyHolderAppointments_PolicyHolderId
        ON dbo.PolicyHolderAppointments (PolicyHolderId);

    CREATE INDEX IX_PolicyHolderAppointments_BrokerageId
        ON dbo.PolicyHolderAppointments (BrokerageId);

    CREATE INDEX IX_PolicyHolderAppointments_InsurerId
        ON dbo.PolicyHolderAppointments (InsurerId);
END
