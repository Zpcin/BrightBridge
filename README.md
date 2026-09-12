# 小引导（C# Android MVP）

面向培智学生、自闭症人士、银发老人和数字新手的本地仿真练习 App。全部练习不会真实拨号、付款或修改系统设置。

## 项目

- `src/SmartBridge.Core`：纯 .NET 10 领域模型、DSL、校验器、引导状态机、本地 JSON 存储、17 个内置课程。
- `src/SmartBridge.Android`：原生 .NET Android 单 Activity、Canvas 仿真界面、儿童/老人画像、TTS/生成器入口预留。

## 构建 APK

```powershell
dotnet build .\src\SmartBridge.Android\SmartBridge.Android.csproj -f net10.0-android -p:AndroidSdkDirectory="$env:ANDROID_HOME" -p:JavaSdkDirectory="$env:JAVA_HOME" -p:AndroidPackageFormat=apk -p:RuntimeIdentifier=android-arm64 -c Release
```

本机验证环境：.NET SDK 10.0.300、Android workload 36.1.43、OpenJDK 17、Android API 35/36。输出位于 `src/SmartBridge.Android/bin/Release/net10.0-android/android-arm64/`。

## P0 内容

L1 图标认知 5 个；L2 基础/通讯操作 8 个；L4 老人急救 4 个。L4 当前按计划采用仿真/截图式引导，不申请无障碍权限，不直接修改真实系统。
