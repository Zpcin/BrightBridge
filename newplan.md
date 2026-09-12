> 面向培智学生、自闭症人士、银发老人和数字新手的数字生活仿真训练 App。
  >
  > 比赛版目标：最大化展示 AI 的即时生成能力，快速完成“自然语言任务 → AI 拆解 → 仿真界面 → 单步引导 → 完成反馈”的完整闭环。

  ---

  ## 1. 比赛版产品定位

  「小引导」不是直接操作真实手机的工具，而是一个安全的数字生活仿真训练助手。

  用户可以输入：

  - “教我打开 Wi-Fi”
  - “教我怎么拨打电话”
  - “手机字体太小怎么办”
  - “教我取快递”

  AI 会将抽象任务拆分成一次只执行一个动作的练习步骤，并生成可交互的仿真界面。

  ```text
  自然语言任务
    ↓
  AI 理解任务
    ↓
  AI 拆解步骤
    ↓
  生成仿真页面
    ↓
  语音 / 文字单步引导
    ↓
  用户操作
    ↓
  即时反馈
    ↓
  完成任务

  比赛版核心价值

  1. AI 能理解用户的自然语言需求；
  2. AI 能根据用户画像生成不同话术；
  3. AI 能即时生成课程步骤；
  4. AI 能生成可交互的仿真界面；
  5. 用户点错不会造成真实损失；
  6. 老人和儿童看到的引导方式不同；
  7. 不需要预先编写大量固定课程。

  ---

  2. 比赛版范围

  2.1 必须实现

  - 儿童 / 学生模式；
  - 老人模式；
  - 自然语言任务输入；
  - AI 生成课程；
  - AI 生成儿童和老人两套话术；
  - 仿真手机界面；
  - 单步操作引导；
  - tap；
  - long_press；
  - swipe；
  - 点错反馈；
  - 点对反馈；
  - 课程完成页；
  - 语音播报或文字播报；
  - 本地演示课程 fallback；
  - 三个完整演示场景；
  - 基础移动端响应式布局。

  2.2 比赛版暂不实现

  以下内容不作为 MVP 阻塞项：

  - 完整 17 个课程；
  - 完整 IndexedDB 进度系统；
  - 复杂掌握度算法；
  - 老师审核工作流；
  - Capacitor Android 打包；
  - 真实系统设置操作；
  - AccessibilityService；
  - 真实拨号；
  - 真实支付；
  - 在线账号；
  - 后端服务；
  - 摄像头识别；
  - LLM 本地部署；
  - 复杂手势识别；
  - 多设备适配；
  - 生产级错误恢复；
  - 完整离线 PWA；
  - iOS 版本。

  ---

  3. 用户画像

  3.1 儿童 / 培智学生 / 自闭症人士

  {
    "persona": "child",
    "fontScale": 1.15,
    "speakRate": 0.85,
    "tapTolerance": 28,
    "autoReplay": true,
    "explainWhy": false,
    "rewardStyle": "playful"
  }

  话术特点：

  - 短句；
  - 少于 12 个字；
  - 不使用复杂术语；
  - 鼓励频繁；
  - 使用颜色、形状和位置描述；
  - 使用撒花、鼓掌、笑脸等反馈。

  示例：

  找到绿色电话。
  点一下。
  你做对啦！

  3.2 老人 / 数字新手

  {
    "persona": "senior",
    "fontScale": 1.45,
    "speakRate": 0.8,
    "tapTolerance": 36,
    "autoReplay": true,
    "explainWhy": true,
    "rewardStyle": "practical"
  }

  话术特点：

  - 尊重、平等；
  - 不使用幼儿化称呼；
  - 解释操作原因；
  - 语速较慢；
  - 字号更大；
  - 目标区域更容易点击；
  - 使用“已经学会”“可以再试一次”等反馈。

  示例：

  请点击绿色的电话图标。
  点击后会打开拨号页面。

  ▎ 老人模式的容错只扩大逻辑命中区域，不改变仿真界面元素的视觉位置，避免形成错误的空间认知。

  ---

  4. 比赛版核心演示场景

  场景一：认识电话图标

  展示能力：

  - 儿童模式；
  - 图标识别；
  - 单步引导；
  - 点错反馈；
  - 正确反馈动画。

  流程：

  显示多个图标
    ↓
  找到绿色电话图标
    ↓
  点击电话图标
    ↓
  显示成功动画

  儿童话术：

  找到绿色电话。

  老人话术：

  请点击绿色的电话图标。
  这是拨打电话的入口。

  ---

  场景二：打开 Wi-Fi

  展示能力：

  - 老人模式；
  - 多步骤任务；
  - seniorWhy；
  - 字号放大；
  - 多页面仿真；
  - AI 动态生成课程。

  流程：

  点击设置
    ↓
  点击 Wi-Fi
    ↓
  点击家庭网络
    ↓
  显示连接成功

  ---

  场景三：调大手机字体

  展示能力：

  - 老人急救箱；
  - 从真实问题生成解决方案；
  - 仿真设置界面；
  - 滑动操作；
  - 完成后显示效果变化。

  流程：

  点击设置
    ↓
  点击显示
    ↓
  点击字体大小
    ↓
  向右拖动滑块
    ↓
  显示字体已变大

  ---

  5. 技术架构

  比赛版采用轻量 React 架构：

  React UI
    ├── HomePage
    ├── GeneratePage
    ├── PracticePage
    └── ResultPage
          ↓
  CourseStore
          ↓
  LLM Service
          ↓
  Course JSON
          ↓
  Synthetic Renderer
          ↓
  Simple Guide Engine

  5.1 技术栈

  - React；
  - TypeScript；
  - Vite；
  - Zustand 或 React Context；
  - CSS；
  - 可选 Framer Motion；
  - 浏览器 SpeechSynthesis；
  - LLM API；
  - 本地 fallback JSON。

  5.2 目录结构

  src/
  ├── App.tsx
  ├── types.ts
  ├── data/
  │   └── demoCourses.ts
  ├── components/
  │   ├── PersonaSelector.tsx
  │   ├── CourseInput.tsx
  │   ├── SyntheticScreen.tsx
  │   ├── GuidePrompt.tsx
  │   ├── Character.tsx
  │   ├── ActionButton.tsx
  │   └── ResultCard.tsx
  ├── pages/
  │   ├── HomePage.tsx
  │   ├── GeneratePage.tsx
  │   ├── PracticePage.tsx
  │   └── ResultPage.tsx
  ├── services/
  │   ├── llmService.ts
  │   └── speechService.ts
  ├── store/
  │   └── courseStore.ts
  └── styles/
      └── global.css

  ---

  6. 核心数据模型

  6.1 课程

  export interface Course {
    id: string
    title: string
    category: 'icon' | 'phone' | 'senior-help'
    persona: 'child' | 'senior'
    description: string
    steps: CourseStep[]
  }

  6.2 课程步骤

  export interface CourseStep {
    id: string
    prompt: {
      child: string
      senior: string
    }
    why?: string
    screen: SimulatedScreen
    action: Action
  }

  6.3 原子动作

  export type Action =
    | {
        type: 'tap'
        targetId: string
      }
    | {
        type: 'long_press'
        targetId: string
        duration: number
      }
    | {
        type: 'swipe'
        direction: 'up' | 'down' | 'left' | 'right'
        targetId?: string
      }

  6.4 仿真页面

  export interface SimulatedScreen {
    title: string
    elements: SimulatedElement[]
  }

  6.5 仿真元素

  export type SimulatedElement =
    | {
        type: 'icon'
        id: string
        label: string
        icon: string
      }
    | {
        type: 'button'
        id: string
        label: string
      }
    | {
        type: 'text'
        id: string
        value: string
      }
    | {
        type: 'toggle'
        id: string
        label: string
        enabled: boolean
      }
    | {
        type: 'slider'
        id: string
        label: string
        value: number
      }

  ---

  7. LLM 生成协议

  7.1 用户输入

  教我把手机字体调大

  7.2 LLM 输出

  {
    "title": "调大手机字体",
    "category": "senior-help",
    "steps": [
      {
        "id": "step-1",
        "prompt": {
          "child": "找到设置。",
          "senior": "请点击设置图标。"
        },
        "why": "设置里可以调整手机功能。",
        "screen": {
          "title": "手机桌面",
          "elements": [
            {
              "type": "icon",
              "id": "settings",
              "label": "设置",
              "icon": "gear"
            }
          ]
        },
        "action": {
          "type": "tap",
          "targetId": "settings"
        }
      }
    ]
  }

  7.3 LLM 规则

  LLM 只能生成白名单内容：

  const allowedActions = [
    'tap',
    'long_press',
    'swipe'
  ]

  const allowedElementTypes = [
    'icon',
    'button',
    'text',
    'toggle',
    'slider'
  ]

  禁止生成：

  - JavaScript；
  - HTML；
  - React 代码；
  - URL；
  - 文件路径；
  - 系统命令；
  - Android API；
  - 真实拨号；
  - 真实支付；
  - 真实系统设置修改；
  - 任意函数调用。

  7.4 生成失败处理

  调用 LLM
    ↓
  JSON 解析
    ↓
  简单白名单校验
    ↓
  成功：进入练习
  失败：加载本地 fallback

  比赛现场必须保证：

  - LLM 无响应时仍可演示；
  - 网络延迟时显示生成动画；
  - JSON 解析失败时自动切换示例课程；
  - 不因 API 失败导致白屏。

  ---

  8. 引导状态机

  比赛版使用简化状态机：

  type PracticeState =
    | 'idle'
    | 'speaking'
    | 'waiting'
    | 'success'
    | 'error'
    | 'completed'

  流程：

  idle
    ↓
  speaking
    ↓
  waiting
    ↓
  用户操作
    ├── 正确 → success → 下一步
    └── 错误 → error → 重播提示

  错误反馈：

  第一次错误

  没关系，再找一次。

  同时：

  - 目标闪烁；
  - 重播语音。

  第二次错误

  看这里，这个按钮可以点击。

  同时：

  - 目标高亮；
  - 其他元素降低透明度；
  - 显示箭头。

  第三次错误

  比赛版不要求自动完成真实操作。

  统一显示：

  我们一起完成了这一步。
  这一步可以再练习一次。

  然后：

  - 进入下一步；
  - 在结果页显示“建议复习”。

  ---

  9. 仿真界面设计

  仿真页面使用 DOM/CSS，不使用 Canvas 作为主要渲染方式。

  原因：

  - 更容易放大字号；
  - 更容易绑定点击事件；
  - 更容易实现响应式；
  - 更容易实现高亮；
  - 更容易测试；
  - 更适合老人模式。

  结构：

  SyntheticScreen
  ├── StatusBar
  ├── ScreenHeader
  ├── ElementGrid
  ├── TargetHighlight
  ├── HandPointer
  └── ErrorOverlay

  每个可交互元素必须具备：

  - 唯一 id；
  - 可见标签；
  - 点击事件；
  - 当前目标状态；
  - 错误反馈状态。

  ---

  10. 页面设计

  10.1 首页

  首页重点是快速进入体验。

  小引导

  让数字生活变简单

  请选择你的练习方式：

  [儿童 / 学生]
  [老人 / 数字新手]

  你想学习什么？

  [教我打开 Wi-Fi]
  [教我拨打电话]
  [教我调大字体]

  [输入自己的问题]

  10.2 生成页

  展示 AI 工作过程：

  正在理解你的问题……
  正在拆成小步骤……
  正在准备练习界面……

  生成时间过长时，显示：

  你也可以先试试“打开 Wi-Fi”

  10.3 练习页

  练习页始终只展示一个当前目标：

  角色
  当前提示
  仿真手机
  错误提示
  重播按钮

  不要同时显示多个操作目标。

  10.4 完成页

  太棒了！

  你完成了：
  连接 Wi-Fi

  你学会了：

  ✓ 找到设置
  ✓ 打开 Wi-Fi
  ✓ 选择家庭网络

  [再练一次]
  [学习新的事情]

  ---

  11. 比赛版实施顺序

  Phase 0：工程初始化

  - 创建 Vite React TypeScript 工程；
  - 配置基础 CSS；
  - 创建页面路由或页面状态；
  - 创建基础数据模型；
  - 创建三个 fallback 课程。

  验收：

  - npm install 成功；
  - npm run dev 成功；
  - 首页可以打开；
  - 可以切换画像。

  Phase 1：本地课程闭环

  - 实现 SyntheticScreen；
  - 实现目标元素点击；
  - 实现正确反馈；
  - 实现错误反馈；
  - 实现下一步；
  - 实现完成页。

  验收：

  首页
  → 选择画像
  → 选择课程
  → 进入练习
  → 点击目标
  → 完成课程

  Phase 2：视觉和动画

  - 手机外壳；
  - 目标高亮；
  - 手指点击动画；
  - 角色表情；
  - 撒花动画；
  - 老人模式字号；
  - 进度条；
  - 页面切换动画。

  验收：

  - 首次演示具有明显视觉效果；
  - 儿童模式和老人模式有明显区别；
  - 仿真页面不出现空白主体。

  Phase 3：LLM 接入

  - 增加自然语言输入；
  - 编写 LLM Prompt；
  - 接收课程 JSON；
  - 解析和白名单校验；
  - 生成失败 fallback；
  - 动态生成课程；
  - 动态生成话术。

  验收：

  输入：

  教我把手机字体调大

  能够生成并开始练习。

  Phase 4：语音和演示优化

  - 接入 SpeechSynthesis；
  - 增加重播；
  - 增加“正在思考”状态；
  - 增加错误温柔提示；
  - 增加示例任务；
  - 优化移动端布局；
  - 准备固定演示路径。

  Phase 5：比赛准备

  - 固定三分钟演示流程；
  - 准备无网络 fallback；
  - 准备 LLM 失败 fallback；
  - 检查首屏加载；
  - 检查移动端显示；
  - 确认没有真实拨号、支付或设置修改；
  - 准备产品价值说明。

  ---

  12. 比赛验收标准

  满足以下条件即可视为 MVP 完成：

  - Web App 可以启动；
  - 首页可以展示产品定位；
  - 用户可以选择儿童或老人模式；
  - 两种模式字号和话术明显不同；
  - 用户可以输入自然语言任务；
  - LLM 可以返回课程 JSON；
  - 课程 JSON 可以生成仿真页面；
  - 仿真页面支持至少三种动作；
  - 用户点错不会产生真实副作用；
  - 用户点对可以进入下一步；
  - 至少三个课程可以完成；
  - 至少一个课程由 LLM 即时生成；
  - 有文字或语音引导；
  - 有错误反馈；
  - 有完成反馈；
  - LLM 失败时可以使用本地课程继续演示；
  - 移动端页面无明显横向溢出；
  - 演示过程中不会进入真实系统设置；
  - 不会真实拨号、支付或发送消息。

  ---

  13. 比赛演示脚本

  第一步：介绍痛点

  很多人不是不会使用手机，而是不敢点。
  因为他们不知道点错之后会发生什么。

  第二步：选择老人模式

  展示：

  - 字号放大；
  - 话术变化；
  - 解释为什么。

  第三步：输入自然语言

  手机字体太小，教我怎么调大。

  第四步：展示 AI 生成

  AI 正在理解问题……
  AI 正在拆分步骤……
  AI 正在生成仿真手机界面……

  第五步：开始练习

  AI 引导：

  请点击设置图标。
  点击后，我们才能找到字体设置。

  用户故意点错：

  没关系，请再找一次。

  用户点对后进入下一步。

  第六步：展示完成结果

  你已经完成了字体调大练习。
  刚才的操作不会改变真实手机。
  你可以放心反复练习。

  第七步：总结差异化

  小引导不是告诉用户应该做什么，
  而是让用户在没有风险的环境里，
  真正练会怎么做。

  ---

  14. 最终比赛策略

  比赛版优先级：

  AI 生成能力
  > 完整演示闭环
  > 交互和视觉效果
  > 画像差异
  > 语音反馈
  > 场景数量
  > 工程完整性
  > 稳定性

  第一目标不是构建完整产品，而是尽快完成：

  一句话
  → AI 生成
  → 仿真界面
  → 一步一步练习
  → 安全完成

  所有暂时未完成的能力都必须明确标记为后续版本，不影响 MVP 演示。