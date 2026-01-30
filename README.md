# Script de Otimização Windows Pós-Formatação

## 📋 Descrição

Script PowerShell completo para otimizar o Windows após formatação, incluindo:

- ✅ **Desativação do Recall** (capturas de tela do Copilot)
- ✅ **Remoção de telemetria** e rastreamento
- ✅ **Desativação da Cortana**
- ✅ **Remoção de anúncios** e sugestões
- ✅ **Otimização de desempenho**
- ✅ **Configuração de privacidade** (localização, câmera e microfone mantidos ativos)
- ✅ **Remoção de bloatware**
- ✅ **Modo de energia: Alto Desempenho**
- ✅ **Desativação de serviços desnecessários**
- ✅ **Instalação automática do Google Chrome**
- ✅ **Cópia da pasta 'micro' para Documentos** (se existir)

---

## 🚀 Como Usar

### Método 1: Execução Direta (Recomendado)

1. **Baixe o script** `Otimizacao-Windows.ps1`

2. **Abra o PowerShell como Administrador:**
   - Pressione `Win + X`
   - Selecione "Terminal (Admin)" ou "PowerShell (Admin)"

3. **Navegue até a pasta do script:**
   ```powershell
   cd C:\CaminhoDoScript
   ```

4. **Execute o script:**
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   .\Otimizacao-Windows.ps1
   ```

### Método 2: Atalho para Execução Rápida

Crie um arquivo `.bat` para executar automaticamente:

**`Executar-Otimizacao.bat`**
```batch
@echo off
echo Iniciando otimizacao do Windows...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Otimizacao-Windows.ps1"
pause
```

Basta clicar com o **botão direito** no arquivo `.bat` e selecionar **"Executar como Administrador"**.

---

## ⚙️ O Que o Script Faz

### 1. Desativa o Recall (Windows Copilot)
- Bloqueia capturas automáticas de tela
- Desativa análise de dados por IA
- Remove histórico de atividades

### 2. Desativa Serviços Desnecessários
- **DiagTrack** - Telemetria
- **dmwappushservice** - Telemetria WAP
- **RetailDemo** - Modo demonstração
- **RemoteRegistry** - Registro remoto (segurança)
- **WSearch** - Windows Search (opcional)
- **SysMain** - Superfetch
- **Fax** - Serviço de Fax
- **Xbox Services** - Serviços do Xbox

**NOTA:** Print Spooler é mantido ativo para uso de impressoras.

### 3. Remove Telemetria
- Desativa coleta de dados
- Remove tarefas agendadas de telemetria
- Bloqueia envio de informações para Microsoft

### 4. Desativa Anúncios
- Remove sugestões do menu Iniciar
- Desativa anúncios na tela de bloqueio
- Remove dicas do Windows

### 5. Otimiza Desempenho
- Desativa efeitos visuais desnecessários
- Remove transparência
- Desativa animações
- Ativa modo Alto Desempenho

### 6. Remove Bloatware
Remove aplicativos pré-instalados:
- Xbox
- Skype
- Bing News
- 3D Builder
- Solitaire
- E muitos outros...

### 7. Configura Privacidade
- Localização, câmera e microfone mantidos ativos
- Desativa sincronização
- Remove histórico de atividades

### 8. Instala Programas Essenciais
- **Google Chrome** - Instalação automática via Winget ou download direto

### 9. Copia Pasta 'micro'
- Se existir uma pasta chamada **'micro'** no mesmo diretório do script
- Ela será copiada automaticamente para a pasta **Documentos** do usuário

---

## ⚠️ Requisitos

- Windows 10 ou Windows 11
- PowerShell 5.1 ou superior
- **Executar como Administrador**
- Conexão com internet (para download do Chrome)
- **Opcional:** Pasta `micro` no mesmo diretório do script

---

## 🔄 Reverter Alterações

Se precisar reverter alguma configuração:

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

## 📝 Observações Importantes

1. **Backup recomendado** antes de executar o script
2. **Reinicialização necessária** após a execução
3. Alguns serviços podem não existir em todas as versões do Windows
4. O script é seguro e não remove arquivos pessoais
5. Print Spooler é mantido ativo para impressoras

---

## 🛠️ Personalização

Você pode editar o script para:
- Adicionar/remover serviços da lista
- Incluir instalação automática de programas
- Ajustar configurações de energia
- Personalizar remoção de bloatware

---

## 📌 Dicas Extras

### Instalar programas essenciais automaticamente

Adicione ao final do script:

```powershell
# Instalar Winget (se necessário)
winget install Google.Chrome
winget install Mozilla.Firefox
winget install 7zip.7zip
winget install VideoLAN.VLC
```

### Criar ponto de restauração antes de executar

Adicione no início do script:

```powershell
Checkpoint-Computer -Description "Antes da Otimizacao" -RestorePointType "MODIFY_SETTINGS"
```

---

## 📧 Suporte

Se encontrar algum problema:
1. Verifique se está executando como Administrador
2. Confirme a versão do Windows
3. Revise o log de erros no console do PowerShell

---

## ✅ Checklist Pós-Execução

- [ ] Script executado com sucesso
- [ ] Computador reiniciado
- [ ] Verificar funcionamento de impressoras
- [ ] Testar navegação e programas essenciais
- [ ] Confirmar que anúncios foram removidos

---

**Desenvolvido para otimização pós-formatação do Windows**
**Versão: 1.0**
