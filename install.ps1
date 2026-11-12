# ============================================================
#  PXT - instalador por PowerShell
#  Descarga "PXT Setup.exe", lo ejecuta en modo silencioso (pide
#  permiso de administrador una vez) y despues borra el descargado.
#
#  Uso rapido (desde CMD o Win+R):
#    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://TU-SERVIDOR/install.ps1 | iex"
#
#  Uso con parametros:
#    powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1 -Path "C:\ruta\PXT Setup.exe"
# ============================================================
param(
    [string]$Url = "",             # direccion de descarga de PXT Setup.exe
    [string]$Path = "",            # o ruta local a PXT Setup.exe (sin internet)
    [string]$Sha256 = "",          # opcional: hash para verificar la descarga
    [string[]]$SetupArgs = @()     # argumentos extra para el Setup (pruebas)
)

# ---- EDITA ESTAS DOS LINEAS cuando subas tu PXT Setup.exe ----
$DefaultUrl    = "https://github.com/EzPorteV22/Gui-pxt-bp/raw/main/PXT%20Setup.exe"
$DefaultSha256 = "484A7B509275366442EA39758F2CEFF4465CF81D82187CA7A6E8103F039EE207"   # hash de PXT Setup.exe (si subis otra version, actualizalo)
# ---------------------------------------------------------------

$ErrorActionPreference = "Stop"
function Say($t, $c = "Gray") { Write-Host $t -ForegroundColor $c }

Say ""
Say "  PXT  //  instalador" Magenta
Say "  ---------------------------------" DarkMagenta

$tmp = $null
try {
    if ($Path -ne "") {
        if (-not (Test-Path -LiteralPath $Path)) { throw "No existe el archivo: $Path" }
        $setup = $Path
        Say "  [*] Usando instalador local" Cyan
    } else {
        if ($Url -eq "") { $Url = $DefaultUrl }
        if ($Sha256 -eq "") { $Sha256 = $DefaultSha256 }
        if ($Url -like "*TU-SERVIDOR*") { throw "Falta configurar la URL de descarga (variable `$DefaultUrl en install.ps1)." }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $tmp = Join-Path $env:TEMP ("pxt_" + [guid]::NewGuid().ToString("N").Substring(0, 8) + ".exe")
        Say "  [*] Descargando instalador..." Cyan
        Invoke-WebRequest -Uri $Url -OutFile $tmp -UseBasicParsing
        $setup = $tmp
        if ($Sha256 -ne "") {
            $h = (Get-FileHash -LiteralPath $tmp -Algorithm SHA256).Hash
            if ($h -ne $Sha256.Trim().ToUpper()) { throw "El archivo descargado no coincide con el hash esperado." }
            Say "  [*] Hash verificado" Cyan
        }
    }

    # "-File ... -SetupArgs a,b" llega como un solo texto "a,b": lo separamos
    if ($SetupArgs.Count -eq 1 -and $SetupArgs[0] -like "*,*") { $SetupArgs = $SetupArgs[0] -split "," }
    $args2 = @("--silent") + $SetupArgs
    $argLine = ($args2 | ForEach-Object { if ($_ -match '\s') { '"' + $_ + '"' } else { $_ } }) -join " "
    Say "  [*] Instalando (acepta el aviso de administrador)..." Cyan
    # no usamos -Wait: el Setup deja el loader abierto y -Wait esperaria a que ese proceso termine
    $p = Start-Process -FilePath $setup -ArgumentList $argLine -PassThru
    $null = $p.Handle
    $p.WaitForExit()
    if ($p.ExitCode -ne 0) { throw "El instalador termino con error (codigo $($p.ExitCode))." }

    Say ""
    Say "  [OK] PXT instalado. Abri Spotify y toca INSERT." Green
    Say ""
}
catch {
    Say ""
    Say "  [ERROR] $($_.Exception.Message)" Red
    Say ""
    exit 1
}
finally {
    if ($tmp -and (Test-Path -LiteralPath $tmp)) { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
}
