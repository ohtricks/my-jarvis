import AppKit
import SwiftUI

@main
struct JarvisApp: App {
    // AppDelegate garante que o app é tratado como GUI app de verdade
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .defaultSize(width: 480, height: 680)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Passo crítico: sem isso apps SPM ficam como processo sem janela GUI
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // Pequeno delay para a janela estar pronta antes de pedir foco
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            NSApp.windows.first?.makeKeyAndOrderFront(nil)
        }
    }

    // Garante que clicar no ícone do Dock re-abre/foca a janela
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
        return true
    }
}
