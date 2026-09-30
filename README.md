# PluckBuddy — AI 琵琶陪练

一款基于端侧 CoreML 的智能琵琶陪练 iOS 应用。摄像头识别手型 + 麦克风识别声音,实时给出指法评分、调音陪伴、节拍陪练,帮助习琴者在家也能练出标准音色与节奏。

> 参赛作品 · 移动应用创新赛
>
> 开发者:吴泽荟  
> 学校:武汉康礼高级中学

---

## 核心功能

| 模块 | 说明 |
| --- | --- |
| **智能指法教练** | 摄像头实时识别左右手指型(Vision 框架),匹配琵琶核心 5 种技法(弹挑/轮指/扫弦/长音/噪音),给出连续帧稳定的技法评分与核心要求轮播 |
| **智能调音** | 麦克风采集琵琶空弦音,自研 FFT 算法给出当前音高与十二平均律标准音的 cents 偏差;接 CoreML 分类器做「先判琵琶声 → 再判音高」门控 |
| **弹挑跑步** | 节拍跑道游戏化陪练。每完成一次弹挑,角色在跑道上前进一格;统计节拍稳定性 BPM 与总分 |
| **轮指花开** | 轮指训练花朵生长可视化。检测连续快速拨弦的均匀度,完成一轮后花瓣绽放 |
| **扫弦水波** | 扫弦训练水波纹可视化。区分上扫/下扫,生成对应方向的水波纹动画 |
| **节拍器** | 独立可调 BPM 节拍器,适配不同练习场景 |
| **社交广场** | 离线排行榜 / 成就 / 好友 PK(本地持久化,演示用) |
| **欢迎界面** | 米白底 + Logo + "今天也来练 5 分钟吧" + 3 秒倒计时自动退出 + 右上角"跳过" |

---

## 技术栈

- **语言 / 框架**:Swift 6 / SwiftUI / Combine / Strict Concurrency
- **平台**:iOS 17.6+,arm64 真机(摄像头 / 麦克风功能必需真机)
- **CoreML**:`PipaSoundClassifier`(四分类 琵琶 / 其它乐器 / 人声 / 背景噪声),`audioSamples` 输入 15600 帧 @ 16 kHz,端侧推理无网络依赖
- **AVFoundation**:`AVAudioEngine` 麦克风采集,自定义 `AudioManager` 4096 帧 tap + 软件 48→16 kHz 线性插值降采样
- **Vision**:左手/右手骨架提取(HandPoseExtractor),关节角度推算指型
- **Lottie**:扫弦水波与跑道角色动画
- **CoreData**:练习记录 / 排行榜 / 成就本地持久化

---

## 项目结构

```
PluckBuddy/
├── PluckBuddy.xcodeproj/        # Xcode 工程
├── PluckBuddy/                   # 主 target 源码
│   ├── PluckBuddyApp.swift       # App 入口(欢迎/首页切换)
│   ├── WelcomeView.swift         # 启动欢迎页(3 秒倒计时淡出)
│   ├── HomeView.swift            # 主页(七大模块入口)
│   ├── TechniqueCoachView*.swift # 智能指法教练 UI + ViewModel
│   ├── TunerView*.swift          # 智能调音 UI + ViewModel
│   ├── RunningViewModel.swift    # 弹挑跑步 ViewModel
│   ├── FlowerPracticeView.swift  # 轮指花开 UI
│   ├── FlowerViewModel.swift     # 轮指花开 ViewModel
│   ├── WavePracticeView.swift    # 扫弦水波 UI
│   ├── WaveViewModel.swift       # 扫弦水波 ViewModel
│   ├── MetronomeView.swift       # 节拍器 UI
│   ├── MetronomeManager.swift    # 节拍器调度
│   ├── FriendPKView.swift        # 社交广场 UI
│   ├── AchievementView.swift     # 成就 UI
│   ├── Persistence.swift         # CoreData 持久化
│   ├── AudioManager.swift        # 统一音频采集
│   ├── PipaSoundClassifier.mlmodel  # 端侧四分类 CoreML 模型
│   ├── PipaSoundGate.swift       # 调音专用琵琶声判门(独立加载模型,避免与指法教练 AVAudioEngine 抢 tap)
│   ├── CameraManager.swift       # 摄像头采集(新旋转 API)
│   ├── HandPoseExtractor.swift   # Vision 手型提取
│   ├── DSPFeatureExtractor.swift # 自研 FFT 频谱特征
│   ├── PitchDetector.swift       # 音高检测
│   ├── RhythmDetector.swift      # 弹挑节拍检测
│   ├── RollDetector.swift        # 轮指检测
│   ├── SweepDetector.swift       # 扫弦检测
│   ├── Animations/               # Lottie 动画 JSON
│   └── Assets.xcassets/          # 资源(Logo 等)
└── PluckBuddyTests/              # 单元测试 target
```

---

## 运行方式

1. **Mac 上 Xcode 17+ 打开** `PluckBuddy.xcodeproj`
2. 左侧工程 → TARGETS `PluckBuddy` → **Signing & Capabilities**
   - **Team** 选你自己的 Apple ID(免费账号即可)
   - **Bundle Identifier** 改成你账号下未注册的(如 `com.你的名字.pluckbuddy`)
3. 连真机 → 顶部设备栏选 iPhone → `Cmd+R`
4. **真机系统要求**:iOS 17.6 或更高
5. **真机首次**:设置 → 隐私与安全性 → 开发者模式 → 打开并重启;跑起来弹「不受信任的开发者」时,设置 → 通用 → VPN 与设备管理 → 信任你的 Apple ID
6. **摄像头 / 麦克风模块**(指法教练 / 调音 / 三个陪练)**必须真机运行**,模拟器无摄像头/麦克风

免费 Apple ID 描述文件 7 天过期,到期需重连 Xcode 重新签名安装。

---

## 本次提交改动

本次提交相对上一版的改动集中在三个方向。

### 一、调音模块接入端侧 CoreML 琵琶声分类器

**为什么需要**:之前的「是否琵琶声」靠 RMS + 音高范围过滤,在嘈杂环境会把说话声/敲桌声误判成琵琶音而给出错误音高。

**改法**:复用指法教练里同一套 `PipaSoundClassifier` CoreML 模型(四分类),新建 `PipaSoundGate.swift` 作为调音专用判门——它**不接管 AVAudioEngine**,只接管「降采样 + 模型推理」,麦克风数据仍由 `AudioManager` 统一提供,避免和指法教练 / 三个陪练模块抢 tap。

**门控逻辑**:调音每次音高判定前先看 `pipaGate.isPipaRecent(within: 0.5)`,最近 0.5 秒内判定为琵琶声才进入音高计算;非琵琶声直接丢弃,显示「聆听中…等待琵琶声」。

### 二、分类器精度的工程改进(不动模型本身)

真机实测发现 CoreML 模型在真机麦克风采集的真实音频下,pipa 概率多落在 0.3~0.7 区间,原阈值 0.5 + 3 帧滑动平均过严。改进:

1. **阈值 0.5 → 0.35**(折中值,真琵琶概率 0.3~0.7 都能命中)
2. **滑动窗口 3 → 2 帧**(抑制噪声的同时避免高概率被平均下来)
3. **能量门控**:推理前先算窗口 RMS,< 0.01 的安静帧直接判 background,不入滑动平均(说话间歇 / 背景噪声不再污染 pipa 概率)
4. **重叠推理窗口**:步长 15600 → 8000(约 50% 重叠率),同一发声片段被 2~3 次推理覆盖,命中率直接翻倍

副作用:推理频率从 1Hz 涨到约 2Hz,CPU 压力可接受。

### 三、欢迎界面淡出动画

`WelcomeView` 之前用 `if/else` 切换 + `.transition(.opacity)`,真机上常表现为硬切(尤其在快速倒计时归零 / 点跳过按钮时)。改为:

- `PluckBuddyApp` 根视图主界面常驻底层
- `WelcomeView` 自身先做 0.5 秒淡出(透明度 + 轻微缩放),动画结束才被移除
- 主界面同步淡入,无黑屏 / 闪白
- 加 `isDismissing` 守卫,避免倒计时归零和跳过按钮的竞态重复退出

---

## 已知限制 / 待改进

- 分类器精度仍受训练数据分布限制。若真机 console 显示 `rms > 0.05` 但 `pipa < 0.3`,说明模型对当前麦克风音质判别力不足,需用 Create ML Sound Analysis 模板重训(每类 ≥ 30 条 16kHz 音频,通常 30 分钟内能出一个明显更好的模型)
- 免费 Apple ID 描述文件 7 天过期,需重连 Xcode 重签
- 摄像头 / 麦克风功能必须真机,模拟器无法演示
- 社交广场为离线演示版,排行榜 / 成就 / 好友 PK 数据存储本地 CoreData

---

## License

参赛作品源码,仅供评审与学习使用。