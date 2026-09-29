//
//  TechniqueType.swift
//  PluckBuddy
//
//  Created by 吴泽荟 on 2026/7/29.
//

import Foundation
import SwiftUI

/// 琵琶技法类型
enum TechniqueType: String, CaseIterable {
    case roll = "轮指"
    case sweep = "扫弦"
    case pluck = "弹挑"
    case unknown = "未识别"
    
    /// 图标
    var icon: String {
        switch self {
        case .roll: return "hand.tap.fill"
        case .sweep: return "waveform.path"
        case .pluck: return "hand.point.up.left.fill"
        case .unknown: return "questionmark.circle"
        }
    }
    
    /// 主题色
    var color: Color {
        switch self {
        case .roll: return .pink
        case .sweep: return .blue
        case .pluck: return .green
        case .unknown: return .gray
        }
    }
    
    /// 描述
    var description: String {
        switch self {
        case .roll: return "快速连续的手指弹奏"
        case .sweep: return "手臂带动的扫弦动作"
        case .pluck: return "弹挑交替的基础技法"
        case .unknown: return "等待识别中..."
        }
    }
}
