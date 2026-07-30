-- RN-057/ADR-050 — Lease do fan-out de cotação na Cotação (ProcessingStartedAt).
-- O reconciliador reenfileira as Cotações Requested que ficaram órfãs após restart. Para NÃO reenfileirar
-- (duplicando a proposta no provedor, chamada não idempotente) uma solicitação que ainda está sendo obtida,
-- o consumidor carimba ProcessingStartedAt antes de acionar o provedor; o reconciliador só pega as em que o
-- lease expirou. O índice filtrado cobre exatamente as em voo (Requested), mantendo a varredura barata mesmo
-- com o histórico crescendo (RN-060 substitui, não apaga). Espelha o mapping EF QuotationMapping. ADR-058.

SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH(N'dbo.Quotations', N'ProcessingStartedAt') IS NULL
BEGIN
    ALTER TABLE dbo.Quotations ADD ProcessingStartedAt DATETIME2 NULL;
END

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Quotations_Requested' AND object_id = OBJECT_ID(N'dbo.Quotations'))
BEGIN
    CREATE INDEX IX_Quotations_Requested
        ON dbo.Quotations (ProcessingStartedAt, CreatedAt)
        WHERE ProcessingStatus = 'Requested';
END
