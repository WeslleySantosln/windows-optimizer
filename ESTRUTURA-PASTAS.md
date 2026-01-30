# 📁 Estrutura de Pastas - Windows Optimizer

```
Pasta-Otimizacao/
│
├── Otimizacao-Windows.ps1      ← Script principal
├── Executar-Otimizacao.bat     ← Atalho para execução
│
└── micro/                       ← Pasta com outros arquivos

```

---

## 📦 Sobre a Pasta 'micro'

### O que é?
A pasta **`micro`** é uma pasta **opcional** que você pode colocar no mesmo diretório do script. Se ela existir, será automaticamente copiada para a pasta **Documentos** do seu usuário durante a execução do script.

### Como funciona?

1. **Se a pasta 'micro' existir:**
   - ✅ Script copia todo o conteúdo para `C:\Users\SeuUsuario\Documentos\micro\`
   - ✅ Mantém toda a estrutura de subpastas
   - ✅ Sobrescreve se já existir uma pasta 'micro' em Documentos

2. **Se a pasta 'micro' NÃO existir:**
   - ⚠️ Script apenas avisa que não encontrou
   - ✅ Continua normalmente com as outras otimizações

### O que colocar na pasta 'micro'?

Você pode colocar **qualquer tipo de arquivo** que queira ter sempre disponível após formatar o PC:

```
