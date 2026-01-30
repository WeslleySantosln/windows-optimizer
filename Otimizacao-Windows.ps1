#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Script de Otimização e Configuração Inicial do Windows
    
.DESCRIPTION
    Script completo para otimização pós-formatação do Windows
    - Desativa serviços desnecessários
    - Remove telemetria e rastreamento
    - Desativa Recall (capturas de tela do Copilot)
    - Otimiza desempenho
    - Remove bloatware
    - Configura privacidade
    
.NOTES
    Autor: Script de Otimização Windows
    Requer: Execução como Administrador
#>

# Cores para output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Step {
    param([string]$Message)
    Write-ColorOutput Cyan "`n[*] $Message"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput Green "[✓] $Message"
}

function Write-Error-Custom {
    param([string]$Message)
    Write-ColorOutput Red "[✗] $Message"
}

# Banner
Clear-Host
Write-ColorOutput Yellow @"
╔═══════════════════════════════════════════════════════════╗
║     SCRIPT DE OTIMIZAÇÃO WINDOWS PÓS-FORMATAÇÃO          ║
║                                                           ║
║     Este script irá otimizar o Windows para melhor       ║
║     desempenho, privacidade e remover bloatware          ║
╚═══════════════════════════════════════════════════════════╝
"@

Write-Host "`nPressione qualquer tecla para iniciar..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# ============================================
# 1. DESATIVAR RECALL (Windows Copilot Screenshots)
# ============================================
Write-Step "Desativando Windows Recall (Capturas do Copilot)..."

try {
    # Desativar Recall via Registro
    $recallPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
    if (!(Test-Path $recallPath)) {
        New-Item -Path $recallPath -Force | Out-Null
    }
    Set-ItemProperty -Path $recallPath -Name "DisableAIDataAnalysis" -Value 1 -Type DWord -Force
    
    # Desativar capturas de tela automáticas
    $snapshotsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $snapshotsPath -Name "DisableSnapshots" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    
    # Desativar Timeline e Activity History
    $timelinePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (!(Test-Path $timelinePath)) {
        New-Item -Path $timelinePath -Force | Out-Null
    }
    Set-ItemProperty -Path $timelinePath -Name "EnableActivityFeed" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $timelinePath -Name "PublishUserActivities" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $timelinePath -Name "UploadUserActivities" -Value 0 -Type DWord -Force
    
    Write-Success "Recall desativado com sucesso"
} catch {
    Write-Error-Custom "Erro ao desativar Recall: $_"
}

# ============================================
# 2. DESATIVAR SERVIÇOS DESNECESSÁRIOS
# ============================================
Write-Step "Desativando serviços desnecessários..."

$servicesToDisable = @(
    "DiagTrack",                    # Telemetria
    "dmwappushservice",             # Telemetria WAP
    "RetailDemo",                   # Modo demonstração
    "RemoteRegistry",               # Registro remoto (segurança)
    "WSearch",                      # Windows Search (opcional)
    "SysMain",                      # Superfetch (em SSDs)
    "Fax",                          # Serviço de Fax
    "XblAuthManager",               # Xbox Live Auth
    "XblGameSave",                  # Xbox Live Save
    "XboxNetApiSvc",                # Xbox Live Networking
    "XboxGipSvc"                    # Xbox Accessory Management
)

foreach ($service in $servicesToDisable) {
    try {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Success "Serviço '$service' desativado"
        }
    } catch {
        Write-Host "  Serviço '$service' não encontrado ou já desativado"
    }
}

# ============================================
# 3. DESATIVAR CORTANA
# ============================================
Write-Step "Desativando Cortana..."

try {
    $cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (!(Test-Path $cortanaPath)) {
        New-Item -Path $cortanaPath -Force | Out-Null
    }
    Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force
    
    Write-Success "Cortana desativada"
} catch {
    Write-Error-Custom "Erro ao desativar Cortana: $_"
}

# ============================================
# 4. REMOVER TELEMETRIA
# ============================================
Write-Step "Removendo telemetria e rastreamento..."

try {
    # Desativar telemetria
    $telemetryPaths = @(
        "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    )
    
    foreach ($path in $telemetryPaths) {
        if (!(Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }
        Set-ItemProperty -Path $path -Name "AllowTelemetry" -Value 0 -Type DWord -Force
    }
    
    # Desativar tarefas agendadas de telemetria
    $tasksToDisable = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Autochk\Proxy",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    )
    
    foreach ($task in $tasksToDisable) {
        try {
            Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
        } catch {}
    }
    
    Write-Success "Telemetria desativada"
} catch {
    Write-Error-Custom "Erro ao desativar telemetria: $_"
}

# ============================================
# 5. DESATIVAR ANÚNCIOS E SUGESTÕES
# ============================================
Write-Step "Desativando anúncios e sugestões..."

try {
    # Desativar anúncios no menu Iniciar
    $startMenuPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Set-ItemProperty -Path $startMenuPath -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $startMenuPath -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $startMenuPath -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $startMenuPath -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $startMenuPath -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $startMenuPath -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord -Force
    
    # Desativar sugestões na tela de bloqueio
    Set-ItemProperty -Path $startMenuPath -Name "RotatingLockScreenEnabled" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $startMenuPath -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Type DWord -Force
    
    # Desativar dicas do Windows
    $cloudContentPath = "HKCU:\Software\Policies\Microsoft\Windows\CloudContent"
    if (!(Test-Path $cloudContentPath)) {
        New-Item -Path $cloudContentPath -Force | Out-Null
    }
    Set-ItemProperty -Path $cloudContentPath -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force
    
    Write-Success "Anúncios e sugestões desativados"
} catch {
    Write-Error-Custom "Erro ao desativar anúncios: $_"
}

# ============================================
# 6. CONFIGURAR PRIVACIDADE
# ============================================
Write-Step "Configurando opções de privacidade..."

try {
    # Localização mantida ativa (conforme solicitado pelo usuário)
    
    # Câmera mantida ativa (conforme solicitado pelo usuário)
    
    # Microfone mantido ativo (conforme solicitado pelo usuário)
    
    # Desativar sincronização
    $syncPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SettingSync"
    if (!(Test-Path $syncPath)) {
        New-Item -Path $syncPath -Force | Out-Null
    }
    Set-ItemProperty -Path $syncPath -Name "SyncPolicy" -Value 5 -Type DWord -Force
    
    # Desativar histórico de atividades
    $activityPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    if (!(Test-Path $activityPath)) {
        New-Item -Path $activityPath -Force | Out-Null
    }
    Set-ItemProperty -Path $activityPath -Name "PublishUserActivities" -Value 0 -Type DWord -Force
    
    Write-Success "Privacidade configurada"
} catch {
    Write-Error-Custom "Erro ao configurar privacidade: $_"
}

# ============================================
# 7. DESATIVAR APPS EM SEGUNDO PLANO
# ============================================
Write-Step "Desativando apps em segundo plano..."

try {
    $backgroundAppsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (!(Test-Path $backgroundAppsPath)) {
        New-Item -Path $backgroundAppsPath -Force | Out-Null
    }
    Set-ItemProperty -Path $backgroundAppsPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force
    
    Write-Success "Apps em segundo plano desativados"
} catch {
    Write-Error-Custom "Erro ao desativar apps em segundo plano: $_"
}

# ============================================
# 8. OTIMIZAR DESEMPENHO
# ============================================
Write-Step "Otimizando configurações de desempenho..."

try {
    # Desativar efeitos visuais desnecessários
    $visualPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (!(Test-Path $visualPath)) {
        New-Item -Path $visualPath -Force | Out-Null
    }
    Set-ItemProperty -Path $visualPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force
    
    # Desativar transparência
    $personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty -Path $personalizePath -Name "EnableTransparency" -Value 0 -Type DWord -Force
    
    # Desativar animações
    $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
    Set-ItemProperty -Path $dwmPath -Name "EnableAeroPeek" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    
    Write-Success "Desempenho otimizado"
} catch {
    Write-Error-Custom "Erro ao otimizar desempenho: $_"
}

# ============================================
# 9. CONFIGURAR MODO DE ENERGIA
# ============================================
Write-Step "Configurando plano de energia para Alto Desempenho..."

try {
    # Ativar plano de Alto Desempenho
    $highPerfGUID = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    powercfg -duplicatescheme $highPerfGUID
    powercfg -setactive $highPerfGUID
    
    # Desativar suspensão de disco
    powercfg -change -disk-timeout-ac 0
    powercfg -change -disk-timeout-dc 0
    
    # Desativar suspensão do sistema
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 30
    
    Write-Success "Plano de energia configurado para Alto Desempenho"
} catch {
    Write-Error-Custom "Erro ao configurar plano de energia: $_"
}

# ============================================
# 10. DESATIVAR HIBERNAÇÃO (Libera espaço)
# ============================================
Write-Step "Desativando hibernação..."

try {
    powercfg -h off
    Write-Success "Hibernação desativada (espaço em disco liberado)"
} catch {
    Write-Error-Custom "Erro ao desativar hibernação: $_"
}

# ============================================
# 11. REMOVER BLOATWARE
# ============================================
Write-Step "Removendo aplicativos pré-instalados desnecessários..."

$bloatware = @(
    "Microsoft.3DBuilder",
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.Wallet",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

foreach ($app in $bloatware) {
    try {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Write-Host "  Removido: $app"
    } catch {
        # Silenciar erros de apps não encontrados
    }
}

Write-Success "Bloatware removido"

# ============================================
# 12. CONFIGURAR WINDOWS UPDATE
# ============================================
Write-Step "Configurando Windows Update..."

try {
    $updatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    if (!(Test-Path $updatePath)) {
        New-Item -Path $updatePath -Force | Out-Null
    }
    
    # Notificar antes de baixar
    Set-ItemProperty -Path $updatePath -Name "AUOptions" -Value 2 -Type DWord -Force
    
    # Desativar atualizações automáticas de drivers
    $driverUpdatePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"
    Set-ItemProperty -Path $driverUpdatePath -Name "SearchOrderConfig" -Value 0 -Type DWord -Force
    
    Write-Success "Windows Update configurado"
} catch {
    Write-Error-Custom "Erro ao configurar Windows Update: $_"
}

# ============================================
# 13. INSTALAR GOOGLE CHROME
# ============================================
Write-Step "Instalando Google Chrome..."

try {
    # Verificar se o Winget está disponível
    $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
    
    if ($wingetPath) {
        Write-Host "  Usando Winget para instalar o Chrome..."
        winget install -e --id Google.Chrome --silent --accept-package-agreements --accept-source-agreements
        Write-Success "Google Chrome instalado via Winget"
    } else {
        Write-Host "  Winget não encontrado, baixando Chrome manualmente..."
        
        # URL do instalador do Chrome
        $chromeUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
        $installerPath = "$env:TEMP\chrome_installer.exe"
        
        # Baixar o instalador
        Invoke-WebRequest -Uri $chromeUrl -OutFile $installerPath -UseBasicParsing
        
        # Instalar silenciosamente
        Start-Process -FilePath $installerPath -Args "/silent /install" -Wait
        
        # Remover instalador
        Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
        
        Write-Success "Google Chrome instalado"
    }
} catch {
    Write-Error-Custom "Erro ao instalar Google Chrome: $_"
    Write-Host "  Você pode instalar manualmente em: https://www.google.com/chrome/"
}

# ============================================
# 14. COPIAR PASTA MICRO PARA DOCUMENTOS
# ============================================

Write-Step "Baixando pasta 'micro' do GitHub..."

$repoZipUrl = "https://github.com/WeslleySantosIn/SEU_REPOSITORIO/archive/refs/heads/main.zip"
$tempZip = "$env:TEMP\repo.zip"
$tempExtract = "$env:TEMP\repo_extract"

Invoke-WebRequest -Uri $repoZipUrl -OutFile $tempZip -UseBasicParsing

if (Test-Path $tempExtract) {
    Remove-Item $tempExtract -Recurse -Force
}

Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force

# 🔑 Descobrir automaticamente a pasta raiz extraída
$repoRoot = Get-ChildItem $tempExtract | Where-Object { $_.PSIsContainer } | Select-Object -First 1

if (-not $repoRoot) {
    throw "Não foi possível identificar a pasta raiz do repositório."
}

$microSourcePath = Join-Path $repoRoot.FullName "micro"

if (-not (Test-Path $microSourcePath)) {
    throw "A pasta 'micro' não foi encontrada dentro do repositório."
}

$documentsPath = [Environment]::GetFolderPath("MyDocuments")
$microDestPath = Join-Path $documentsPath "micro"

if (Test-Path $microDestPath) {
    Remove-Item $microDestPath -Recurse -Force
}

Copy-Item -Path $microSourcePath -Destination $microDestPath -Recurse -Force

Write-Success "Pasta 'micro' copiada com sucesso para Documentos"

        
        # ============================================
        # CONFIGURAR PAPEL DE PAREDE E TELA DE BLOQUEIO
        # ============================================
        Write-Step "Configurando papel de parede e tela de bloqueio..."
        
        # Caminho da imagem
        $wallpaperFileName = "foto_de_fundo_grupoprima.png"
        $wallpaperPath = Join-Path $microDestPath $wallpaperFileName
        
        # Verificar se a imagem existe
        if (Test-Path $wallpaperPath) {
            try {
                # Adicionar tipo para manipular wallpaper
                Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
                
                # Definir papel de parede da área de trabalho
                $SPI_SETDESKWALLPAPER = 0x0014
                $UpdateIniFile = 0x01
                $SendChangeEvent = 0x02
                $fWinIni = $UpdateIniFile -bor $SendChangeEvent
                
                [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $wallpaperPath, $fWinIni) | Out-Null
                Write-Success "Papel de parede da área de trabalho configurado"
                
                # Configurar tela de bloqueio via registro
                $lockScreenPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
                if (!(Test-Path $lockScreenPath)) {
                    New-Item -Path $lockScreenPath -Force | Out-Null
                }
                
                # Definir imagem da tela de bloqueio
                Set-ItemProperty -Path $lockScreenPath -Name "LockScreenImage" -Value $wallpaperPath -Type String -Force
                
                # Também configurar para o usuário atual
                $userLockScreenPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"
                if (!(Test-Path $userLockScreenPath)) {
                    New-Item -Path $userLockScreenPath -Force | Out-Null
                }
                
                # Copiar a imagem para o local padrão do Windows
                $wallpaperDestPath = "$env:APPDATA\Microsoft\Windows\Themes"
                if (!(Test-Path $wallpaperDestPath)) {
                    New-Item -Path $wallpaperDestPath -ItemType Directory -Force | Out-Null
                }
                Copy-Item -Path $wallpaperPath -Destination "$wallpaperDestPath\TranscodedWallpaper" -Force
                
                # Configurar também via registro do usuário para garantir
                $personalizationPath = "HKCU:\Control Panel\Desktop"
                Set-ItemProperty -Path $personalizationPath -Name "Wallpaper" -Value $wallpaperPath -Force
                
                Write-Success "Tela de bloqueio configurada"
                Write-Host "  A tela de bloqueio será aplicada após reiniciar o computador"
                
            } catch {
                Write-Error-Custom "Erro ao configurar papéis de parede: $_"
            }
        } else {
            Write-Host "  Imagem '$wallpaperFileName' não encontrada na pasta 'micro'"
            Write-Host "  Pulando configuração de papel de parede..."
        }
        
    } else {
        Write-Host "  Pasta 'micro' não encontrada. Pulando esta etapa..."
        Write-Host "  Procurado em: $microSourcePath"
    }
} catch {
    Write-Error-Custom "Erro ao copiar pasta 'micro': $_"
}

# ============================================
# 15. LIMPEZA DO SISTEMA
# ============================================
Write-Step "Executando limpeza do sistema..."

try {
    # Limpar arquivos temporários
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    # Limpar cache do Windows Update
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    
    Write-Success "Limpeza concluída"
} catch {
    Write-Error-Custom "Erro durante limpeza: $_"
}

# ============================================
# FINALIZAÇÃO
# ============================================
Write-ColorOutput Yellow "`n╔═══════════════════════════════════════════════════════════╗"
Write-ColorOutput Yellow "║              OTIMIZAÇÃO CONCLUÍDA COM SUCESSO!            ║"
Write-ColorOutput Yellow "╚═══════════════════════════════════════════════════════════╝"

Write-Host "`n"
Write-ColorOutput Green "✓ Recall desativado"
Write-ColorOutput Green "✓ Serviços desnecessários desativados"
Write-ColorOutput Green "✓ Cortana desativada"
Write-ColorOutput Green "✓ Telemetria removida"
Write-ColorOutput Green "✓ Anúncios desativados"
Write-ColorOutput Green "✓ Privacidade configurada (localização, câmera e microfone mantidos)"
Write-ColorOutput Green "✓ Apps em segundo plano desativados"
Write-ColorOutput Green "✓ Desempenho otimizado"
Write-ColorOutput Green "✓ Alto desempenho ativado"
Write-ColorOutput Green "✓ Hibernação desativada"
Write-ColorOutput Green "✓ Bloatware removido"
Write-ColorOutput Green "✓ Windows Update configurado"
Write-ColorOutput Green "✓ Google Chrome instalado"
Write-ColorOutput Green "✓ Pasta 'micro' copiada para Documentos"
Write-ColorOutput Green "✓ Papel de parede e tela de bloqueio configurados"
Write-ColorOutput Green "✓ Sistema limpo"

Write-Host "`n"
Write-ColorOutput Cyan "RECOMENDAÇÃO: Reinicie o computador para aplicar todas as alterações."
Write-Host "`n"

$restart = Read-Host "Deseja reiniciar agora? (S/N)"
if ($restart -eq 'S' -or $restart -eq 's') {
    Write-ColorOutput Yellow "Reiniciando em 10 segundos..."
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-ColorOutput Yellow "Lembre-se de reiniciar o computador mais tarde!"
}
