# 🖥️ SCREEN MODE

<div align="center">

![SCREEN MODE](assets/banner.jpg)

### O alternador inteligente de monitores Ultrawide entre Mac e Windows a 155Hz

[![macOS](https://img.shields.io/badge/macOS-12.0+-blue?style=for-the-badge&logo=apple)](https://github.com/WennyLife/screen-mode)
[![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-0078D6?style=for-the-badge&logo=windows)](https://github.com/WennyLife/screen-mode)
[![Taxa](https://img.shields.io/badge/Refresh%20Rate-155Hz%20Nativo-purple?style=for-the-badge)](https://github.com/WennyLife/screen-mode)
[![License](https://img.shields.io/badge/Licen%C3%A7a-MIT-green?style=for-the-badge)](LICENSE)
[![Auto-Update](https://img.shields.io/badge/Auto--Update-Integrado-orange?style=for-the-badge)](https://github.com/WennyLife/screen-mode)

**Alterne instantaneamente entre seu Mac e seu PC Windows com apenas 1 clique ou atalho de teclado global, aproveitando os 155Hz nativos do seu monitor sem precisar de nenhum switch KVM físico!**

[Download macOS (.dmg)](https://github.com/WennyLife/screen-mode/raw/main/release/SCREEN_MODE_macOS.dmg) • [Download Windows (.zip)](https://github.com/WennyLife/screen-mode/raw/main/release/SCREEN_MODE_Windows.zip)

</div>

---

## 🌟 Principais Recursos

* ⚡ **Alternância Instantânea em 1 Toque:** Mude entre macOS e Windows via protocolo DDC/CI direto pelo cabo de vídeo.
* ⌨️ **Atalhos Globais de Teclado:**
  * No Mac ➔ **`Cmd + Option + 2`** pula para o Windows.
  * No Windows ➔ **`Ctrl + Alt + 1`** pula para o Mac.
  * *Compatível tanto com a fileira de números de cima quanto com o Teclado Numérico (Numpad)!*
* 🚀 **155Hz Nativos em Ambas as Máquinas:**
  * Mac no cabo **USB-C Thunderbolt** (155Hz + 65W Power Delivery + Mouse/Teclado).
  * Windows no cabo **DisplayPort** (155Hz máximos).
* 🔄 **Sistema de Auto-Update Integrado:** O aplicativo checa automaticamente novidades no GitHub Releases e avisa no topo do menu quando uma nova versão estiver disponível!
* 🛠️ **Zero Hardware Adicional:** Não compre switches KVM caros que limitam a taxa para 60Hz. O controle é 100% digital e sem lag.

---

## 📐 Como Funciona a Conexão

```mermaid
flowchart TD
    subgraph Monitor["🖥️ Monitor Ultrawide (MSI MAG401QR 155Hz)"]
        USB_C["Entrada USB-C (155Hz)"]
        DP["Entrada DisplayPort (155Hz)"]
        KVM["KVM Automático USB"]
    end

    subgraph Mac["🍎 Apple Mac"]
        MacPort["Porta Thunderbolt / USB-C"]
    end

    subgraph PC["💻 PC Windows"]
        GPU["Placa de Vídeo DisplayPort"]
        USBB["Cabo USB-B (Impressora)"]
    end

    MacPort <== "1 Único Cabo USB-C (Vídeo 155Hz + Carga 65W + Mouse)" ==> USB_C
    GPU <== "Cabo DisplayPort (155Hz)" ==> DP
    USBB <== "Dados do Mouse / Teclado" ==> KVM

    classDef mac fill:#0071e3,stroke:#fff,stroke-width:2px,color:#fff;
    classDef win fill:#0078d6,stroke:#fff,stroke-width:2px,color:#fff;
    classDef mon fill:#6f42c1,stroke:#fff,stroke-width:2px,color:#fff;
    class Mac mac;
    class PC win;
    class Monitor mon;
```

---

## 🍎 Instalação no macOS

1. Baixe o instalador oficial: **[`SCREEN_MODE_macOS.dmg`](release/SCREEN_MODE_macOS.dmg)**.
2. Dê dois cliques no `.dmg` e **arraste o ícone do SCREEN MODE para a pasta Aplicativos**.
3. Abra o **SCREEN MODE** pelo Launchpad ou Spotlight.
4. O ícone 🖥️ aparecerá na sua **Barra de Menus** (perto do relógio).

### Atalhos no Mac:
* **Ir para o Windows:** `Cmd + Option + 2` *(ou pelo menu superior)*.
* **Voltar para o Mac:** `Cmd + Option + 1`.

---

## 🪟 Instalação no Windows

1. Baixe o pacote: **[`SCREEN_MODE_Windows.zip`](release/SCREEN_MODE_Windows.zip)**.
2. Extraia o arquivo `.zip` no seu PC.
3. Dê dois cliques no arquivo **`Instalar_SCREEN_MODE.bat`**.
4. O instalador automático irá:
   * Instalar o SCREEN MODE no seu sistema.
   * Criar os atalhos **🍎 Screen Mac (155Hz)** e **💻 Screen Windows (155Hz)** na sua Área de Trabalho.
   * Ativar o ícone na bandeja do sistema (perto do relógio).
   * Configurar a inicialização automática junto com o Windows.

### Atalhos no Windows:
* **Voltar para o Mac:** `Ctrl + Alt + 1` *(ou dê 2 cliques no atalho da Área de Trabalho)*.
* **Ir para o Windows:** `Ctrl + Alt + 2`.

---

## 🔄 Sistema de Atualização Automática (Auto-Updater)

O **SCREEN MODE** possui integração nativa com o **GitHub Releases**:
* A cada inicialização (e periodicamente em segundo plano), o app verifica se existe uma versão mais recente.
* Se houver nova versão, um banner destacado aparece no topo do menu:
  `✨ Nova Versão Disponível (vX.X)! Clique para Atualizar`
* Você também pode clicar em **`🔄 Verificar Atualizações...`** no menu a qualquer momento.

---

## ⚙️ Configurações Recomendadas no Monitor (MSI MAG401QR)

Para a melhor experiência sem falhas:
1. **Auto Scan:** Deixe em **ON** (Ligado) no menu OSD do monitor. Se uma máquina for desligada, o monitor acha a outra sozinho.
2. **DP OverClocking:** Deixe em **ON** para liberar os **155Hz** no painel.
3. **KVM:** Deixe em **Auto** para o mouse e teclado acompanharem a troca de imagem.

---

## 📄 Licença

Distribuído sob a licença **MIT**. Veja [`LICENSE`](LICENSE) para mais detalhes.
