-- RN-514 (regras-de-negocio/emissao.md): Apólice — registro da emissão SOLICITADA de uma Cotação.
-- Guarda os valores vigentes no momento da emissão (inclusive os recalculados por ajuste de taxa,
-- RN-504), a forma de pagamento escolhida (RN-505), o snapshot do endereço do Segurado enviado
-- (RN-503), o aceite do Termo (RN-506) e quem solicitou.
-- Nesta fase NÃO há número da apólice, arquivo nem boletos: vêm da confirmação da emissão, que é
-- demanda própria (OPEN-07) — a plataforma não registra o que não confirmou.
-- Índice único em QuotationId: é o que garante no banco a solicitação única por Cotação (RN-507).
-- Espelha PolicyMapping 1:1.
IF OBJECT_ID(N'dbo.Policies', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Policies
    (
        Id                        UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_Policies PRIMARY KEY,
        QuotationGroupId          UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_Policies_QuotationGroups REFERENCES dbo.QuotationGroups (Id),
        QuotationId               UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_Policies_Quotations REFERENCES dbo.Quotations (Id),
        PolicyExternalId          NVARCHAR(100)    NOT NULL,
        ProposalNumber            NVARCHAR(50)     NULL,
        Premium                   DECIMAL(18, 2)   NULL,
        Tax                       DECIMAL(9, 4)    NULL,
        CommissionPercentage      DECIMAL(9, 4)    NULL,
        CommissionValue           DECIMAL(18, 2)   NULL,
        InstallmentNumber         INT              NOT NULL,
        GracePeriodInDays         INT              NOT NULL,
        TermAcceptanceId          UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_Policies_TermAcceptances REFERENCES dbo.TermAcceptances (Id),
        RequestedByUserId         UNIQUEIDENTIFIER NOT NULL
            CONSTRAINT FK_Policies_Users REFERENCES dbo.Users (Id),
        RequestedAt               DATETIME2        NOT NULL,
        InsuredAddressZipCode     NVARCHAR(8)      NULL,
        InsuredAddressStreet      NVARCHAR(200)    NULL,
        InsuredAddressNumber      NVARCHAR(20)     NULL,
        InsuredAddressComplement  NVARCHAR(100)    NULL,
        InsuredAddressNeighborhood NVARCHAR(100)   NULL,
        InsuredAddressCity        NVARCHAR(100)    NULL,
        InsuredAddressState       NVARCHAR(2)      NULL,
        CreatedAt                 DATETIME2        NOT NULL,
        CreatedBy                 NVARCHAR(100)    NOT NULL,
        UpdatedAt                 DATETIME2        NULL,
        UpdatedBy                 NVARCHAR(100)    NULL
    );

    CREATE UNIQUE INDEX UX_Policies_QuotationId ON dbo.Policies (QuotationId);
    CREATE INDEX IX_Policies_QuotationGroupId ON dbo.Policies (QuotationGroupId);
END
