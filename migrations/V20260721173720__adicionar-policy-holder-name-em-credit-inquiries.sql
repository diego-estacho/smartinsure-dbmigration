-- CreditInquiries: guarda a razao social do tomador retornada pela Seguradora.
-- Guard para ambientes que ja tinham a tabela antes da coluna existir.

IF OBJECT_ID(N'dbo.CreditInquiries', N'U') IS NOT NULL
   AND COL_LENGTH(N'dbo.CreditInquiries', N'PolicyHolderName') IS NULL
BEGIN
    ALTER TABLE dbo.CreditInquiries
        ADD PolicyHolderName NVARCHAR(200) NULL;
END;
