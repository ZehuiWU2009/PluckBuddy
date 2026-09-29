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
                if showWelcome {
                    WelcomeView(onEnter: enterMain)
                        .transition(.opacity)
                } else {
                    HomeView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .transition(.opacity)
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
