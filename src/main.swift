import Cocoa
import Foundation
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?
    var statusItem: NSStatusItem!
    let defaults = UserDefaults.standard

    // Versão do Aplicativo
    let appVersion = "1.0.0"

    // Repositório GitHub para checar atualizações
    var githubRepo: String {
        get {
            return defaults.string(forKey: "githubRepo") ?? "lendaii/screen-mode"
        }
        set {
            defaults.set(newValue, forKey: "githubRepo")
        }
    }

    var updateAvailableVersion: String? = nil
    var updateAvailableUrl: String? = nil

    var hotKeyRefWindows: EventHotKeyRef?
    var hotKeyRefWindowsNumpad: EventHotKeyRef?
    var hotKeyRefMac: EventHotKeyRef?
    var hotKeyRefMacNumpad: EventHotKeyRef?

    // Default VESA VCP 0x60 input values:
    // DisplayPort 1 = 15, DisplayPort 2 = 16, HDMI 1 = 17, HDMI 2 = 18, USB-C = 27
    var windowsInput: Int {
        get {
            let val = defaults.integer(forKey: "windowsInput")
            return val != 0 ? val : 15 // Default DisplayPort 1
        }
        set {
            defaults.set(newValue, forKey: "windowsInput")
            rebuildMenu()
        }
    }

    var macInput: Int {
        get {
            let val = defaults.integer(forKey: "macInput")
            return val != 0 ? val : 27 // Default USB-C Ugreen
        }
        set {
            defaults.set(newValue, forKey: "macInput")
            rebuildMenu()
        }
    }

    func portName(for code: Int) -> String {
        switch code {
        case 15: return "DisplayPort 1"
        case 16: return "DisplayPort 2"
        case 17: return "HDMI 1"
        case 18: return "HDMI 2"
        case 27: return "USB-C"
        default: return "Porta \(code)"
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            if let image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "SCREEN MODE") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "🖥️"
            }
            button.toolTip = "SCREEN MODE v\(appVersion) (Mac / Windows)"
        }

        // Atualizar preferências para Windows em DisplayPort (15) e Mac em USB-C (27)
        if !defaults.bool(forKey: "configured_dp_windows_v3") {
            defaults.set(15, forKey: "windowsInput")
            defaults.set(27, forKey: "macInput")
            defaults.set(true, forKey: "configured_dp_windows_v3")
        }

        registerGlobalHotkeys()
        rebuildMenu()

        // Verificar atualizações automaticamente após 3 segundos da inicialização
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.checkForUpdates(silent: true)
        }

        // Timer para checar a cada 4 horas em segundo plano
        Timer.scheduledTimer(withTimeInterval: 14400, repeats: true) { [weak self] _ in
            self?.checkForUpdates(silent: true)
        }
    }

    func registerGlobalHotkeys() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetEventDispatcherTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            GetEventParameter(theEvent, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            
            if hotKeyID.id == 2 {
                DispatchQueue.main.async {
                    NSSound.beep()
                    AppDelegate.shared?.handleSwitchWindows()
                }
            } else if hotKeyID.id == 1 {
                DispatchQueue.main.async {
                    NSSound.beep()
                    AppDelegate.shared?.handleSwitchMac()
                }
            }
            return noErr
        }, 1, &eventType, nil, nil)

        // Cmd + Option (Alt)
        let gModifier = UInt32(cmdKey | optionKey)
        
        // Cmd + Option + 2 -> Screen Windows (Fileira de cima E Teclado Numérico)
        RegisterEventHotKey(UInt32(kVK_ANSI_2), gModifier, EventHotKeyID(signature: OSType(0x5357494E), id: 2), GetEventDispatcherTarget(), 0, &hotKeyRefWindows)
        RegisterEventHotKey(UInt32(kVK_ANSI_Keypad2), gModifier, EventHotKeyID(signature: OSType(0x5357494E), id: 2), GetEventDispatcherTarget(), 0, &hotKeyRefWindowsNumpad)

        // Cmd + Option + 1 -> Screen Mac (Fileira de cima E Teclado Numérico)
        RegisterEventHotKey(UInt32(kVK_ANSI_1), gModifier, EventHotKeyID(signature: OSType(0x534D4143), id: 1), GetEventDispatcherTarget(), 0, &hotKeyRefMac)
        RegisterEventHotKey(UInt32(kVK_ANSI_Keypad1), gModifier, EventHotKeyID(signature: OSType(0x534D4143), id: 1), GetEventDispatcherTarget(), 0, &hotKeyRefMacNumpad)
    }

    func getM1ddcPath() -> String {
        let bundlePath = Bundle.main.bundlePath
        let candidates = [
            Bundle.main.resourcePath?.appending("/m1ddc"),
            bundlePath + "/Contents/Resources/m1ddc",
            bundlePath + "/m1ddc",
            "/Users/lendaii/Movies/antigravity/ScreenSwitcher/bin/m1ddc",
            "/usr/local/bin/m1ddc",
            "/opt/homebrew/bin/m1ddc"
        ]
        for path in candidates {
            if let p = path, FileManager.default.isExecutableFile(atPath: p) {
                return p
            }
        }
        return "/tmp/m1ddc/m1ddc"
    }

    func switchInput(to inputCode: Int, name: String) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let m1ddc = self.getM1ddcPath()

            let process = Process()
            process.executableURL = URL(fileURLWithPath: m1ddc)
            process.arguments = ["display", "1", "set", "input", "\(inputCode)"]

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()
                process.waitUntilExit()
                print("Switched input to \(name) (\(inputCode)), exit code: \(process.terminationStatus)")
            } catch {
                print("Failed to run m1ddc: \(error)")
            }
        }
    }

    @objc func handleSwitchWindows() {
        switchInput(to: windowsInput, name: "Windows (\(portName(for: windowsInput)))")
    }

    @objc func handleSwitchMac() {
        switchInput(to: macInput, name: "Mac (\(portName(for: macInput)))")
    }

    // Windows port selection
    @objc func setWindowsDP1() { windowsInput = 15 }
    @objc func setWindowsHDMI1() { windowsInput = 17 }
    @objc func setWindowsHDMI2() { windowsInput = 18 }

    // Mac port selection
    @objc func setMacUSBC() { macInput = 27 }
    @objc func setMacDP1() { macInput = 15 }
    @objc func setMacHDMI1() { macInput = 17 }

    // Testing actions
    @objc func testDP1() { switchInput(to: 15, name: "Teste DisplayPort 1") }
    @objc func testHDMI1() { switchInput(to: 17, name: "Teste HDMI 1") }
    @objc func testHDMI2() { switchInput(to: 18, name: "Teste HDMI 2") }
    @objc func testUSBC() { switchInput(to: 27, name: "Teste USB-C") }

    // MARK: - Auto-Updater Logic
    func isVersion(_ v1: String, greaterThan v2: String) -> Bool {
        let clean1 = v1.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))
        let clean2 = v2.trimmingCharacters(in: CharacterSet(charactersIn: "vV "))
        return clean1.compare(clean2, options: .numeric) == .orderedDescending
    }

    @objc func checkUpdatesManually() {
        checkForUpdates(silent: false)
    }

    @objc func openDownloadUpdate() {
        if let urlStr = updateAvailableUrl, let url = URL(string: urlStr) {
            NSWorkspace.shared.open(url)
        }
    }

    func checkForUpdates(silent: Bool) {
        guard let url = URL(string: "https://api.github.com/repos/\(githubRepo)/releases/latest") else { return }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("SCREEN-MODE-AutoUpdater", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 8.0

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                if !silent {
                    DispatchQueue.main.async {
                        let alert = NSAlert()
                        alert.messageText = "SCREEN MODE"
                        alert.informativeText = "Não foi possível verificar atualizações no momento. Verifique sua conexão com a internet."
                        alert.alertStyle = .warning
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                    }
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let tagName = json["tag_name"] as? String {
                    
                    let htmlUrl = json["html_url"] as? String ?? "https://github.com/\(self.githubRepo)/releases/latest"
                    
                    DispatchQueue.main.async {
                        if self.isVersion(tagName, greaterThan: self.appVersion) {
                            self.updateAvailableVersion = tagName
                            self.updateAvailableUrl = htmlUrl
                            self.rebuildMenu()

                            // Notificar o usuário
                            let alert = NSAlert()
                            alert.messageText = "✨ Nova Atualização Disponível!"
                            alert.informativeText = "Uma nova versão do SCREEN MODE (\(tagName)) está pronta para download!\n\nSua versão atual: v\(self.appVersion)\nVersão mais recente: \(tagName)\n\nDeseja baixar a atualização agora?"
                            alert.alertStyle = .informational
                            alert.addButton(withTitle: "Baixar Atualização")
                            alert.addButton(withTitle: "Mais tarde")

                            if alert.runModal() == .alertFirstButtonReturn {
                                if let downloadUrl = URL(string: htmlUrl) {
                                    NSWorkspace.shared.open(downloadUrl)
                                }
                            }
                        } else if !silent {
                            let alert = NSAlert()
                            alert.messageText = "SCREEN MODE"
                            alert.informativeText = "Parabéns! Você já está usando a versão mais recente (v\(self.appVersion))."
                            alert.alertStyle = .informational
                            alert.addButton(withTitle: "OK")
                            alert.runModal()
                        }
                    }
                }
            } catch {
                print("Error parsing update JSON: \(error)")
            }
        }.resume()
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func rebuildMenu() {
        let menu = NSMenu()

        // Monitor Title Item
        let titleItem = NSMenuItem(title: "🖥️ SCREEN MODE v\(appVersion)", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        // Banner de Nova Atualização (se disponível)
        if let newVer = updateAvailableVersion {
            let updateBanner = NSMenuItem(
                title: "✨ Nova Versão Disponível (\(newVer))! Baixar ➔",
                action: #selector(openDownloadUpdate),
                keyEquivalent: ""
            )
            updateBanner.target = self
            menu.addItem(updateBanner)
        }

        menu.addItem(NSMenuItem.separator())

        // 1-Click Screen Windows (Cmd + Option + 2)
        let winItem = NSMenuItem(
            title: "💻 Screen Windows (\(portName(for: windowsInput)) - 155Hz)",
            action: #selector(handleSwitchWindows),
            keyEquivalent: "2"
        )
        winItem.keyEquivalentModifierMask = [.command, .option]
        winItem.target = self
        menu.addItem(winItem)

        // 1-Click Screen Mac (Cmd + Option + 1)
        let macItem = NSMenuItem(
            title: "🍎 Screen Mac (\(portName(for: macInput)) - 155Hz)",
            action: #selector(handleSwitchMac),
            keyEquivalent: "1"
        )
        macItem.keyEquivalentModifierMask = [.command, .option]
        macItem.target = self
        menu.addItem(macItem)

        menu.addItem(NSMenuItem.separator())

        // Configurações Submenu
        let configItem = NSMenuItem(title: "⚙️ Configurações", action: nil, keyEquivalent: "")
        let configSubmenu = NSMenu()

        // Windows port selector
        let winHeader = NSMenuItem(title: "Porta do Windows:", action: nil, keyEquivalent: "")
        winHeader.isEnabled = false
        configSubmenu.addItem(winHeader)

        let wDp1 = NSMenuItem(title: "  DisplayPort 1 (155Hz)", action: #selector(setWindowsDP1), keyEquivalent: "")
        wDp1.target = self
        wDp1.state = (windowsInput == 15) ? .on : .off
        configSubmenu.addItem(wDp1)

        let wH1 = NSMenuItem(title: "  HDMI 1 (100Hz)", action: #selector(setWindowsHDMI1), keyEquivalent: "")
        wH1.target = self
        wH1.state = (windowsInput == 17) ? .on : .off
        configSubmenu.addItem(wH1)

        let wH2 = NSMenuItem(title: "  HDMI 2 (100Hz)", action: #selector(setWindowsHDMI2), keyEquivalent: "")
        wH2.target = self
        wH2.state = (windowsInput == 18) ? .on : .off
        configSubmenu.addItem(wH2)

        configSubmenu.addItem(NSMenuItem.separator())

        // Mac port selector
        let macHeader = NSMenuItem(title: "Porta do Mac:", action: nil, keyEquivalent: "")
        macHeader.isEnabled = false
        configSubmenu.addItem(macHeader)

        let mUSBC = NSMenuItem(title: "  USB-C Ugreen (155Hz + 65W)", action: #selector(setMacUSBC), keyEquivalent: "")
        mUSBC.target = self
        mUSBC.state = (macInput == 27) ? .on : .off
        configSubmenu.addItem(mUSBC)

        let mDp1 = NSMenuItem(title: "  DisplayPort 1 (155Hz)", action: #selector(setMacDP1), keyEquivalent: "")
        mDp1.target = self
        mDp1.state = (macInput == 15) ? .on : .off
        configSubmenu.addItem(mDp1)

        configSubmenu.addItem(NSMenuItem.separator())

        // Test options
        let testHeader = NSMenuItem(title: "Testar Entradas:", action: nil, keyEquivalent: "")
        testHeader.isEnabled = false
        configSubmenu.addItem(testHeader)

        let testDP = NSMenuItem(title: "⚡ Mudar para DisplayPort 1 (Windows)", action: #selector(testDP1), keyEquivalent: "")
        testDP.target = self
        configSubmenu.addItem(testDP)

        let testUSBC = NSMenuItem(title: "⚡ Mudar para USB-C (Mac)", action: #selector(testUSBC), keyEquivalent: "")
        testUSBC.target = self
        configSubmenu.addItem(testUSBC)

        let testH1 = NSMenuItem(title: "⚡ Mudar para HDMI 1", action: #selector(testHDMI1), keyEquivalent: "")
        testH1.target = self
        configSubmenu.addItem(testH1)

        let testH2 = NSMenuItem(title: "⚡ Mudar para HDMI 2", action: #selector(testHDMI2), keyEquivalent: "")
        testH2.target = self
        configSubmenu.addItem(testH2)

        configItem.submenu = configSubmenu
        menu.addItem(configItem)

        // Opção manual de checar atualizações
        let checkUpdateItem = NSMenuItem(title: "🔄 Verificar Atualizações...", action: #selector(checkUpdatesManually), keyEquivalent: "")
        checkUpdateItem.target = self
        menu.addItem(checkUpdateItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Encerrar SCREEN MODE", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
