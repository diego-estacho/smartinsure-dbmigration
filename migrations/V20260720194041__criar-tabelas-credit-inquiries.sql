-- RN-029/RN-030/RN-031 — Consulta de Crédito (CreditInquiry)
-- Registro imutável de cada consulta de limites de crédito do tomador:
-- cabeçalho (Corretora + CNPJ consultado) e um resultado por Seguradora consultada,
-- inclusive indisponibilidades com motivo (RN-030). Nunca editado nem excluído (RN-031).

SET QUOTED_IDENTIFIER ON;

IF OBJECT_ID(N'dbo.CreditInquiries', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CreditInquiries (
        Id                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_CreditInquiries PRIMARY KEY,
        BrokerageId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_CreditInquiries_Brokerage REFERENCES dbo.Persons (Id),
        PolicyHolderCnpj   NVARCHAR(20)     NOT NULL,
        QueriedAt          DATETIME2        NOT NULL,
        CreatedAt          DATETIME2        NOT NULL,
        CreatedBy          NVARCHAR(100)    NOT NULL,
        UpdatedAt          DATETIME2        NULL,
        UpdatedBy          NVARCHAR(100)    NULL
    );

    -- RN-031: histórico consultável por CNPJ e por Corretora
    CREATE INDEX IX_CreditInquiries_PolicyHolderCnpj
        ON dbo.CreditInquiries (PolicyHolderCnpj);

    CREATE INDEX IX_CreditInquiries_BrokerageId
        ON dbo.CreditInquiries (BrokerageId);
END

IF OBJECT_ID(N'dbo.CreditInquiryResults', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CreditInquiryResults (
        Id                  UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_CreditInquiryResults PRIMARY KEY,
        CreditInquiryId     UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_CreditInquiryResults_CreditInquiry REFERENCES dbo.CreditInquiries (Id),
        InsurerId           UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_CreditInquiryResults_Insurer REFERENCES dbo.Insurers (Id),
        Status              NVARCHAR(20)     NOT NULL, -- Available | Unavailable (RN-030)
        FailureReason       NVARCHAR(500)    NULL,
        TraditionalLimit    DECIMAL(18,2)    NULL,
        TraditionalRate     DECIMAL(9,4)     NULL,
        JudicialLimit       DECIMAL(18,2)    NULL,
        JudicialRate        DECIMAL(9,4)     NULL,
        JudicialFiscalRate  DECIMAL(9,4)     NULL,
        FinancialLimit      DECIMAL(18,2)    NULL,
        FinancialRate       DECIMAL(9,4)     NULL,
        LimitValidUntil     DATETIME2        NULL,
        CreatedAt           DATETIME2        NOT NULL,
        CreatedBy           NVARCHAR(100)    NOT NULL,
        UpdatedAt           DATETIME2        NULL,
        UpdatedBy           NVARCHAR(100)    NULL,

        -- RN-030/RN-031: resultado indisponível sempre carrega o motivo
        CONSTRAINT CK_CreditInquiryResults_UnavailableReason
            CHECK (Status <> 'Unavailable' OR FailureReason IS NOT NULL)
    );

    -- Uma Seguradora aparece uma única vez por consulta
    CREATE UNIQUE INDEX UX_CreditInquiryResults_InquiryInsurer
        ON dbo.CreditInquiryResults (CreditInquiryId, InsurerId);

    CREATE INDEX IX_CreditInquiryResults_InsurerId
        ON dbo.CreditInquiryResults (InsurerId);
END
