##Regra do firewall
Write-Host "[*] Adicionando regra de firewall para permitir Ping (ICMPv4)..." -ForegroundColor Cyan

# Executa o comando para liberar o Ping no Windows Firewall
netsh advfirewall firewall add rule name="Permitir Ping (ICMPv4)" protocol=icmpv4:8,any dir=in action=allow | Out-Null

# Agora sim o script verifica se o comando acima funcionou
if ($LASTEXITCODE -eq 0) {
    Write-Host "[+] Regra de Firewall (Ping/ICMPv4) adicionada com sucesso [OK]!" -ForegroundColor Green
} else {
    Write-Host "[-] Falha ao adicionar a regra de Firewall. O sistema pode bloquear o Ping." -ForegroundColor Red
}
Write-Host "[*] Verificando se o FusionInventory Agent esta instalado..." -ForegroundColor Cyan

$RegPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$FusionFound = $false

$RegPaths | ForEach-Object {
    if (-not $FusionFound) {
        $path = $_
        $keys = Get-Item -Path $path -ErrorAction SilentlyContinue
        if ($null -ne $keys) {
            $keys | ForEach-Object {
                if (-not $FusionFound) {
                    $key = $_
                    $displayName = $key.GetValue("DisplayName")
                    if ($displayName -like "*FusionInventory*") {
                        $FusionFound = $true
                        $uninstallString = $key.GetValue("UninstallString")
                        Write-Host "[+] FusionInventory encontrado. Iniciando desinstalacao..." -ForegroundColor Yellow
                        
                        if ($uninstallString -like "*msiexec*") {
                            $uninstArgs = $uninstallString -replace "/I", "/X "
                            $uninstArgs = "$uninstArgs /quiet /norestart"
                            Start-Process -FilePath "cmd.exe" -ArgumentList "/c $uninstArgs" -Wait -NoNewWindow
                        } else {
                            Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $($key.PSChildName) /quiet /norestart" -Wait -NoNewWindow
                        }
                        Write-Host "[+] FusionInventory desinstalado com sucesso!" -ForegroundColor Green
                    }
                }
            }
        }
    }
}

if (-not $FusionFound) {
    Write-Host "[-] Nenhum FusionInventory Agent encontrado." -ForegroundColor DarkGray
}

# Verifica fisicamente se o arquivo do agente existe para definir $GlpiFound como $true ou $false
$GlpiFound = Test-Path "C:\Program Files\GLPI-Agent\glpi-agent.bat"

if ($GlpiFound) {
    Write-Host "[+] GLPI Agent ja esta instalado no sistema!" -ForegroundColor Green
} else {
    # ==========================================
    # INSTALAR O GLPI AGENT (A PARTIR DA PASTA LOCAL)
    # ==========================================
    Write-Host "[-] GLPI Agent nao encontrado. Iniciando processo de instalacao..." -ForegroundColor Yellow

    # Define o diretório atual de onde o script está sendo executado
    $CurrentDirectory = $PSScriptRoot
    if (-not $CurrentDirectory) { $CurrentDirectory = (Get-Location).Path }
    $MsiName = "GLPI-Agent-1.19-x64.msi"
    
    # Busca o MSI na mesma pasta do script
    $MsiPath = Join-Path -Path $CurrentDirectory -ChildPath $MsiName

    if (Test-Path -Path $MsiPath) {
        Write-Host "[+] Arquivo MSI encontrado em: $MsiPath" -ForegroundColor Cyan
        
        # Argumentos para instalação silenciosa (sem definir servidor)
        $MsiArgs = @(
            "/i", "`"$MsiPath`"", "/quiet", "/norestart"
        )

        Write-Host "[*] Instalando o GLPI Agent... Aguarde." -ForegroundColor Yellow
        $Process = Start-Process -FilePath "msiexec.exe" -ArgumentList $MsiArgs -Wait -PassThru -NoNewWindow
        
        if ($Process.ExitCode -eq 0) {
            Write-Host "[+] GLPI Agent instalado com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "[-] A instalacao terminou com o codigo de erro: $($Process.ExitCode)" -ForegroundColor Red
        }

    } else {
        Write-Host "[-] O arquivo MSI NAO foi encontrado na pasta local do script: $MsiPath" -ForegroundColor Red
    }
}

# ==========================================
# GERAR INVENTÁRIO LOCAL EM XML
# ==========================================
Write-Host "[*] Gerando inventario local em XML na Area de Trabalho..." -ForegroundColor Cyan

$destino = "$env:USERPROFILE\Desktop\$env:COMPUTERNAME.xml"

# Removida a flag --xml, pois o padrão nativo já é XML
& "C:\Program Files\GLPI-Agent\glpi-inventory.bat" | Out-File -FilePath $destino -Encoding utf8

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("O arquivo $env:COMPUTERNAME.xml foi gerado com sucesso na sua Área de Trabalho.", "Dump GLPI Concluído", 0, [System.Windows.Forms.MessageBoxIcon]::Information)