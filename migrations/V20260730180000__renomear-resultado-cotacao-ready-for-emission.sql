-- ADR-064 / RN-058 — renomear o valor do resultado da Cotação: Automatic -> ReadyForEmission.
-- EQuotationResult e persistido como string (ADR-031); o valor 'Automatic' passa a 'ReadyForEmission'
-- (mesma classificacao estavel, so o nome mudou — mais intuitivo: a Cotacao esta apta a ser emitida).
-- Atualiza as linhas ja obtidas com esse resultado; idempotente (so afeta as que ainda estao 'Automatic').

SET QUOTED_IDENTIFIER ON;

UPDATE dbo.Quotations SET Result = 'ReadyForEmission' WHERE Result = 'Automatic';
