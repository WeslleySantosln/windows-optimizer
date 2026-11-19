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

# Grava um valor no Registro, criando a chave se ela não existir
function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        $Value,
        [string]$Type = "DWord"
    )
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
    }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force -ErrorAction Stop
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

# ============================================
# MENU INICIAL
# ============================================
Write-Host "`n"
Write-ColorOutput Cyan "═══════════════════════════════════════════════════════════"
Write-ColorOutput Cyan "                    MENU DE OPÇÕES"
Write-ColorOutput Cyan "═══════════════════════════════════════════════════════════"
Write-Host "`n"

Write-Host "Escolha o que deseja fazer:"
Write-Host ""
Write-Host "  [1] Otimização completa corporativa"
Write-Host "  [2] Apenas instalar Google Chrome"
Write-Host "  [3] Otimização para jogos (PC dedicado a jogos)"
Write-Host "  [0] Sair"
Write-Host ""

$opcao = Read-Host "Digite sua opção"

# Variáveis de controle
$executeOptimization = $false
$installChrome = $false
$modoJogos = $false   # $true = otimização para jogos (opção 3); $false = corporativa (opção 1)

switch ($opcao) {
    "1" {
        Write-ColorOutput Green "`nVocê escolheu: Otimização completa corporativa"
        $executeOptimization = $true
        $installChrome = $false
    }
    "2" {
        Write-ColorOutput Green "`nVocê escolheu: Apenas instalar Google Chrome"
        $executeOptimization = $false
        $installChrome = $true
    }
    "3" {
        Write-ColorOutput Green "`nVocê escolheu: Otimização para jogos"
        $executeOptimization = $true
        $modoJogos = $true
        $installChrome = $false
    }
    "0" {
        Write-ColorOutput Yellow "`nSaindo do script..."
        Start-Sleep -Seconds 2
        exit
    }
    default {
        Write-ColorOutput Red "`nOpção inválida! Saindo..."
        Start-Sleep -Seconds 3
        exit
    }
}

Write-Host "`nPressione qualquer tecla para continuar..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# ============================================
# EXECUTAR OTIMIZAÇÃO (se selecionado)
# ============================================
if ($executeOptimization) {

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
    "Fax"                           # Serviço de Fax
)

if ($modoJogos) {
    # PC de jogos: os serviços Xbox são MANTIDOS (controle Xbox e login Xbox em jogos)
    $servicesToDisable += @(
        "Spooler",                  # Impressão
        "stisvc",                   # Scanners e câmeras (WIA)
        "SCardSvr",                 # Cartão inteligente
        "ScDeviceEnum",             # Enumeração de cartão inteligente
        "MapsBroker",               # Mapas baixados
        "lfsvc",                    # Geolocalização
        "WerSvc",                   # Relatório de erros do Windows
        "PcaSvc",                   # Assistente de Compatibilidade de Programas
        "PhoneSvc",                 # Telefone
        "WalletService",            # Carteira
        "WpcMonSvc",                # Controle dos pais
        "icssvc",                   # Hotspot móvel
        "wisvc",                    # Windows Insider
        "TrkWks"                    # Rastreamento de links distribuídos
    )
} else {
    $servicesToDisable += @(
        "XblAuthManager",           # Xbox Live Auth
        "XblGameSave",              # Xbox Live Save
        "XboxNetApiSvc",            # Xbox Live Networking
        "XboxGipSvc"                # Xbox Accessory Management
    )
}

if ($modoJogos) {
    # Desligar a compactação de memória. Precisa rodar ANTES de desativar o SysMain
    # (logo abaixo), porque é esse serviço que aplica a configuração.
    try {
        Disable-MMAgent -MemoryCompression -ErrorAction Stop
        Write-Success "Compactação de memória desativada"
    } catch {
        Write-Error-Custom "Erro ao desativar a compactação de memória: $_"
    }
}

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

    if ($modoJogos) {
        $tasksToDisable += @(
            "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser Exp",
            "\Microsoft\Windows\Application Experience\MareBackup",
            "\Microsoft\Windows\Feedback\Siuf\DmClient",
            "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
            "\Microsoft\Windows\Windows Error Reporting\QueueReporting",
            "\Microsoft\Windows\Maps\MapsUpdateTask",
            "\Microsoft\Windows\Maps\MapsToastTask"
        )
    }

    foreach ($task in $tasksToDisable) {
        try {
            # Disable-ScheduledTask precisa da pasta (-TaskPath) e do nome (-TaskName) separados
            $taskPath = $task.Substring(0, $task.LastIndexOf('\') + 1)
            $taskName = $task.Substring($task.LastIndexOf('\') + 1)
            Disable-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue | Out-Null
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
    # Localização, câmera e microfone mantidos ativos (conforme solicitado)
    
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
    # Configurar para "Ajustar para obter um melhor desempenho"
    # mas mantendo fontes suaves e sombras de ícones
    
    # Definir como personalizado (VisualFXSetting = 3)
    $visualPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (!(Test-Path $visualPath)) {
        New-Item -Path $visualPath -Force | Out-Null
    }
    Set-ItemProperty -Path $visualPath -Name "VisualFXSetting" -Value 3 -Type DWord -Force
    
    # Caminho principal dos efeitos visuais
    $advancedPath = "HKCU:\Control Panel\Desktop"
    $dwmPath = "HKCU:\Software\Microsoft\Windows\DWM"
    $explorerAdvPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    
    # DESATIVAR todos os efeitos (melhor desempenho)
    Set-ItemProperty -Path $advancedPath -Name "DragFullWindows" -Value "0" -Type String -Force
    Set-ItemProperty -Path $advancedPath -Name "FontSmoothing" -Value "2" -Type String -Force  # Manter suavização
    Set-ItemProperty -Path $advancedPath -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force
    
    # Desativar animações de janela
    Set-ItemProperty -Path $dwmPath -Name "EnableAeroPeek" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $dwmPath -Name "AlwaysHibernateThumbnails" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    
    # Desativar transparência
    $personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty -Path $personalizePath -Name "EnableTransparency" -Value 0 -Type DWord -Force
    
    # Configurações específicas do Explorer
    Set-ItemProperty -Path $explorerAdvPath -Name "ListviewAlphaSelect" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $explorerAdvPath -Name "ListviewShadow" -Value 1 -Type DWord -Force  # MANTER sombras de ícones
    Set-ItemProperty -Path $explorerAdvPath -Name "TaskbarAnimations" -Value 0 -Type DWord -Force
    
    # SystemParametersInfo para aplicar algumas mudanças imediatamente
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class VisualEffects {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);
}
"@
    
    # SPI_SETFONTSMOOTHING = 0x004B (manter fontes suaves)
    [VisualEffects]::SystemParametersInfo(0x004B, 2, [IntPtr]::Zero, 0x01 -bor 0x02) | Out-Null
    
    Write-Success "Efeitos visuais configurados (melhor desempenho + fontes suaves + sombras de ícones)"
    
} catch {
    Write-Error-Custom "Erro ao otimizar desempenho visual: $_"
}

# ============================================
# CONFIGURAR MEMÓRIA VIRTUAL (ARQUIVO DE PAGINAÇÃO)
# ============================================
Write-Step "Configurando memória virtual personalizada..."

try {
    # Tamanho inicial: 8000 MB (8 GB)
    # Tamanho máximo: 16000 MB (16 GB)
    
    $initialSize = 8000
    $maximumSize = 16000
    
    # Obter a letra da unidade do sistema (geralmente C:)
    $systemDrive = $env:SystemDrive
    
    # Desabilitar gerenciamento automático
    $computerSystem = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
    $computerSystem.AutomaticManagedPagefile = $false
    $computerSystem.Put() | Out-Null
    
    # Configurar arquivo de paginação personalizado
    $pageFile = Get-WmiObject -Query "SELECT * FROM Win32_PageFileSetting WHERE Name='$systemDrive\\pagefile.sys'"
    
    if ($pageFile) {
        # Atualizar arquivo existente
        $pageFile.InitialSize = $initialSize
        $pageFile.MaximumSize = $maximumSize
        $pageFile.Put() | Out-Null
    } else {
        # Criar novo arquivo de paginação
        $pageFile = ([WMIClass]"root\cimv2:Win32_PageFileSetting").CreateInstance()
        $pageFile.Name = "$systemDrive\pagefile.sys"
        $pageFile.InitialSize = $initialSize
        $pageFile.MaximumSize = $maximumSize
        $pageFile.Put() | Out-Null
    }
    
    Write-Success "Memória virtual configurada: Inicial=$initialSize MB, Máximo=$maximumSize MB"
    Write-Host "  A configuração será aplicada após reiniciar o computador"
    
} catch {
    Write-Error-Custom "Erro ao configurar memória virtual: $_"
}

# ============================================
# 9. CONFIGURAR MODO DE ENERGIA
# ============================================
if ($modoJogos) {
    # PC de jogos (desktop): plano "Desempenho Máximo" (Ultimate Performance)
    Write-Step "Configurando plano de energia Desempenho Máximo..."

    try {
        $ultimateBaseGUID = "e9a42b02-d5df-448d-aa00-03f14749eb61"   # modelo do Windows
        $ultimateGUID = "9f4c2a1e-7b3d-4e6a-8c5f-2d1e0b9a7c63"       # cópia criada por este script

        # Criar a cópia só na primeira execução (evita planos duplicados)
        if (-not ((powercfg -list) -match $ultimateGUID)) {
            powercfg -duplicatescheme $ultimateBaseGUID $ultimateGUID | Out-Null
        }
        powercfg -setactive $ultimateGUID
        if ($LASTEXITCODE -ne 0) {
            throw "plano Desempenho Máximo não disponível neste Windows"
        }

        # Suspensão seletiva de USB desligada (controle e mouse não "dormem")
        powercfg -setacvalueindex $ultimateGUID 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
        # Economia de energia do PCI Express (placa de vídeo) desligada
        powercfg -setacvalueindex $ultimateGUID 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
        powercfg -setactive $ultimateGUID

        # Nunca suspender o PC nem desligar o disco
        powercfg -change -standby-timeout-ac 0
        powercfg -change -disk-timeout-ac 0

        Write-Success "Plano de energia Desempenho Máximo ativado"
    } catch {
        Write-Error-Custom "Erro ao configurar plano de energia: $_"
    }
} else {

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

} # FIM plano de energia corporativo

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
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

if ($modoJogos) {
    # PC de jogos: MANTÉM Xbox Identity Provider e Xbox TCUI (login Xbox em jogos da Steam etc.)
    # e a Game Bar (sem ela, o botão Xbox do controle mostra erro "ms-gamingoverlay")
    $bloatware += @(
        "Microsoft.GamingApp",                      # App Xbox (não usado)
        "Microsoft.XboxApp",                        # App Xbox antigo
        "Microsoft.XboxSpeechToTextOverlay",
        "Clipchamp.Clipchamp",
        "MicrosoftTeams",
        "MSTeams",
        "Microsoft.OutlookForWindows",
        "microsoft.windowscommunicationsapps",      # Email e Calendário
        "Microsoft.Todos",
        "Microsoft.PowerAutomateDesktop",
        "Microsoft.Windows.DevHome",
        "MicrosoftCorporationII.QuickAssist",
        "MicrosoftCorporationII.MicrosoftFamily",
        "Microsoft.BingSearch",
        "Microsoft.549981C3F5F10"                   # App Cortana
    )
} else {
    $bloatware += @(
        "Microsoft.GamingApp",          # App Xbox atual (Windows 10/11)
        "Microsoft.Xbox.TCUI",
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxGamingOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.XboxSpeechToTextOverlay"
    )
}

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
# 13. DESATIVAR WIDGET DE NOTÍCIAS
# ============================================
Write-Step "Desativando 'Informações e Notícias' do Windows..."

try {
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds"
    
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    # Desativar completamente o recurso
    Set-ItemProperty -Path $regPath -Name "EnableFeeds" -Type DWord -Value 0 -Force
    
    # Também desativar no usuário atual (reforço)
    $userPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds"
    if (!(Test-Path $userPath)) {
        New-Item -Path $userPath -Force | Out-Null
    }
    Set-ItemProperty -Path $userPath -Name "ShellFeedsTaskbarViewMode" -Type DWord -Value 2 -Force
    
    Write-Success "Widget de Notícias desativado"
} catch {
    Write-Error-Custom "Erro ao desativar Widget de Notícias: $_"
}

# ============================================
# 14. DESATIVAR WINDOWS COPILOT
# ============================================
Write-Step "Desativando Windows Copilot..."

try {
    # 1. Desativar via Política (oficial)
    $copilotPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
    
    if (!(Test-Path $copilotPolicyPath)) {
        New-Item -Path $copilotPolicyPath -Force | Out-Null
    }
    
    Set-ItemProperty -Path $copilotPolicyPath -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force
    
    # 2. Remover botão da barra de tarefas (usuário)
    $userCopilotPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $userCopilotPath -Name "ShowCopilotButton" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    # 3. Remover Copilot AppX (se existir)
    $copilotPackages = Get-AppxPackage -AllUsers | Where-Object {
        $_.Name -match "Copilot"
    }
    
    foreach ($pkg in $copilotPackages) {
        Write-Host "  Removendo pacote: $($pkg.Name)"
        Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }
    
    Write-Success "Copilot desativado/removido"
} catch {
    Write-Error-Custom "Erro ao desativar Copilot: $_"
}

# ============================================
# 15. DESATIVAR XBOX (GAME BAR E GAME DVR)
# ============================================
# Vale para as duas opções. Na corporativa, os serviços Xbox também são desativados
# na etapa 2 e os apps Xbox removidos na etapa 11; na de jogos eles são mantidos.
# Aqui desativamos a gravação de jogos em segundo plano (Game DVR) e a abertura
# da Game Bar pelo botão Xbox do controle.
Write-Step "Desativando Xbox Game Bar e Game DVR..."

try {
    # 1. Bloquear Game DVR via política (vale para todos os usuários)
    $gameDvrPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
    if (!(Test-Path $gameDvrPolicyPath)) {
        New-Item -Path $gameDvrPolicyPath -Force | Out-Null
    }
    Set-ItemProperty -Path $gameDvrPolicyPath -Name "AllowGameDVR" -Type DWord -Value 0 -Force

    # 2. Desativar captura/gravação de jogos (usuário atual)
    $gameDvrUserPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
    if (!(Test-Path $gameDvrUserPath)) {
        New-Item -Path $gameDvrUserPath -Force | Out-Null
    }
    Set-ItemProperty -Path $gameDvrUserPath -Name "AppCaptureEnabled" -Type DWord -Value 0 -Force

    $gameConfigPath = "HKCU:\System\GameConfigStore"
    if (!(Test-Path $gameConfigPath)) {
        New-Item -Path $gameConfigPath -Force | Out-Null
    }
    Set-ItemProperty -Path $gameConfigPath -Name "GameDVR_Enabled" -Type DWord -Value 0 -Force

    # 3. Não abrir a Game Bar pelo botão Xbox do controle (usuário atual)
    $gameBarPath = "HKCU:\Software\Microsoft\GameBar"
    if (!(Test-Path $gameBarPath)) {
        New-Item -Path $gameBarPath -Force | Out-Null
    }
    Set-ItemProperty -Path $gameBarPath -Name "UseNexusForGameBarEnabled" -Type DWord -Value 0 -Force

    Write-Success "Xbox Game Bar e Game DVR desativados"
} catch {
    Write-Error-Custom "Erro ao desativar Xbox Game Bar/Game DVR: $_"
}

# ============================================
# ETAPAS 16 A 18: SOMENTE NA OTIMIZAÇÃO PARA JOGOS (opção 3)
# ============================================
if ($modoJogos) {

# ============================================
# 16. POLÍTICAS DE PRIVACIDADE E TELEMETRIA (JOGOS)
# ============================================
# Base: layout_game\dicas_youtuber_de_extremo_sucesso\telemetria_desativar_gpedit.txt
# São as mesmas políticas do gpedit, gravadas direto no Registro
# (assim funciona também no Windows Home, que não tem gpedit).
# Telemetria, histórico de atividades, Cortana e aviso do Windows Update
# já são aplicados nas etapas 1, 3, 4 e 12.
Write-Step "Aplicando políticas de privacidade e telemetria..."

$polAppCompat = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat"
$polCloud     = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$polSearch    = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
$polWU        = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"

$politicasJogos = @(
    # --- Telemetria e coleta de dados ---
    @{ Path = $polAppCompat; Name = "AITEnable"; Value = 0 }                  # Telemetria de aplicativos
    @{ Path = $polAppCompat; Name = "DisablePCA"; Value = 1 }                 # Auxiliar de Compatibilidade de Programa
    @{ Path = $polAppCompat; Name = "DisableInventory"; Value = 1 }           # Coletor de Inventário
    @{ Path = $polAppCompat; Name = "DisableUAR"; Value = 1 }                 # Gravador de Passos
    # ATENÇÃO: os dois abaixo desligam as correções de compatibilidade de programas antigos.
    # Se algum jogo antigo parar de abrir, apague DisableEngine e SbEnable desta chave.
    @{ Path = $polAppCompat; Name = "DisableEngine"; Value = 1 }              # Mecanismo de Compatibilidade
    @{ Path = $polAppCompat; Name = "SbEnable"; Value = 0 }                   # SwitchBack
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting"; Name = "Disabled"; Value = 1 }        # Relatório de Erros
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting"; Name = "LoggingDisabled"; Value = 1 } # Log de erros
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"; Name = "DisabledByGroupPolicy"; Value = 1 }   # ID de anúncio
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Name = "AllowCrossDeviceClipboard"; Value = 0 }        # Área de transferência entre dispositivos

    # --- Nuvem, conta Microsoft e sincronização ---
    @{ Path = $polCloud; Name = "DisableCloudOptimizedContent"; Value = 1 }      # Conteúdo otimizado em nuvem
    @{ Path = $polCloud; Name = "DisableConsumerAccountStateContent"; Value = 1 } # Conteúdo da conta na nuvem
    @{ Path = $polCloud; Name = "DisableSoftLanding"; Value = 1 }                # Dicas do Windows
    @{ Path = $polCloud; Name = "DisableWindowsConsumerFeatures"; Value = 1 }    # Apps instalados sozinhos
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync"; Name = "DisableSettingSync"; Value = 2 }             # Não sincronizar
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync"; Name = "DisableSettingSyncUserOverride"; Value = 1 } # ...sem o usuário poder religar
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"; Name = "DisableGraphRecentItems"; Value = 1 }          # Recomendados no Explorador
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\PushToInstall"; Name = "DisablePushToInstall"; Value = 1 }                # Instalação por Push

    # --- Pesquisa ---
    @{ Path = $polSearch; Name = "AllowCloudSearch"; Value = 0 }              # Pesquisa na nuvem
    @{ Path = $polSearch; Name = "EnableDynamicContentInWSB"; Value = 0 }     # Destaques de pesquisa
    @{ Path = $polSearch; Name = "AllowSearchToUseLocation"; Value = 0 }      # Pesquisa usando localização
    @{ Path = $polSearch; Name = "AlwaysUseAutoLangDetection"; Value = 0 }    # Detecção automática de idioma
    @{ Path = $polSearch; Name = "DisableWebSearch"; Value = 1 }              # Sem resultados da web (Bing)...
    @{ Path = $polSearch; Name = "ConnectedSearchUseWeb"; Value = 0 }         # ...na pesquisa do Windows
    @{ Path = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"; Name = "DisableSearchBoxSuggestions"; Value = 1 }      # Sugestões web no menu Iniciar

    # --- Localização ---
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"; Name = "DisableWindowsLocationProvider"; Value = 1 } # Localizador do Windows
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors"; Name = "DisableSensors"; Value = 1 }                 # Sensores
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice"; Name = "AllowFindMyDevice"; Value = 0 }                            # Localizar Meu Dispositivo

    # --- Apps da Loja em segundo plano (2 = Forçar Negação) ---
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"; Name = "LetAppsRunInBackground"; Value = 2 }
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy"; Name = "LetAppsAccessBackgroundSpatialPerception"; Value = 2 }

    # --- IA do Windows ---
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableClickToDo"; Value = 1 }      # Click to Do
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"; Name = "DisableSettingsAgent"; Value = 1 }  # Pesquisa com IA nas Configurações

    # --- Voz ---
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Speech"; Name = "AllowSpeechModelUpdate"; Value = 0 }          # Atualização automática de dados de fala

    # --- Widgets ---
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"; Name = "AllowNewsAndInterests"; Value = 0 }              # Widgets
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"; Name = "DisableWidgetsOnLockScreen"; Value = 1 }         # Widgets na tela de bloqueio
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"; Name = "DisableWidgetsBoard"; Value = 1 }                # Quadro de widgets

    # --- Microsoft Edge: não carregar em segundo plano ---
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader"; Name = "AllowTabPreloading"; Value = 0 } # Edge antigo (política do gpedit)
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"; Name = "AllowPrelaunch"; Value = 0 }             # Edge antigo (política do gpedit)
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "StartupBoostEnabled"; Value = 0 }                      # Edge atual: "Startup boost"
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"; Name = "BackgroundModeEnabled"; Value = 0 }                    # Edge atual: rodar em segundo plano

    # --- Microsoft Store ---
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"; Name = "AutoDownload"; Value = 2 }              # Sem atualização automática de apps

    # --- Windows Update ---
    @{ Path = $polWU; Name = "SetUpdateNotificationLevel"; Value = 1 }        # Só avisos de reinício...
    @{ Path = $polWU; Name = "UpdateNotificationLevel"; Value = 1 }           # ...nas notificações
    @{ Path = $polWU; Name = "ExcludeWUDriversInQualityUpdate"; Value = 1 }   # Não trocar o driver da placa de vídeo
    @{ Path = "$polWU\AU"; Name = "NoAutoRebootWithLoggedOnUsers"; Value = 1 } # Sem reinício automático com usuário logado
    @{ Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"; Name = "DODownloadMode"; Value = 0 } # Sem enviar updates para outros PCs (P2P)

    # --- Menu Iniciar ---
    @{ Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"; Name = "NoRecentDocsHistory"; Value = 1 } # Sem histórico de documentos recentes
)

$falhasPoliticas = 0
foreach ($pol in $politicasJogos) {
    try {
        Set-RegistryValue -Path $pol.Path -Name $pol.Name -Value $pol.Value
    } catch {
        $falhasPoliticas++
        Write-Error-Custom "Falha em $($pol.Path)\$($pol.Name): $_"
    }
}
Write-Success "$($politicasJogos.Count - $falhasPoliticas) de $($politicasJogos.Count) políticas aplicadas"

# ============================================
# 17. AJUSTES DE DESEMPENHO PARA JOGOS
# ============================================
Write-Step "Aplicando ajustes de desempenho para jogos..."

try {
    # Modo de Jogo LIGADO (no Windows 10/11 atual ele ajuda)
    Set-RegistryValue "HKCU:\Software\Microsoft\GameBar" "AutoGameModeEnabled" 1
    Set-RegistryValue "HKCU:\Software\Microsoft\GameBar" "AllowAutoGameMode" 1

    # Agendamento de GPU acelerado por hardware (exige reiniciar; ignorado se a placa não suportar)
    Set-RegistryValue "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" "HwSchMode" 2

    # Otimizações para jogos em janela (Windows 11), mantendo outras opções já gravadas
    $dxPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
    $dxAtual = (Get-ItemProperty -Path $dxPath -Name "DirectXUserGlobalSettings" -ErrorAction SilentlyContinue).DirectXUserGlobalSettings
    $dxNovo = ($dxAtual -replace 'SwapEffectUpgradeEnable=\d;', '') + "SwapEffectUpgradeEnable=1;"
    Set-RegistryValue $dxPath "DirectXUserGlobalSettings" $dxNovo "String"

    # Mouse sem aceleração ("Aumentar precisão do ponteiro" desligado)
    Set-RegistryValue "HKCU:\Control Panel\Mouse" "MouseSpeed" "0" "String"
    Set-RegistryValue "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0" "String"
    Set-RegistryValue "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0" "String"

    # Atalhos de acessibilidade desligados (Shift 5x, segurar Shift direito, segurar Num Lock)
    Set-RegistryValue "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" "String"
    Set-RegistryValue "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122" "String"
    Set-RegistryValue "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58" "String"

    # Prioridade para jogos no agendador multimídia do Windows (ganho pequeno, sem risco)
    $mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    Set-RegistryValue $mmPath "SystemResponsiveness" 10
    Set-RegistryValue $mmPath "NetworkThrottlingIndex" 0xFFFFFFFF
    Set-RegistryValue "$mmPath\Tasks\Games" "GPU Priority" 8
    Set-RegistryValue "$mmPath\Tasks\Games" "Priority" 6
    Set-RegistryValue "$mmPath\Tasks\Games" "Scheduling Category" "High" "String"
    Set-RegistryValue "$mmPath\Tasks\Games" "SFIO Priority" "High" "String"

    Write-Success "Ajustes de desempenho aplicados (alguns só valem após reiniciar)"
} catch {
    Write-Error-Custom "Erro nos ajustes de desempenho: $_"
}

# ============================================
# 18. DESATIVAR E DESINSTALAR ONEDRIVE (JOGOS)
# ============================================
Write-Step "Desativando e desinstalando OneDrive..."

try {
    Get-Process OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force

    # Bloquear o OneDrive via política e tirar da inicialização
    Set-RegistryValue "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -ErrorAction SilentlyContinue

    # Desinstalar. Os arquivos que já estão na pasta OneDrive NÃO são apagados.
    $oneDriveSetup = @(
        "$env:SystemRoot\System32\OneDriveSetup.exe",
        "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if ($oneDriveSetup) {
        Start-Process $oneDriveSetup "/uninstall" -Wait
        Write-Success "OneDrive desativado e desinstalado (arquivos da pasta OneDrive mantidos)"
    } elseif (Get-Command winget -ErrorAction SilentlyContinue) {
        winget uninstall --id Microsoft.OneDrive -e --silent --accept-source-agreements | Out-Null
        Write-Success "OneDrive desativado e desinstalado via Winget (arquivos da pasta OneDrive mantidos)"
    } else {
        Write-Host "  Instalador do OneDrive não encontrado; o OneDrive ficou apenas bloqueado"
    }
} catch {
    Write-Error-Custom "Erro ao remover OneDrive: $_"
}

} # FIM das etapas exclusivas para jogos

# ============================================
# 19. BAIXAR PASTA 'MICRO' DO GITHUB PARA DOCUMENTOS (SOMENTE CORPORATIVO)
# (o papel de parede NÃO é aplicado automaticamente)
# ============================================
if (-not $modoJogos) {

Write-Step "Baixando pasta 'micro' do GitHub..."

try {
    # IMPORTANTE: Substitua SEU_USUARIO pelo seu username do GitHub
    $repoZipUrl = "https://github.com/WeslleySantosln/windows-optimizer/archive/refs/heads/main.zip"
    $tempZip = "$env:TEMP\repo.zip"
    $tempExtract = "$env:TEMP\repo_extract"
    
    # Forçar TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Write-Host "  Testando conectividade com GitHub..."
    if (-not (Test-NetConnection github.com -Port 443 -InformationLevel Quiet)) {
        throw "Não foi possível resolver/conectar ao github.com"
    }

    Write-Host "  Baixando repositório..."
    Invoke-WebRequest -Uri $repoZipUrl -OutFile $tempZip -ErrorAction Stop
    
    # Limpar pasta de extração se existir
    if (Test-Path $tempExtract) {
        Remove-Item $tempExtract -Recurse -Force
    }
    
    # Extrair ZIP
    Write-Host "  Extraindo arquivos..."
    Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
    
    # Descobrir automaticamente a pasta raiz extraída
    $repoRoot = Get-ChildItem $tempExtract | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    
    if (-not $repoRoot) {
        throw "Não foi possível identificar a pasta raiz do repositório."
    }
    
    $microSourcePath = Join-Path $repoRoot.FullName "micro"
    
    if (-not (Test-Path $microSourcePath)) {
        Write-Host "  Pasta 'micro' não encontrada no repositório. Pulando esta etapa..."
    } else {
        # Copiar para Documentos
        $documentsPath = [Environment]::GetFolderPath("MyDocuments")
        $microDestPath = Join-Path $documentsPath "micro"
        
        if (Test-Path $microDestPath) {
            Remove-Item $microDestPath -Recurse -Force
        }
        
        Copy-Item -Path $microSourcePath -Destination $microDestPath -Recurse -Force
        Write-Success "Pasta 'micro' copiada para Documentos"
        Write-Host "  Local: $microDestPath"
        Write-Host "  O papel de parede não foi aplicado; a imagem está nessa pasta caso queira usar."
    }
    
    # Limpar arquivos temporários
    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue
    
} catch {
    Write-Error-Custom "Erro ao baixar pasta 'micro': $_"
    Write-Host "  Verifique se o repositório existe e está público"
}

} # FIM pasta 'micro' (somente corporativo)

# ============================================
# 20. LIMPEZA DO SISTEMA
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

} # FIM do if ($executeOptimization)

# ============================================
# INSTALAR GOOGLE CHROME (se selecionado)
# ============================================
if ($installChrome) {
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
}

# ============================================
# FINALIZAÇÃO
# ============================================
Write-ColorOutput Yellow "`n╔═══════════════════════════════════════════════════════════╗"
Write-ColorOutput Yellow "║              PROCESSO CONCLUÍDO COM SUCESSO!              ║"
Write-ColorOutput Yellow "╚═══════════════════════════════════════════════════════════╝"

Write-Host "`n"

if ($executeOptimization) {
    Write-ColorOutput Green "✓ Recall desativado"
    Write-ColorOutput Green "✓ Serviços desnecessários desativados"
    Write-ColorOutput Green "✓ Cortana desativada"
    Write-ColorOutput Green "✓ Telemetria removida"
    Write-ColorOutput Green "✓ Anúncios desativados"
    Write-ColorOutput Green "✓ Widget de Notícias desativado"
    Write-ColorOutput Green "✓ Copilot desativado"
    Write-ColorOutput Green "✓ Apps em segundo plano desativados"
    Write-ColorOutput Green "✓ Efeitos visuais otimizados (melhor desempenho + fontes suaves + sombras)"
    Write-ColorOutput Green "✓ Memória virtual configurada (8GB inicial / 16GB máximo)"
    Write-ColorOutput Green "✓ Hibernação desativada"
    Write-ColorOutput Green "✓ Bloatware removido"
    Write-ColorOutput Green "✓ Windows Update configurado"

    if ($modoJogos) {
        Write-ColorOutput Green "✓ Políticas de privacidade e telemetria aplicadas (lista do gpedit)"
        Write-ColorOutput Green "✓ Plano Desempenho Máximo (USB e PCI Express sem economia de energia)"
        Write-ColorOutput Green "✓ Gravação de jogos (Game DVR) desativada; controle Xbox mantido"
        Write-ColorOutput Green "✓ Modo de Jogo, agendamento de GPU e otimização de jogos em janela ligados"
        Write-ColorOutput Green "✓ Mouse sem aceleração e atalhos de Teclas de Aderência desligados"
        Write-ColorOutput Green "✓ Compactação de memória desativada"
        Write-ColorOutput Green "✓ OneDrive removido"
    } else {
        Write-ColorOutput Green "✓ Privacidade configurada (localização, câmera e microfone mantidos)"
        Write-ColorOutput Green "✓ Xbox desativado (serviços, apps, Game Bar e Game DVR)"
        Write-ColorOutput Green "✓ Alto desempenho ativado"
        Write-ColorOutput Green "✓ Pasta 'micro' baixada para Documentos (papel de parede não aplicado)"
    }

    Write-ColorOutput Green "✓ Sistema limpo"
}

if ($installChrome) {
    Write-ColorOutput Green "✓ Google Chrome instalado"
}

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
