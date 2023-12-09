[cmdletbinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]
    $CertName,

    [Parameter(Mandatory=$false)]
    [SecureString]
    $CertPassword = (ConvertTo-SecureString -String "test" -Force -AsPlainText),

    [Parameter(Mandatory=$false)]
    [string]
    $certStoreLocation = "Cert:\CurrentUser\My",

    [Parameter(Mandatory=$false)]
    [string]
    $OutputLocation = "..\certs",

    [Parameter(Mandatory=$false)]
    [string]
    $KeyExportPolicy = "Exportable",

    [Parameter(Mandatory=$false)]
    [string]
    $KeySpec = "Signature",

    [Parameter(Mandatory=$false)]
    [int]
    $KeyLength = 2048,

    [Parameter(Mandatory=$false)]
    [string]
    $KeyAlgorithm = "RSA",

    [Parameter(Mandatory=$false)]
    [string]
    $HashAlgorithm = "SHA256"
)

Write-Information ("Creating Certificate")
$cert = New-SelfSignedCertificate -Subject "CN=$CertName" -CertStoreLocation $certStoreLocation -KeyExportPolicy $KeyExportPolicy -KeySpec $KeySpec -KeyLength $KeyLength -KeyAlgorithm $KeyAlgorithm -HashAlgorithm $HashAlgorithm

Write-Information("Exporting Certificate")
Export-PfxCertificate -Cert $cert -FilePath "$OutputLocation\$certname.pfx" -Password $CertPassword   