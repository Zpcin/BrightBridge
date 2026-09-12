# P0 验收说明

## 已实现

- **画像**：儿童/老人模式切换；老人默认字号 1.4、逻辑容错 36dp、解释原因；画像写入应用私有目录。
- **引导 DSL**：课程→环节→微步骤；支持 observe、tap、long_press、swipe、type_char、wait；每步只有一个原子动作。
- **仿真沙盒**：内置课程仅绘制仿真界面；不声明真实拨号、付款、无障碍或系统设置权限。
- **提示阶梯**：错误后进入提示状态；三次错误在仿真场景自动完成并标记待复习；截图式真实设置引导不会自动代做，会进入人工帮助。
- **双模渲染基础**：synthetic Canvas 元素和目标热点；坐标固定为 1000×1000 逻辑面，视觉尺寸不因老人容错放大。
- **内容**：L1 图标认知 5 个、L2 操作 8 个、L4 急救箱 4 个，共 17 个内置场景。
- **本地数据**：画像、进度、审核后的生成场景使用 JSON；生成场景要求校验、老师 reviewerId 和 SHA-256 manifest，修改后审核失效。
- **中文语音**：Android 系统 TTS 可用时播报；无中文语音时仍保留可见文字。

## 构建验证

已在 Windows ARM64 环境验证：

```powershell
dotnet build .\src\SmartBridge.Android\SmartBridge.Android.csproj `
  -f net10.0-android `
  -p:AndroidSdkDirectory='C:\Users\yi\AndroidSdk' `
  -p:JavaSdkDirectory='C:\Program Files\Microsoft\jdk-17.0.20.101-hotspot' `
  -p:AndroidPackageFormat=apk `
  -p:RuntimeIdentifier=android-arm64 `
  -c Release
```

最后一次 Release 构建：0 warning、0 error。

## 明确边界

截图选取、LLM/ASR 生成器当前提供安全入口和审核存储边界，联网模型实现留作 P1；L4 当前为仿真/截图式练习，不会自动改变真实手机设置。AccessibilityService、实时控件树、离线 ASR 和生图属于后续版本。
