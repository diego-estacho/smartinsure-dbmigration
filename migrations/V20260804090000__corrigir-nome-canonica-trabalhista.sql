-- RN-104 (AB#0007) — alinha o nome da Cobertura Adicional canônica ao glossário e à plataforma
-- legada: o seed gravou "Trabalhista e Previdênciário" (typo em duas letras). A conversão dos
-- booleanos do Grupo de Cotação (V20260804090200) resolve a canônica POR NOME e depende deste acerto.
-- Idempotente e conservadora: só renomeia se o nome com typo existir e o correto ainda não existir
-- (evita colidir com o índice único de nome, se houver, e evita duas canônicas para o mesmo conceito).

SET QUOTED_IDENTIFIER ON;

IF EXISTS (SELECT 1 FROM dbo.AdditionalCoverages WHERE Name = N'Trabalhista e Previdênciário')
   AND NOT EXISTS (SELECT 1 FROM dbo.AdditionalCoverages WHERE Name = N'Trabalhista e Previdenciária')
BEGIN
    UPDATE dbo.AdditionalCoverages
       SET Name = N'Trabalhista e Previdenciária'
     WHERE Name = N'Trabalhista e Previdênciário';
END
