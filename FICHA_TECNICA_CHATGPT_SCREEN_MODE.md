# 🚀 FICHA TÉCNICA OFICIAL & BRIEFING DO PROJETO SCREEN MODE
> **Instruções para o ChatGPT / Codex GPT:** Você está atuando como Arquiteto de Software e Designer UI/UX sênior do projeto **SCREEN MODE**. O usuário deseja fazer um **upgrade visual (modo picture / mockups de interface)** e de funcionalidades no aplicativo. Leia este documento com atenção máxima para entender todo o funcionamento, a arquitetura de hardware, os códigos e as regras do software.

---

## 1. VISÃO GERAL DO PROJETO

- **Nome Oficial:** SCREEN MODE
- **Versão Atual:** `v1.0.0`
- **Repositório Oficial no GitHub:** [https://github.com/WennyLife/screen-mode](https://github.com/WennyLife/screen-mode)
- **Desenvolvedor:** WennyLife
- **Plataformas:** 
  - 🍏 **macOS:** Aplicativo nativo em Swift (Menu Bar / Barra de Menus)
  - 🪟 **Windows 10/11:** Companion App nativo em PowerShell + Win32 Tray Icon (Bandeja do Sistema)
- **Hardware Principal:**
  - **Monitor:** MSI MAG401QR (Ultrawide 40 polegadas, resolução 3440 x 1440 @ 155Hz nativos com DP OverClocking).
  - **MacBook:** Conectado via 1 único cabo USB-C Thunderbolt 40Gbps (Vídeo 155Hz + Carregamento 65W Power Delivery + Passagem de Mouse/Teclado via KVM interno do monitor).
  - **PC Windows:** Conectado via DisplayPort (Vídeo 155Hz) + Cabo USB-B (upstream de impressora) para o KVM USB.
  - **Teclado:** Logitech Signature K650 (Travado em modo macOS via `Fn + O` por 3s).

---

## 2. ARQUITETURA TÉCNICA DO SOFTWARE

### A. Versão macOS (`src/main.swift`):
- **Interface:** `NSStatusItem` com ícone de monitor na barra de menus superior do macOS.
- **Mecanismo de Troca:** Protocolo DDC/CI direto via cabo de vídeo (VCP Code `0x60` / Input Source):
  - **Entrada USB-C (Mac):** Valor VCP `27`
  - **Entrada DisplayPort 1 (Windows):** Valor VCP `15`
  - Utiliza o binário embutido `m1ddc` compilado para Apple Silicon (`/Contents/Resources/m1ddc`).
- **Atalhos Globais sem Foco:**
  - Registrados via **Carbon Event Manager** com target global `GetEventDispatcherTarget()` (funciona mesmo sem janela aberta):
    - `Cmd + Option + 2`: Pula instantaneamente para o Windows (funciona no número `2` superior E no teclado numérico `Keypad 2`).
    - `Cmd + Option + 1`: Pula para o Mac (número `1` superior E `Keypad 1`).
- **Execução Otimizada:** Executado de forma assíncrona em fila de prioridade alta (`DispatchQueue.global(qos: .userInitiated)`), eliminando qualquer delay de clique duplo.
- **Auto-Updater Integrado:** Checa a API do GitHub (`https://api.github.com/repos/WennyLife/screen-mode/releases/latest`) e exibe banner/botão de download no topo do menu quando uma nova versão é lançada.

### B. Versão Windows (`windows/`):
- **Mecanismo de Troca:** PowerShell chamando a API nativa Win32 `dxva2.dll` (`SetVCPFeature` com VCP `0x60`).
- **Bandeja do Sistema (`ScreenMode_Tray.ps1`):** Ícone na área de notificação do Windows com menu interativo.
- **Atalhos Globais no Windows:**
  - Registrados via Win32 `RegisterHotKey`:
    - `Ctrl + Alt + 1`: Alterna para o Mac.
    - `Ctrl + Alt + 2`: Alterna para o Windows.
- **Instalador em 1 Clique (`Instalar_SCREEN_MODE.bat`):**
  - Instala em `%LOCALAPPDATA%\ScreenMode`.
  - Cria atalhos na Área de Trabalho com ícones próprios e hotkeys do sistema.
  - Configura inicialização silenciosa automática via VBScript em `shell:startup`.
- **Auto-Updater Windows:** Checa a API do GitHub via `Net.WebClient` e notifica na bandeja.

---

## 3. OBJETIVO DO UPGRADE (SOLICITADO PELO USUÁRIO)

O usuário deseja fazer um **upgrade de design e experiência visual** (UI/UX) para o **SCREEN MODE**, com geração de maquetes visuais (modo Picture / DALL-E / UI Concepts).

### Demandas para a Nova Interface (UI Upgrade):
1. **Painel Flutuante Moderno (Glassmorphism Escuro):**
   - Transição de um simples menu texto para um **Popover Flutuante Premium** (estilo Control Center da Apple / macOS Sequoia).
   - Fundo translúcido com `backdrop-blur`, bordas ultrafinas com brilho sutil (slate-800 / indigo neon).
2. **Visualizador Gráfico do Monitor Ultrawide:**
   - Ilustração dinâmica de um monitor curvo ultrawide no topo do painel.
   - Destaque interativo mostrando qual entrada está ativa no momento:
     - 🍏 **Modo Mac Ativo:** Luz ciano/azul, badge `USB-C 155Hz`, ícone Apple.
     - 💻 **Modo PC Ativo:** Luz roxa/magenta, badge `DisplayPort 155Hz`, ícone Windows.
3. **Botões de Alternância Grandes & Táteis:**
   - Dois cards principais clicáveis lado a lado:
     - **Card Mac:** "MacBook Pro" • `Cmd + ⌥ + 1` • 155Hz
     - **Card Windows:** "Gaming PC" • `Cmd + ⌥ + 2` • 155Hz
   - Animação de transição suave ao clicar ou usar o atalho.
4. **Mini Widget de Telemetria / Status da Conexão:**
   - Taxa de quadros detectada (`155 Hz`).
   - Resolução ativa (`3440 x 1440`).
   - Status da porta DDC/CI (`Conectado`).
   - Status do Auto-Update (`Versão v1.0.0 - Atualizado`).

---

## 4. PROMPTS PRONTOS PARA O "MODO PICTURE" (GERAÇÃO DE IMAGENS DE UI)

Se for gerar imagens ou mockups conceituais no ChatGPT/DALL-E para o usuário avaliar a nova interface, use a seguinte estrutura de prompt:

```text
A sleek, hyper-modern macOS Menu Bar Popover application UI mockup named "SCREEN MODE". Dark mode glassmorphism interface with deep slate background, frosted glass blur, and elegant neon purple and cyan accents. At the top, a miniature 3D graphic of a 40-inch curved ultrawide monitor with glowing indicators for macOS and Windows. Below it, two large interactive segmented control cards: "MacBook Pro (USB-C 155Hz)" with Cmd+Opt+1 badge, and "Gaming PC (DisplayPort 155Hz)" with Cmd+Opt+2 badge. A bottom status bar displaying "3440x1440 @ 155Hz | DDC/CI Active". Premium Apple design language, typography in San Francisco font, pixel-perfect UI/UX design, 8k render.
```

---

## 5. ESTRUTURA ATUAL DE ARQUIVOS DO PROJETO

```text
/Users/lendaii/Movies/antigravity/screen-mode/
├── README.md                           # Documentação completa em Markdown com badges e links diretos
├── LICENSE                             # Licença MIT
├── assets/
│   ├── banner.jpg                      # Banner widescreen com diagrama de hardware
│   └── story.jpg                       # Arte vertical 9:16 para Instagram Stories
├── src/
│   └── main.swift                      # Código-fonte principal do app macOS com Auto-Updater e Carbon HotKeys
├── windows/
│   ├── ScreenMode_Tray.ps1             # App de bandeja do Windows com Auto-Updater e atalhos
│   ├── SwitchInput.ps1                 # Script de controle DDC/CI Win32
│   ├── Instalar_SCREEN_MODE.bat        # Instalador automático 1-click
│   ├── Desinstalar_SCREEN_MODE.bat     # Desinstalador limpo
│   ├── Iniciar_ScreenMode_Windows.vbs  # Launcher em background sem tela preta
│   ├── Screen_Mac.bat                  # Atalho de execução rápida para Mac
│   └── Screen_Windows.bat              # Atalho de execução rápida para Windows
└── release/
    ├── SCREEN_MODE_macOS.dmg           # Instalador empacotado para Mac
    └── SCREEN_MODE_Windows.zip         # Pacote completo zipado para Windows
```

---

## 6. DIRETRIZES PARA O CHATGPT
- Respeite a arquitetura existente: não quebre a compatibilidade dos atalhos nem a engine DDC/CI.
- Forneça sugestões de design visual para a maquete e o código Swift (usando `NSPopover` e `NSHostingView` com SwiftUI ou AppKit moderno) para tornar a interface visualmente espetacular.
