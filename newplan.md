# 智触心桥 SmartBridge Web 重构架构计划

## 1. 重构目标

将现有“C# 原生 Android + Android Canvas”实现替换为 **TypeScript 核心 + React Web UI + Vite + Capacitor Android 壳**。

当前 C# 核心不作为 Web 运行时依赖。它仅保留为历史参考；新的核心模型、校验器、状态机、手势匹配、进度存储全部使用 TypeScript 重新实现。

首要目标不是复制当前界面，而是解决当前版本的核心问题：

- 首页布局混乱、课程列表不可读；
- 页面高度和滚动处理不正确；
- 练习区域空白、信息层级不清晰；
- Android 原生布局修改成本高；
- 课程内容无法方便地由 JSON 驱动；
- 当前核心状态与 UI 耦合，无法可靠扩展。

## 2. 总体技术方案

```text
React + TypeScript + Vite
          ↓
TypeScript Core（纯逻辑，无 DOM 依赖）
          ↓
PWA 离线资源
          ↓
Capacitor Android
          ↓
Android APK
```

### 技术选型

- UI：React 18/19 + TypeScript
- 构建：Vite
- 路由：React Router
- 状态：Zustand；核心练习状态仍由纯 TypeScript `GuideEngine` 管理
- 样式：普通 CSS Modules 或分层 CSS，不依赖在线 CDN
- 数据校验：自定义严格校验器；必要时使用 Zod，但运行时必须保留语义校验
- 测试：Vitest + Testing Library；关键流程使用 Playwright
- 本地存储：IndexedDB，localStorage 只保存小型设置
- Android：Capacitor
- 语音：浏览器 SpeechSynthesis 作为基础能力；Capacitor 原生 TTS 插件作为 Android 增强和离线 fallback
- 文件选择：HTML File API；Android 通过 Capacitor Filesystem/实现插件增强
- 图像显示：`img` + SVG overlay；synthetic 界面使用 DOM/CSS，复杂绘制才使用 Canvas

## 3. 目录结构

```text
smartbridge-web/
├─ package.json
├─ tsconfig.json
├─ vite.config.ts
├─ capacitor.config.ts
├─ index.html
├─ public/
│  ├─ scenes/
│  │  ├─ l1-phone.json
│  │  ├─ l1-wechat.json
│  │  └─ ...
│  ├─ images/
│  ├─ characters/
│  └─ fonts/
├─ src/
│  ├─ main.tsx
│  ├─ App.tsx
│  ├─ app/
│  │  ├─ routes.tsx
│  │  ├─ AppShell.tsx
│  │  ├─ appStore.ts
│  │  └─ errorBoundary.tsx
│  ├─ core/
│  │  ├─ models.ts
│  │  ├─ defaults.ts
│  │  ├─ sceneValidator.ts
│  │  ├─ guideEngine.ts
│  │  ├─ gestureMatcher.ts
│  │  ├─ promptLadder.ts
│  │  ├─ progressTracker.ts
│  │  ├─ simulationReducer.ts
│  │  ├─ clock.ts
│  │  └─ coreErrors.ts
│  ├─ data/
│  │  ├─ builtinSceneRepository.ts
│  │  ├─ generatedSceneRepository.ts
│  │  ├─ profileStore.ts
│  │  ├─ progressStore.ts
│  │  ├─ manifestStore.ts
│  │  └─ indexedDb.ts
│  ├─ services/
│  │  ├─ speechService.ts
│  │  ├─ nativeTtsService.ts
│  │  ├─ screenshotService.ts
│  │  ├─ sceneGenerationClient.ts
│  │  └─ shareService.ts
│  ├─ stores/
│  │  ├─ profileStore.ts
│  │  ├─ catalogStore.ts
│  │  ├─ practiceStore.ts
│  │  └─ reportStore.ts
│  ├─ components/
│  │  ├─ BrandHeader.tsx
│  │  ├─ PersonaSwitcher.tsx
│  │  ├─ CourseCard.tsx
│  │  ├─ CourseSection.tsx
│  │  ├─ PracticeSurface.tsx
│  │  ├─ ImageScreen.tsx
│  │  ├─ SyntheticScreen.tsx
│  │  ├─ HotspotOverlay.tsx
│  │  ├─ PromptPanel.tsx
│  │  ├─ CharacterPanel.tsx
│  │  ├─ ActionBar.tsx
│  │  ├─ ReviewBadge.tsx
│  │  ├─ EmptyState.tsx
│  │  └─ ConfirmDialog.tsx
│  ├─ pages/
│  │  ├─ WelcomePage.tsx
│  │  ├─ HomePage.tsx
│  │  ├─ CourseCatalogPage.tsx
│  │  ├─ PracticePage.tsx
│  │  ├─ ResultPage.tsx
│  │  ├─ ReviewPage.tsx
│  │  ├─ GeneratorPage.tsx
│  │  └─ TeacherPreviewPage.tsx
│  ├─ styles/
│  │  ├─ tokens.css
│  │  ├─ global.css
│  │  ├─ layout.css
│  │  ├─ components.css
│  │  └─ accessibility.css
│  └─ test/
│     ├─ setup.ts
│     ├─ fixtures.ts
│     └─ helpers.ts
├─ tests/
│  ├─ core/
│  │  ├─ sceneValidator.test.ts
│  │  ├─ guideEngine.test.ts
│  │  ├─ gestureMatcher.test.ts
│  │  ├─ promptLadder.test.ts
│  │  └─ progressTracker.test.ts
│  ├─ ui/
│  │  ├─ HomePage.test.tsx
│  │  ├─ CourseCatalogPage.test.tsx
│  │  ├─ PracticePage.test.tsx
│  │  └─ TeacherPreviewPage.test.tsx
│  └─ e2e/
│     ├─ onboarding.spec.ts
│     ├─ practice.spec.ts
│     └─ responsive.spec.ts
├─ scripts/
│  ├─ validate-scenes.ts
│  ├─ copy-assets.ts
│  └─ build-android.ps1
└─ docs/
   ├─ WEB-ARCHITECTURE.md
   ├─ DSL.md
   ├─ OFFLINE.md
   └─ P0-ACCEPTANCE.md
```

## 4. 核心领域模型

### 4.1 画像

```ts
export type Persona = 'child' | 'senior'

export interface LearnerProfile {
  persona: Persona
  fontScale: number
  speakRate: number
  tapToleranceDp: number
  autoReplay: boolean
  explainWhy: boolean
  celebrationEnabled: boolean
}
```

默认值：

- child：字号 1.0、语速 0.9、容错 24dp、短句、高频鼓励；
- senior：字号 1.4、语速 0.9、容错 36dp、解释原因、克制反馈。

容错只用于逻辑命中，不改变仿真界面的视觉位置和尺寸。

### 4.2 DSL

```ts
export type AtomicAction =
  | 'observe'
  | 'tap'
  | 'long_press'
  | 'swipe'
  | 'type_char'
  | 'wait'

export type ExecutionMode =
  | 'simulation'
  | 'screenshot_guide'
  | 'live_settings_guide'

export interface Scene {
  schemaVersion: 1
  id: string
  title: string
  level: 'L0' | 'L1' | 'L2' | 'L3' | 'L4'
  domain: string
  executionMode: Exclude<ExecutionMode, 'live_settings_guide'>
  sandbox: true
  screen: ScreenDefinition
  phases: Phase[]
}

export interface Phase {
  id: string
  title: string
  screen?: ScreenDefinition
  steps: Step[]
}

export interface Step {
  id: string
  action: AtomicAction
  targetId?: string
  inputId?: string
  character?: string
  durationMs?: number
  from?: Point
  to?: Point
  waitMs?: number
  say: SayText
  prompts: PromptRule[]
}

export interface SayText {
  child: string
  senior: string
  seniorWhy?: string
}

export interface Point { x: number; y: number }
export interface Rect { x: number; y: number; width: number; height: number }

export interface ScreenElement {
  id: string
  kind: string
  text?: string
  icon?: string
  color?: string
  bounds: Rect
  interactive: boolean
}

export interface ScreenDefinition {
  type: 'image' | 'synthetic'
  src?: string
  style?: 'kiosk' | 'atm' | 'pos' | 'app_light' | 'app_dark'
  elements: ScreenElement[]
}
```

所有坐标统一使用 0 到 1 的归一化值。渲染层负责将其映射到内容矩形，不能直接把屏幕像素当成归一化坐标。

## 5. 核心模块设计

### 5.1 `sceneValidator.ts`

校验分为三层：

1. JSON 结构校验；
2. 类型和枚举校验；
3. 语义安全校验。

必须拒绝：

- 未知动作、未知屏幕样式、未知字段；
- 越界、负数、NaN、Infinity 坐标；
- image 的 URL、绝对路径、目录穿越；
- 交互目标不存在或 `interactive=false`；
- `type_char` 不是单个 Unicode grapheme；
- child 话术超过 12 个感知字符；
- “然后、接着、下一步、随后、之后”等拆分红线；
- 脚本、工具调用、提示注入文本；
- 非沙盒场景；
- L4 真实系统自动执行定义；
- 不完整的辅助规则。

校验器返回结构化问题，不允许页面因非法场景崩溃。

### 5.2 `guideEngine.ts`

状态：

```ts
export type GuideState =
  | 'idle'
  | 'greeting'
  | 'presenting_step'
  | 'turn_cue'
  | 'awaiting_action'
  | 'applying_prompt'
  | 'feedback'
  | 'paused'
  | 'completed'
  | 'need_human_help'
  | 'aborted'
```

事件必须携带当前步骤的 `stepRunId`，异步语音、动画和计时回调必须携带 `operationId`。旧步骤回调不得推进新步骤。

状态机要求：

- `observe` 通过展示时间或“我准备好了”完成，结果为 `ExposureCompleted`；
- `wait` 只通过模拟等待条件完成；
- tap、长按、滑动、虚拟键输入分别匹配；
- 错误操作不会造成真实副作用；
- 仿真场景最高辅助档可自动完成并标记待复习；
- screenshot guide 最高辅助档进入 `need_human_help`，不得自动操作真实手机；
- 暂停时冻结活动计时，恢复不能补算暂停期间；
- 步骤推进前取消上一条 TTS、动画和定时器。

核心 API：

```ts
export interface GuideEngine {
  snapshot(): GuideSnapshot
  dispatch(event: GuideEvent): TransitionResult
  currentStep(): Step
  currentScreen(): ScreenDefinition
  exportSession(): SessionResult
}
```

### 5.3 `gestureMatcher.ts`

支持：

- tap：精确命中优先，老人容错区作为第二层；
- long_press：检查目标和持续时间；
- swipe：检查起点、方向、距离和终点；
- type_char：只接受一个虚拟键和一个字符；不调用真实键盘；
- observe / wait：拒绝触摸伪完成。

邻近热点重叠时，精确命中优先；模糊命中不能把邻键判定为正确。

### 5.4 `progressTracker.ts`

记录：

```ts
export interface StepAttempt {
  sessionId: string
  stepRunId: string
  stepId: string
  sceneVersion: number
  outcome:
    | 'IndependentSuccess'
    | 'PromptedSuccess'
    | 'AutoCompleted'
    | 'ExposureCompleted'
    | 'Aborted'
  wrongCount: number
  usedPromptIds: string[]
  maxPromptLevel: number
  activeElapsedMs: number
  firstAttemptCorrect: boolean
}
```

只有不同 session 中完整练习得到的连续三次独立成功才能计为掌握。自动完成、提示完成、observe 和 wait 均不能伪装为独立掌握。

### 5.5 `simulationReducer.ts`

所有仿真副作用必须是白名单效果：

```ts
export type SimulationEffect =
  | { type: 'append_char'; inputId: string; character: string }
  | { type: 'set_flag'; key: string; value: boolean }
  | { type: 'show_screen'; screenId: string }
```

禁止从 DSL 执行 URL、JavaScript、系统命令、真实拨号、真实支付和任意代码。

## 6. 数据和审核架构

### 6.1 内置场景

内置场景位于 `public/scenes`，构建时打包进前端，默认离线可用。

首版冻结：

- L1 图标认知 5 个：电话、微信、相机、设置、Wi-Fi；
- L2 操作 8 个：解锁、拨号、接听、挂断、微信长按发语音、调音量、手电筒、拍照；
- L4 急救箱 4 个：字体太小、声音问题、连接 Wi-Fi、诈骗识别。

### 6.2 生成场景

生成流程：

```text
截图或文字描述
  ↓
SceneDraft JSON
  ↓
严格结构与语义校验
  ↓
老师预览试玩
  ↓
输入审核人
  ↓
计算 ContentHash
  ↓
保存 ScenePackageManifest
  ↓
进入已审核场景列表
```

LLM 输出不得包含审核字段。审核信息单独存储：

```ts
interface ScenePackageManifest {
  sceneId: string
  contentHash: string
  reviewedHash: string
  reviewStatus: 'draft' | 'approved' | 'rejected'
  reviewerId: string
  reviewedAt?: string
}
```

内容 hash 变化后自动回到 draft。未经审核的场景不可进入学员课程目录。

## 7. 页面架构

### 7.1 首页

首页必须是有限高度的 App Shell，主体内容放在唯一的滚动容器中，禁止页面整体和子页面同时产生无意义滚动。

结构：

```text
固定顶部栏
  - 品牌：智触心桥 SmartBridge
  - 当前画像
  - 设置入口

滚动主体
  - 欢迎卡片
  - 继续练习卡片
  - 今日待复习
  - L1 图标认知
  - L2 软件操作
  - L4 老人急救箱
  - 老师工具入口

固定底部导航
  - 首页
  - 课程
  - 复习
  - 设置
```

课程卡片使用分组、标签和短描述，不再将所有课程直接堆成一列巨大按钮。

### 7.2 课程目录页

- 按等级和生活域分组；
- 卡片显示标题、级别、完成状态、是否待复习；
- 老人模式自动增大字号和间距；
- 课程列表自身可滚动，但页面不能出现横向滚动；
- 使用语义化按钮和 `aria-label`。

### 7.3 练习页

结构：

```text
练习页顶部：返回、课程标题、步骤进度
安全提示条：练习模式，不会真实拨号/付款/修改设置
主练习区：截图或 synthetic 仿真屏幕
热点层：SVG 高亮、箭头、遮罩、小手动画
引导卡：当前唯一任务和双 persona 话术
角色区：说话状态、表情、重播
操作栏：重播、我不明白、暂停、退出
```

主练习区使用 `aspect-ratio` 和内容矩形映射，不能依赖固定 Android 像素。

### 7.4 老人模式

通过根节点属性和 CSS 变量控制：

```css
[data-persona='senior'] {
  --font-scale: 1.4;
  --button-min-height: 72px;
  --card-gap: 18px;
  --focus-ring-width: 4px;
}
```

老人模式不使用幼稚动画，显示尊重、平等、解释原因的文本。

### 7.5 老师预览页

- 显示场景草稿状态；
- 显示当前截图或 synthetic 界面；
- 显示每一步的动作、目标和双 persona 话术；
- 支持试玩；
- 明确显示“未审核，不会进入学员课程”；
- 审核人填写后才能保存；
- 保存后显示 hash 和审核时间。

## 8. 离线和 Android 方案

### P0 离线要求

- 首屏、内置课程、核心状态机、进度记录不依赖网络；
- 所有 JS、CSS、字体、课程 JSON 和必要图片都打包进 APK；
- 不使用外部 CDN；
- TTS 不可用时仍显示完整文字；
- 生成器网络失败不影响预制课程；
- IndexedDB 损坏时恢复默认画像并保留错误提示。

### Capacitor

初期只使用 Capacitor 的通用能力：

- Android APK 打包；
- 状态栏与返回键适配；
- 文件选择；
- 系统分享；
- 原生 TTS 增强。

暂不实现：

- AccessibilityService；
- 自动修改真实系统设置；
- 真实拨号与支付；
- 相机识别和录音识别。

## 9. 分阶段实施

### Phase 0：新 Web 工程基线

- 初始化 Vite React TypeScript；
- 配置严格 TypeScript；
- 配置 ESLint、Prettier、Vitest；
- 配置离线构建；
- 配置 Capacitor Android；
- 删除旧 Android UI 对新主线的依赖。

验收：浏览器可启动，Android 壳可构建，离线刷新可加载。

### Phase 1：TypeScript Core

- 完成 models；
- 完成 sceneValidator；
- 完成 gestureMatcher；
- 完成 promptLadder；
- 完成 guideEngine；
- 完成 progressTracker；
- 完成 simulationReducer；
- 为每个模块编写 Vitest 测试。

验收：核心测试覆盖正常、错误、超时、暂停、恢复、三次自动完成、L4 人工帮助、多屏和进度掌握。

### Phase 2：全新首页和课程目录

- 完成 AppShell；
- 完成首页分区布局；
- 完成课程卡片；
- 完成画像切换；
- 完成复习入口；
- 完成响应式和大字号适配。

验收：小屏、普通手机、平板宽度下无裁切、无横向滚动、课程内容可滚动。

### Phase 3：练习闭环

- 完成 PracticeSurface；
- 完成 ImageScreen；
- 完成 SyntheticScreen；
- 完成 SVG 热点层；
- 完成 tap、long press、swipe、type_char；
- 完成 observe、wait；
- 完成重播、帮助、暂停、完成反馈；
- 接入 SpeechSynthesis / 原生 TTS。

验收：至少三种课程跑通，六种动作均可测试，错误不会造成真实副作用。

### Phase 4：场景数据迁移

- 将 17 个内置课程迁移为 JSON；
- 建立场景构建时校验脚本；
- 资源路径校验；
- 预制课程版本管理；
- 将所有课程从代码常量迁移到 repository。

验收：断网打开 App 可浏览和练习全部内置课程。

### Phase 5：进度、复习和老师工具

- 完成 IndexedDB 存储；
- 完成会话和步骤记录；
- 完成待复习排序；
- 完成学习报告；
- 完成截图选择；
- 完成草稿预览；
- 完成人工审核和 manifest 保存。

验收：关闭、重新打开、修改内容 hash 后，状态和审核边界正确。

### Phase 6：Android 打包和验证

- Capacitor 同步 Android；
- 构建 debug APK；
- 构建 release APK；
- 在至少一个 Android ARM64 设备验证；
- 验证返回键、状态恢复、横竖屏策略、TTS、文件选择。

## 10. 测试策略

### Core 单元测试

必须覆盖：

- 画像默认值和话术选择；
- child 话术 12 字限制；
- 非法坐标和未知动作；
- URL、绝对路径、目录穿越拦截；
- 当前屏目标校验；
- 邻近热点精确命中优先；
- 长按时长；
- 滑动方向和距离；
- 单字符虚拟键；
- observe/wait 暴露完成；
- 10 秒超时辅助；
- 错误 1、2、3 档；
- screenshot guide 不自动完成；
- pause/resume 活动计时；
- 旧 operationId 不推进状态；
- 三个不同 session 的独立成功掌握；
- 自动完成不计独立成功；
- manifest hash 变化回到 draft。

### UI 测试

- 首页可滚动且没有横向溢出；
- 课程分组正确；
- 儿童/老人视觉参数变化正确；
- 练习页始终只显示一个当前任务；
- 错误提示和高亮显示正确；
- 完成页显示待复习状态；
- 草稿不可直接进入学员课程。

### E2E 测试

至少完成：

1. 首次启动选择儿童模式；
2. 选择 L1 电话图标课并完成；
3. 错误三次后显示复习标记；
4. 切换老人模式后字号和话术改变；
5. 选择截图进入老师预览；
6. 未审核草稿不可运行；
7. 刷新后画像和进度保留；
8. 断网仍可启动和完成预制课。

## 11. 不迁移的旧实现

以下 C# Android 实现不再作为 Web 主线依赖：

- `MainActivity` 的旧布局；
- Android Canvas 练习画布；
- 原生 UI 中的课程列表；
- C# `GuideEngine` 的旧 API；
- C# 内嵌课程常量。

C# 工程可以保留作为历史参考，但新的 Web 架构不能通过 WebView 反向调用它，也不能为了复用旧代码引入本地后端。

## 12. 完成标准

只有同时满足以下条件，才称为 Web 重构完成：

- 主线代码全部为 TypeScript/React；
- 浏览器开发模式和生产构建均成功；
- 离线模式可以启动；
- 首页不再出现裁切、巨大空白和横向溢出；
- 17 个内置场景可从 JSON 加载；
- 六种原子动作有可测试实现；
- 两种画像实际改变字号、话术、辅助和奖励；
- 本地进度在刷新和重启后保留；
- 非法场景被拦截；
- 生成草稿必须人工审核后才能保存；
- Capacitor Android APK 可以构建；
- 完成 Core、UI、E2E 测试；
- 文档明确 P0/P1 边界，不虚报真实系统设置自动化能力。

## 13. 首次实施顺序

严格按以下顺序执行：

1. 新建 Web 工程；
2. 写 TypeScript models；
3. 写 Core 单元测试；
4. 实现 validator 和 gesture matcher；
5. 实现 guide engine 和 progress tracker；
6. 用三个最小 JSON 场景验证 Core；
7. 实现新的首页；
8. 实现课程目录；
9. 实现练习页；
10. 迁移 17 个课程 JSON；
11. 实现 IndexedDB；
12. 实现老师预览和审核；
13. 接入 TTS；
14. 配置 PWA；
15. 配置 Capacitor；
16. 构建并验证 APK；
17. 最后再实现 P1 的联网场景生成和 Android 专用能力。

**核心原则：先让 Web 版本的离线预制课程、首页和练习闭环真正可用，再接入任何 LLM 或复杂 Android 能力。**
