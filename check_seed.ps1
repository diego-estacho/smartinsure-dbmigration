# Count unique codes in migration
$migration = @"
INSERT INTO dbo.LegalNatures (Id, EmissionYear, Code, Name, IsPrivate, CreatedAt, CreatedBy) VALUES (N'818593BE-E75A-425B-9D9D-CEC8652DB75A', 2018, N'2062', N'Sociedade Empresária Limitada', 1, SYSUTCDATETIME(), N'flyway-seed');
INSERT INTO dbo.LegalNatures (Id, EmissionYear, Code, Name, IsPrivate, CreatedAt, CreatedBy) VALUES (N'FC92A548-0CB3-480B-BD65-D1074C47D67E', 2018, N'2046', N'Sociedade Anônima Aberta', 1, SYSUTCDATETIME(), N'flyway-seed');
INSERT INTO dbo.LegalNatures (Id, EmissionYear, Code, Name, IsPrivate, CreatedAt, CreatedBy) VALUES (N'FDB6F55F-C14A-4F2B-8A5F-14ABFE4C4B8C', 2018, N'1015', N'Órgão Público do Poder Executivo Federal', 0, SYSUTCDATETIME(), N'flyway-seed');
INSERT INTO dbo.LegalNatures (Id, EmissionYear, Code, Name, IsPrivate, CreatedAt, CreatedBy) VALUES (N'1ED210D6-E9A0-43DD-A6D9-0A4F0B51580B', 2018, N'1236', N'Direito Público Interno', 0, SYSUTCDATETIME(), N'flyway-seed');
INSERT INTO dbo.LegalNatures (Id, EmissionYear, Code, Name, IsPrivate, CreatedAt, CreatedBy) VALUES (N'737EA2BE-0949-4E00-8FEB-2309131E4FA1', 2021, N'1228', N'Consórcio Público de Direito Privado', 0, SYSUTCDATETIME(), N'flyway-seed');
INSERT INTO dbo.LegalNatures (Id, EmissionYear, Code, Name, IsPrivate, CreatedAt, CreatedBy) VALUES (N'01706741-CD82-4B1B-8D01-B432164B4F80', 2021, N'2321', N'Sociedade Unipessoal de Advogados', 1, SYSUTCDATETIME(), N'flyway-seed');
INSERT INTO dbo.LegalNatures (Id, EmissionYear, Code, Name, IsPrivate, CreatedAt, CreatedBy) VALUES (N'6F8207D7-9260-4B5D-B2F2-6969ACEE3EE1', 2021, N'4120', N'Produtor Rural (Pessoa Física)', 1, SYSUTCDATETIME(), N'flyway-seed');
"@

# Check samples
$samples = @{
    '2062' = 1
    '1015' = 0
    '1228' = 0
    '2321' = 1
}

foreach ($code in $samples.Keys) {
    $match = $migration | Select-String "N'$code'" -Context 0,0
    if ($match) {
        if ($match -match "N'$code'.*(\d+), SYSUTCDATETIME") {
            $val = [int]$Matches[1]
            $expected = $samples[$code]
            if ($val -eq $expected) {
                Write-Host "Code $code: IsPrivate=$val (correct)"
            } else {
                Write-Host "Code $code: IsPrivate=$val (EXPECTED $expected) - MISMATCH"
            }
        }
    }
}
