-- Baseline inicial do schema SmartInsure: marco zero do histórico Flyway.
-- Nenhum objeto de negócio é criado aqui — o schema nasce nas migrations
-- seguintes, definidas junto com as RNs (ADR-041); este script apenas
-- inaugura a flyway_schema_history de forma verificável em todo ambiente.
SELECT 1;
