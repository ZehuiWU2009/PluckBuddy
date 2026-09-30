//
//  PluckBuddyApp.swift
//  PluckBuddy
//
//  Created by 吴泽荟 on 2026/7/15.
//

import SwiftUI
import CoreData

@main
struct PluckBuddyApp: App {
    let persistenceController = PersistenceController.shared
    
    /// 启动时先显示欢迎页，点击「开始练习」或停留超时后进入主界面
    @State private var showWelcome = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                // 主界面常驻底层；欢迎页淡出时主界面同步淡入，避免黑屏 / 闪白
                HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .opacity(showWelcome ? 0 : 1)
                    .animation(.easeInOut(duration: 0.5), value: showWelcome)
                    .accessibilityHidden(showWelcome)
                if showWelcome {
                    WelcomeView(onEnter: enterMain)
                }
            }
        }
    }
    
    /// 欢迎页的退出动作（由欢迎页内的定时器触发）。加 guard 防止重复调用。
    private func enterMain() {
        guard showWelcome else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            showWelcome = false
        }
    }
}
