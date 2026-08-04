-- RN-029/RN-031 — Consulta de Crédito: tempo de resposta por Seguradora
-- Persiste a duração medida da chamada ao Motor de Cálculo, por Seguradora (em ms),
-- para exibição na consulta e no histórico imutável (RN-031). Ausente (NULL) quando a
-- Seguradora não respondeu (indisponibilidade, falha ou pré-condição não atendida).

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.CreditInquiryResults', N'ResponseTimeMs') IS NULL
BEGIN
    ALTER TABLE dbo.CreditInquiryResults
        ADD ResponseTimeMs BIGINT NULL;
END
