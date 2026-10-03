Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Import DDC switch logic
. "$scriptDir\SwitchInput.ps1"

$appVersion = "1.0.0"
$githubRepo = "lendaii/screen-mode"

# C# Form with global hotkeys:
# Ctrl+Alt+1, Ctrl+Alt+2, Win+Alt+1, Win+Alt+2 (Top row and Numpad)
$code = @"
using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;

public class GlobalHotKeyManager : Form {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    public const int WM_HOTKEY = 0x0312;
    public const uint MOD_ALT = 0x0001;
    public const uint MOD_CONTROL = 0x0002;
    public const uint MOD_WIN = 0x0008;

    public Action SwitchToMac;
    public Action SwitchToWindows;

    public GlobalHotKeyManager() {
        this.WindowState = FormWindowState.Minimized;
        this.ShowInTaskbar = false;
        this.Visible = false;
        this.FormBorderStyle = FormBorderStyle.None;
    }

    protected override void OnHandleCreated(EventArgs e) {
        base.OnHandleCreated(e);
        
        // Modifiers:
        // Ctrl + Alt = 0x0003
        // Win + Alt  = 0x0009

        // 1 & Numpad 1 -> Mac (id 101, 102, 103, 104)
        RegisterHotKey(this.Handle, 101, 0x0003, 0x31); // Ctrl+Alt+1
        RegisterHotKey(this.Handle, 102, 0x0003, 0x61); // Ctrl+Alt+Num1
        RegisterHotKey(this.Handle, 103, 0x0009, 0x31); // Win+Alt+1
        RegisterHotKey(this.Handle, 104, 0x0009, 0x61); // Win+Alt+Num1

        // 2 & Numpad 2 -> Windows (id 201, 202, 203, 204)
        RegisterHotKey(this.Handle, 201, 0x0003, 0x32); // Ctrl+Alt+2
        RegisterHotKey(this.Handle, 202, 0x0003, 0x62); // Ctrl+Alt+Num2
        RegisterHotKey(this.Handle, 203, 0x0009, 0x32); // Win+Alt+2
        RegisterHotKey(this.Handle, 204, 0x0009, 0x62); // Win+Alt+Num2
    }

    protected override void WndProc(ref Message m) {
        if (m.Msg == WM_HOTKEY) {
            int id = m.WParam.ToInt32();
            if (id >= 101 && id <= 104) {
                try { System.Media.SystemSounds.Beep.Play(); } catch {}
                SwitchToMac?.Invoke();
            } else if (id >= 201 && id <= 204) {
                try { System.Media.SystemSounds.Beep.Play(); } catch {}
                SwitchToWindows?.Invoke();
            }
        }
        base.WndProc(ref m);
    }
}
"@

Add-Type -TypeDefinition $code -Language CSharp -IgnoreWarnings

# Create Tray Icon
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Icon = [System.Drawing.SystemIcons]::Application
$notifyIcon.Text = "SCREEN MODE v$appVersion (Mac / Windows)"
$notifyIcon.Visible = $true

$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip

$header = $contextMenu.Items.Add("🖥️ SCREEN MODE v$appVersion (155Hz)")
$header.Enabled = $false

# Item dinâmico de atualização
$updateItem = $contextMenu.Items.Add("✨ Nova Atualização Disponível! (Baixar)")
$updateItem.Visible = $false
$updateItem.Add_Click({
    if ($this.Tag) {
        [System.Diagnostics.Process]::Start($this.Tag)
    }
})

$contextMenu.Items.Add("-") | Out-Null

# Mac no USB-C (27)
$itemMac = $contextMenu.Items.Add("🍎 Screen Mac [Ctrl+Alt+1] (USB-C)")
$itemMac.Add_Click({
    [MonitorManager]::SetInputSource(27)
})

# Windows no DisplayPort 1 (15)
$itemWin = $contextMenu.Items.Add("💻 Screen Windows [Ctrl+Alt+2] (DP)")
$itemWin.Add_Click({
    [MonitorManager]::SetInputSource(15)
})

$contextMenu.Items.Add("-") | Out-Null

# Checar atualizações
$itemCheckUpdates = $contextMenu.Items.Add("🔄 Verificar Atualizações...")
$itemCheckUpdates.Add_Click({
    Check-ForUpdates -Silent $false
})

$itemExit = $contextMenu.Items.Add("Encerrar SCREEN MODE")
$itemExit.Add_Click({
    $notifyIcon.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})

$notifyIcon.ContextMenuStrip = $contextMenu

function Check-ForUpdates {
    param([bool]$Silent = $true)
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        $url = "https://api.github.com/repos/$githubRepo/releases/latest"
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "SCREEN-MODE-Windows")
        $jsonStr = $wc.DownloadString($url)
        $json = $jsonStr | ConvertFrom-Json
        $latest = $json.tag_name -replace '^[vV]', ''
        
        if ([System.Version]$latest -gt [System.Version]$appVersion) {
            $notifyIcon.ShowBalloonTip(6000, "SCREEN MODE", "Nova versão v$latest disponível! Clique para baixar.", [System.Windows.Forms.ToolTipIcon]::Info)
            $updateItem.Visible = $true
            $updateItem.Text = "✨ Nova Versão: v$latest (Baixar)"
            $updateItem.Tag = $json.html_url
        } elseif (-not $Silent) {
            [System.Windows.Forms.MessageBox]::Show("Você já está usando a versão mais recente (v$appVersion)!", "SCREEN MODE", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    } catch {
        if (-not $Silent) {
            [System.Windows.Forms.MessageBox]::Show("Não foi possível verificar atualizações no momento.", "SCREEN MODE", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
    }
}

# Checar atualizações automaticamente em segundo plano
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 5000 # Checar 5s após abrir
$timer.Add_Tick({
    $timer.Stop()
    Check-ForUpdates -Silent $true
})
$timer.Start()

# Instantiate Hotkey Manager
$hotKeyManager = New-Object GlobalHotKeyManager
$hotKeyManager.SwitchToMac = [Action]{
    [MonitorManager]::SetInputSource(27)
}
$hotKeyManager.SwitchToWindows = [Action]{
    [MonitorManager]::SetInputSource(15)
}

# Keep running
[System.Windows.Forms.Application]::Run($hotKeyManager)
