# 🚀 Windows Optimization Script - Pós-Formatação

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?logo=powershell)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-active-success)

Script completo de otimização do Windows para ser executado após formatação. Remove bloatware, desativa telemetria, otimiza desempenho e configura privacidade.

---

## ✨ Recursos

- ✅ **Desativa Windows Recall** (capturas de tela do Copilot)
- ✅ **Remove telemetria e rastreamento**
- ✅ **Desativa Cortana**
- ✅ **Remove anúncios e sugestões**
- ✅ **Remove bloatware pré-instalado**
- ✅ **Otimiza desempenho visual**
- ✅ **Configura modo Alto Desempenho**
- ✅ **Desativa hibernação** (libera espaço em disco)
- ✅ **Desativa serviços desnecessários**
- ✅ **Configura privacidade** (mantém localização, câmera e microfone ativos)
- ✅ **Limpa arquivos temporários**
- ✅ **Instala Google Chrome automaticamente**
- ✅ **Copia pasta 'micro' para Documentos** (se existir)

---

## 🎯 Instalação Rápida

### Método 1: Execução Direta (Recomendado)

Abra o **PowerShell como Administrador** e execute:

```powershell
irm https://raw.githubusercontent.com/SEU-USUARIO/windows-optimizer/main/Otimizacao-Windows.ps1 | iex
```

### Método 2: Usando o Instalador

```powershell
irm https://raw.githubusercontent.com/SEU-USUARIO/windows-optimizer/main/install.ps1 | iex
```

### Método 3: Download Manual

```powershell
# Baixar o script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SEU-USUARIO/windows-optimizer/main/Otimizacao-Windows.ps1" -OutFile "Otimizacao-Windows.ps1"

# Executar
Set-ExecutionPolicy Bypass -Scope Process -Force
.\Otimizacao-Windows.ps1
```

---

## 📋 O Que o Script Faz

### 🛡️ Privacidade e Segurança

| Ação | Descrição |
|------|-----------|
| **Desativa Recall** | Bloqueia capturas automáticas de tela do Windows Copilot |
| **Remove Telemetria** | Desativa coleta de dados pela Microsoft |
| **Desativa Cortana** | Remove assistente virtual |
| **Configura Privacidade** | Mantém localização, câmera e microfone ativos (conforme necessidade do usuário) |
| **Remove Activity History** | Desativa histórico de atividades |

### ⚡ Desempenho

| Ação | Descrição |
|------|-----------|
| **Alto Desempenho** | Ativa plano de energia máximo |
| **Desativa Efeitos Visuais** | Remove animações e transparências |
| **Desativa Hibernação** | Libera espaço em disco (até 8GB+) |
| **Otimiza Serviços** | Desativa serviços desnecessários |
| **Desativa Superfetch** | Otimização para SSDs |

### 🧹 Limpeza

| Ação | Descrição |
|------|-----------|
| **Remove Bloatware** | Xbox, Skype, Candy Crush, etc |
| **Remove Anúncios** | Bloqueia sugestões do Windows |
| **Limpa Temp** | Remove arquivos temporários |
| **Limpa Windows Update** | Limpa cache de atualizações |

### 📦 Instalação Automática

| Ação | Descrição |
|------|-----------|
| **Google Chrome** | Instala automaticamente via Winget ou download direto |
| **Pasta 'micro'** | Copia pasta 'micro' (se existir) para Documentos do usuário |

---

## 🔧 Serviços Desativados

O script desativa os seguintes serviços com segurança:

- **DiagTrack** - Telemetria
- **dmwappushservice** - Telemetria WAP
- **RetailDemo** - Modo demonstração
- **RemoteRegistry** - Registro remoto (segurança)
- **WSearch** - Windows Search (opcional)
- **SysMain** - Superfetch
- **Fax** - Serviço de Fax
- **Xbox Services** - Serviços Xbox (todos)

**🖨️ NOTA:** O serviço **Print Spooler** é mantido ativo para uso de impressoras.

---

## 📱 Apps Removidos (Bloatware)

- Microsoft 3D Builder
- Bing News & Weather
- Microsoft Office Hub
- Solitaire Collection
- Xbox (todos os apps)
- Skype
- People
- Your Phone
- Zune Music & Video
- E muitos outros...

---

## ⚙️ Requisitos

- Windows 10 ou Windows 11
- PowerShell 5.1 ou superior
- **Executar como Administrador**
- Conexão com internet (para download do Chrome)
- **Opcional:** Pasta `micro` na mesma localização do script (será copiada para Documentos)

---

## 📁 Estrutura Recomendada

```
Pasta de Execução/
│
├── Otimizacao-Windows.ps1      # Script principal
├── micro/                       # Pasta opcional (será copiada para Documentos)
│   ├── arquivo1.txt
│   └── arquivo2.pdf
└── Executar-Otimizacao.bat     # Atalho opcional
```

---

## 🚨 Avisos Importantes

1. ⚠️ **Execute como Administrador** - Obrigatório
2. 🔄 **Reinicialização necessária** após execução
3. 💾 **Backup recomendado** antes de executar
4. 📖 **Leia o código** antes de executar em produção
5. 🖨️ **Print Spooler** é mantido ativo
6. 🌐 **Google Chrome** será instalado automaticamente
7. 📹 **Localização, câmera e microfone** permanecem ativos
8. 📁 **Pasta 'micro'** (se existir) será copiada para Documentos

---

## 🔄 Reverter Alterações

### Reativar um serviço:
```powershell
Set-Service -Name "NomeDoServico" -StartupType Automatic
Start-Service -Name "NomeDoServico"
```

### Reativar Windows Search:
```powershell
Set-Service -Name "WSearch" -StartupType Automatic
Start-Service -Name "WSearch"
```

### Reativar Cortana:
```powershell
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana"
```

---

## 📊 Comparação Antes/Depois

| Métrica | Antes | Depois |
|---------|-------|--------|
| Apps Pré-instalados | ~30 | ~10 |
| Serviços Ativos | ~200 | ~180 |
| Espaço em Disco | - | +8GB (hibernação) |
| Telemetria | Ativa | Desativada |
| Anúncios | Vários | Nenhum |
| Privacidade | Baixa | Alta |

---

## 🛠️ Personalização

Você pode editar o script `Otimizacao-Windows.ps1` para:

- Adicionar/remover serviços
- Incluir instalação de programas via Winget
- Ajustar configurações de energia
- Personalizar remoção de bloatware

### Exemplo: Instalar programas automaticamente

Adicione ao final do script:

```powershell
# Instalar programas essenciais
winget install Google.Chrome
winget install Mozilla.Firefox
winget install 7zip.7zip
winget install VideoLAN.VLC
```

---

## 📁 Estrutura do Repositório

```
windows-optimizer/
│
├── Otimizacao-Windows.ps1      # Script principal
├── install.ps1                  # Instalador rápido
├── Executar-Otimizacao.bat     # Atalho para execução local
├── README.md                    # Este arquivo
└── GUIA-GITHUB.md              # Guia de uso avançado
```

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se livre para:

1. Fazer um Fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abrir um Pull Request

---

## 📝 Changelog

### v1.0.0 - 2025-01-30
- ✅ Versão inicial
- ✅ Desativação do Windows Recall
- ✅ Remoção de telemetria
- ✅ Otimização de desempenho
- ✅ Remoção de bloatware
- ✅ Configuração de privacidade

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

## ⭐ Suporte

Se este script foi útil para você, considere dar uma ⭐ no repositório!

---

## 📧 Contato

Encontrou algum bug ou tem sugestões? Abra uma [Issue](https://github.com/SEU-USUARIO/windows-optimizer/issues)!

---

## 🔗 Links Úteis

- [Documentação do PowerShell](https://docs.microsoft.com/powershell/)
- [Windows Group Policy Reference](https://docs.microsoft.com/windows/client-management/mdm/)
- [Privacy Settings in Windows](https://support.microsoft.com/windows/windows-privacy-settings-3e912f30-6142-4c6b-8ecd-a4d21f054f4c)

---

**Desenvolvido para otimização pós-formatação do Windows**

**⚡ Rápido • 🛡️ Seguro • 🎯 Eficiente**
