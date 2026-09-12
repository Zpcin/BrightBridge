using SmartBridge.Models;

namespace SmartBridge.Services;

public static class BuiltinScenes
{
    public static IReadOnlyList<LearningScene> All { get; } = CreateScenes();

    private static List<LearningScene> CreateScenes()
    {
        var scenes = new List<LearningScene>();
        scenes.AddRange([
            Icon("l1-phone", "认识电话图标", "电话", "phone", "绿色电话图标", "认准绿色听筒"),
            Icon("l1-wechat", "认识微信图标", "微信", "wechat", "绿色聊天图标", "认准绿色气泡"),
            Icon("l1-camera", "认识相机图标", "相机", "camera", "相机图标", "认准相机图案"),
            Icon("l1-settings", "认识设置图标", "设置", "settings", "齿轮图标", "认准齿轮图案"),
            Icon("l1-wifi", "认识 Wi-Fi 图标", "Wi-Fi", "wifi", "无线网络图标", "认准扇形信号"),
            TwoStep("l2-unlock", "练习解锁", "基础操作", "解锁", "lock", "密码键", AtomicAction.TypeChar),
            TwoStep("l2-dial", "练习拨号", "通讯", "拨号", "phone", "数字键", AtomicAction.Tap),
            TwoStep("l2-answer", "练习接听", "通讯", "接听电话", "answer", "绿色接听", AtomicAction.Tap),
            TwoStep("l2-hangup", "练习挂断", "通讯", "挂断电话", "hangup", "红色挂断", AtomicAction.Tap),
            TwoStep("l2-voice", "练习发送语音", "通讯", "长按发语音", "wechat", "按住说话", AtomicAction.LongPress),
            TwoStep("l2-volume", "练习调音量", "基础操作", "调大声音", "volume", "音量加号", AtomicAction.Tap),
            TwoStep("l2-flashlight", "练习打开手电筒", "基础操作", "打开手电筒", "flashlight", "手电筒", AtomicAction.Tap),
            TwoStep("l2-camera", "练习拍照", "基础操作", "拍一张照片", "camera", "白色快门", AtomicAction.Tap),
            Emergency("l4-font", "字体太小看不清", "显示", "显示设置", "display", "显示", "点显示设置，字会变大"),
            Emergency("l4-sound", "手机没有声音", "声音", "声音设置", "sound", "声音", "点声音设置，检查媒体音量"),
            Emergency("l4-wifi", "连接 Wi-Fi", "网络", "无线网络", "wifi", "Wi-Fi", "点无线网络，选择熟悉的网络"),
            Emergency("l4-scam", "识别可疑信息", "安全", "诈骗识别", "warning", "不点击", "陌生链接不要点开")
        ]);
        return scenes;
    }

    private static LearningScene Icon(string id, string title, string label, string iconId, string childSay, string seniorSay)
    {
        var target = Element(iconId, "icon", label, 35, 35, 30, 20, "#D7F5E5");
        return Scene(id, title, "图标认知", "L1", target, [
            Step($"{id}-observe", AtomicAction.Observe, target.Id, new(childSay, seniorSay)),
            Step($"{id}-tap", AtomicAction.Tap, target.Id, new($"点{label}", $"请点{label}图标"))
        ]);
    }

    private static LearningScene TwoStep(string id, string title, string domain, string summary, string targetId, string targetLabel, AtomicAction action)
    {
        var target = Element(targetId, "button", targetLabel, 25, 40, 50, 18, action == AtomicAction.LongPress ? "#DCEBFF" : "#EAF3FF");
        var secondAction = action == AtomicAction.TypeChar ? AtomicAction.TypeChar : action;
        return Scene(id, title, domain, "L2", target, [
            Step($"{id}-observe", AtomicAction.Observe, target.Id, new($"这是{summary}", $"这是{summary}界面")),
            Step($"{id}-act", secondAction, target.Id, new($"点{targetLabel}", $"请操作{targetLabel}"))
        ]);
    }

    private static LearningScene Emergency(string id, string title, string domain, string summary, string targetId, string targetLabel, string why)
    {
        var target = Element(targetId, "button", targetLabel, 20, 42, 60, 16, "#FFF0D6");
        return Scene(id, title, domain, "L4", target, [
            Step($"{id}-observe", AtomicAction.Observe, target.Id, new("这是设置页面", $"这是设置页面。{why}")),
            Step($"{id}-tap", AtomicAction.Tap, target.Id, new($"点{targetLabel}", $"请点{targetLabel}。{why}"))
        ], seniorOnly: true);
    }

    private static LearningScene Scene(string id, string title, string domain, string level, ScreenElement target, IEnumerable<LearningStep> steps, bool seniorOnly = false)
    {
        return new LearningScene
        {
            Id = id, Title = title, Domain = domain, Level = level, Summary = "练习模式：不会真的拨号、付款或修改手机设置。", SeniorOnly = seniorOnly,
            Screen = new ScreenDefinition { Type = "synthetic", Style = level == "L4" ? "app_light" : "app_dark", Elements = [
                new ScreenElement { Id = "header", Kind = "text", Text = "小引导 · 练习模式", Color = "#FFFFFF", X = 0, Y = 0, Width = 100, Height = 14 }, target
            ]},
            Phases = [new LearningPhase { Id = $"{id}-phase", Title = title, Steps = steps.ToList() }]
        };
    }

    private static ScreenElement Element(string id, string kind, string text, float x, float y, float width, float height, string color) =>
        new() { Id = id, Kind = kind, Text = text, X = x, Y = y, Width = width, Height = height, Color = color };

    private static LearningStep Step(string id, AtomicAction action, string targetId, SpeechText say) => new()
    {
        Id = id, Action = action, TargetId = targetId, Say = say,
        Prompts = [
            new PromptLevel { Id = $"{id}-prompt-1", Trigger = "wrongActionCount", AfterErrors = 1, Effect = "arrow_dim", Say = new("看这里，试试", "这个按钮藏得有点深，我们看这里") },
            new PromptLevel { Id = $"{id}-prompt-2", Trigger = "wrongActionCount", AfterErrors = 2, Effect = "hand_demo", Say = new("我做一次给你看", "我先示范一次，您再试试") },
            new PromptLevel { Id = $"{id}-prompt-3", Trigger = "wrongActionCount", AfterErrors = 3, Effect = "auto_complete_review", Say = new("这次我帮你", "这次我帮您完成，下次会更熟悉") }
        ]
    };
}
