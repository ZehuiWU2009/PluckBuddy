//
//  HandPoseExtractor.swift
//  PluckBuddy
//
//  Created by 吴泽荟 on 2026/8/17.
//

import Vision
import AVFoundation
import CoreImage

/// 手部姿态提取器
/// 使用 Apple Vision Framework 提取手部 21 个关键点
class HandPoseExtractor {
    
    // MARK: - Properties
    private var handPoseRequest: VNDetectHumanHandPoseRequest
    
    // 21 个关键点名称（按顺序）
    private let jointNames: [VNHumanHandPoseObservation.JointName] = [
        .wrist,
        .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
        .indexMCP, .indexPIP, .indexDIP, .indexTip,
        .middleMCP, .middlePIP, .middleDIP, .middleTip,
        .ringMCP, .ringPIP, .ringDIP, .ringTip,
        .littleMCP, .littlePIP, .littleDIP, .littleTip
    ]
    
    // MARK: - Initialization
    init() {
        handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2  // 检测最多 2 只手
    }
    
    // MARK: - Public Methods
    
    /// 从视频帧中提取手部关键点
    /// - Parameter buffer: 视频帧缓冲区
    /// - Returns: 关键点数组（每个点包含 x, y 坐标和置信度）
    func extractKeypoints(from buffer: CVPixelBuffer) async throws -> [HandKeypoint] {
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, options: [:])
        try handler.perform([handPoseRequest])
        
        guard let observations = handPoseRequest.results,
              !observations.isEmpty else {
            // 未检测到手部，返回空数组
            return []
        }
        
        // 提取第一只手的关键点（通常是右手）
        let firstHand = observations.first!
        var keypoints: [HandKeypoint] = []
        
        for jointName in jointNames {
            if let point = try? firstHand.recognizedPoint(jointName) {
                // 使用更简洁的关键点名称（例如："wrist", "thumbTip" 等）
                let simpleName = getSimpleName(for: jointName)
                keypoints.append(HandKeypoint(
                    name: simpleName,
                    location: point.location,
                    confidence: Double(point.confidence)
                ))
            }
        }
        
        print("✅ 检测到 \(keypoints.count) 个关键点")  // 调试日志
        return keypoints
    }
    
    /// 获取关键点的简化名称
    private func getSimpleName(for jointName: VNHumanHandPoseObservation.JointName) -> String {
        switch jointName {
        case .wrist: return "wrist"
        case .thumbCMC: return "thumbCMC"
        case .thumbMP: return "thumbMP"
        case .thumbIP: return "thumbIP"
        case .thumbTip: return "thumbTip"
        case .indexMCP: return "indexMCP"
        case .indexPIP: return "indexPIP"
        case .indexDIP: return "indexDIP"
        case .indexTip: return "indexTip"
        case .middleMCP: return "middleMCP"
        case .middlePIP: return "middlePIP"
        case .middleDIP: return "middleDIP"
        case .middleTip: return "middleTip"
        case .ringMCP: return "ringMCP"
        case .ringPIP: return "ringPIP"
        case .ringDIP: return "ringDIP"
        case .ringTip: return "ringTip"
        case .littleMCP: return "littleMCP"
        case .littlePIP: return "littlePIP"
        case .littleDIP: return "littleDIP"
        case .littleTip: return "littleTip"
        default: return "unknown"
        }
    }
    
    /// 从关键点数组提取扁平化特征向量（用于模型输入）
    /// - Parameter keypoints: 关键点数组
    /// - Returns: 特征向量 [x1, y1, x2, y2, ..., x21, y21]
    func extractFeatureVector(from keypoints: [HandKeypoint]) -> [Double] {
        var features: [Double] = []
        
        for keypoint in keypoints {
            features.append(Double(keypoint.location.x))
            features.append(Double(keypoint.location.y))
        }
        
        return features
    }
    
    /// 归一化关键点坐标（相对于手腕）
    /// - Parameter keypoints: 原始关键点
    /// - Returns: 归一化后的关键点
    func normalizeKeypoints(_ keypoints: [HandKeypoint]) -> [HandKeypoint] {
        guard !keypoints.isEmpty else { return [] }
        
        // 以手腕为参考点
        let wrist = keypoints[0].location
        
        return keypoints.map { keypoint in
            HandKeypoint(
                name: keypoint.name,
                location: CGPoint(
                    x: keypoint.location.x - wrist.x,
                    y: keypoint.location.y - wrist.y
                ),
                confidence: keypoint.confidence
            )
        }
    }
}

// MARK: - Data Structures

/// 手部关键点数据结构
struct HandKeypoint {
    let name: String
    let location: CGPoint
    let confidence: Double
}

/// 手部姿态数据（包含完整的关键点序列）
struct HandPose {
    let keypoints: [HandKeypoint]
    let timestamp: Date
    
    /// 是否有效（至少检测到 50% 的关键点）
    var isValid: Bool {
        let validCount = keypoints.filter { $0.confidence > 0.3 }.count
        return Double(validCount) / Double(keypoints.count) > 0.5
    }
}
