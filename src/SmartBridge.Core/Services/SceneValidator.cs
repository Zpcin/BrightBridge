using System.Globalization;
using System.Text;
using SmartBridge.Models;

namespace SmartBridge.Services;

/// <summary>A deterministic validation problem. Generated scenes must have no issues before they can be saved.</summary>
public sealed record ValidationIssue(string Path, string Message);

/// <summary>
/// Validates the closed scene DSL before a scene is rendered or persisted.
/// This validator deliberately treats malformed/generated content as unsafe: a scene is
/// usable only when <see cref="Validate"/> returns an empty list.
/// </summary>
public sealed class SceneValidator
{
    public const float SurfaceSize = 1000f;
    private const int MaxChildSpeechCharacters = 12;
    private const int MaxSeniorSpeechCharacters = 30;
    private const int MaxWaitSeconds = 120;
    private const int MaxStepDurationMs = 30_000;

    private static readonly HashSet<string> ScreenTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "image", "synthetic"
    };

    private static readonly HashSet<string> SyntheticStyles = new(StringComparer.OrdinalIgnoreCase)
    {
        "kiosk", "atm", "pos", "app_light", "app_dark"
    };

    private static readonly HashSet<string> ElementKinds = new(StringComparer.OrdinalIgnoreCase)
    {
        "button", "icon", "text", "image", "input", "keyboard_key", "toggle",
        "link", "indicator", "card", "label"
    };

    private static readonly HashSet<string> PromptEffects = new(StringComparer.OrdinalIgnoreCase)
    {
        "repeat", "flash", "arrow_dim", "hand_demo", "auto_complete_review"
    };

    // These words make a single instruction ambiguous. "再" is intentionally included;
    // generated content can use "再试试" only in prompt text, not in the atomic action.
    private static readonly string[] SplitWords = ["然后", "接着", "之后"];

    // LLM output must never smuggle a prompt or executable instruction into learner speech.
    private static readonly string[] AssistantInjectionMarkers =
    [
        "忽略之前", "忽略上面的", "系统提示", "开发者提示", "system:", "developer:",
        "assistant:", "tool_call", "工具调用", "<script", "javascript:"
    ];

    public IReadOnlyList<ValidationIssue> Validate(LearningScene? scene)
    {
        var issues = new List<ValidationIssue>();
        if (scene is null)
        {
            issues.Add(new("scene", "场景不能为空"));
            return issues;
        }

        RequireText(scene.Id, "id", "场景必须有 id", issues, 80);
        RequireText(scene.Title, "title", "场景必须有标题", issues, 100);
        RequireText(scene.Domain, "domain", "场景必须有生活域", issues, 80);
        RequireText(scene.Level, "level", "场景必须有等级", issues, 10);
        ValidateSafeText(scene.Title, "title", issues);
        ValidateSafeText(scene.Domain, "domain", issues);
        ValidateSafeText(scene.Summary, "summary", issues);
        ValidateSafeText(scene.Icon, "icon", issues);

        if (scene.SchemaVersion is < 1 or > 1)
            issues.Add(new("schemaVersion", "不支持的场景版本"));
        if (!Enum.IsDefined(scene.ExecutionMode))
            issues.Add(new("executionMode", "执行模式无效"));
        if (scene.ExecutionMode == ExecutionMode.LiveSettingsGuide)
            issues.Add(new("executionMode", "Core 场景不能直接执行真实系统设置"));
        if (!new[] { "L0", "L1", "L2", "L3", "L4" }.Contains(scene.Level, StringComparer.OrdinalIgnoreCase))
            issues.Add(new("level", "等级必须是 L0、L1、L2、L3 或 L4"));

        // The Core DSL is a simulator. Real settings, dialing, payment, deletion and power
        // operations belong to explicit Android integrations and cannot be represented here.
        if (!scene.Sandbox)
            issues.Add(new("sandbox", "Core 场景必须是仿真沙盒，不能执行真实操作"));

        if (scene.Phases is null || scene.Phases.Count == 0)
        {
            issues.Add(new("phases", "至少需要一个环节"));
            return issues;
        }

        if (scene.Phases.Any(p => p is null))
            issues.Add(new("phases", "环节不能为 null"));

        var phaseIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var stepIds = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var rootElements = ValidateScreen(scene.Screen, "screen", issues);

        for (var phaseIndex = 0; phaseIndex < scene.Phases.Count; phaseIndex++)
        {
            var phase = scene.Phases[phaseIndex];
            if (phase is null) continue;
            var phasePath = $"phases[{phaseIndex}]";

            RequireText(phase.Id, $"{phasePath}.id", "环节必须有 id", issues, 80);
            RequireText(phase.Title, $"{phasePath}.title", "环节必须有标题", issues, 100);
            ValidateSafeText(phase.Title, $"{phasePath}.title", issues);
            if (!string.IsNullOrWhiteSpace(phase.Id) && !phaseIds.Add(phase.Id))
                issues.Add(new($"{phasePath}.id", "环节 id 不能重复"));

            var elements = phase.Screen is null
                ? rootElements
                : ValidateScreen(phase.Screen, $"{phasePath}.screen", issues);

            if (phase.Steps is null || phase.Steps.Count == 0)
            {
                issues.Add(new($"{phasePath}.steps", "环节不能没有步骤"));
                continue;
            }

            for (var stepIndex = 0; stepIndex < phase.Steps.Count; stepIndex++)
            {
                var step = phase.Steps[stepIndex];
                if (step is null)
                {
                    issues.Add(new($"{phasePath}.steps[{stepIndex}]", "步骤不能为 null"));
                    continue;
                }

                var path = $"{phasePath}.steps[{stepIndex}]";
                RequireText(step.Id, $"{path}.id", "步骤必须有 id", issues, 100);
                if (!string.IsNullOrWhiteSpace(step.Id) && !stepIds.Add(step.Id))
                    issues.Add(new($"{path}.id", "步骤 id 必须在整个场景内唯一"));
                ValidateSafeText(step.Character, $"{path}.character", issues);
                ValidateSpeech(step.Say, $"{path}.say", issues);
                ValidatePrompts(step.Prompts, path, issues);

                if (!Enum.IsDefined(step.Action))
                {
                    issues.Add(new($"{path}.action", "动作不在允许的六种原子动作内"));
                    continue;
                }

                if (step.DurationMs < 0 || step.DurationMs > MaxStepDurationMs)
                    issues.Add(new($"{path}.durationMs", $"动作时长必须在 0 到 {MaxStepDurationMs} 毫秒之间"));
                if (step.WaitSeconds < 0 || step.WaitSeconds > MaxWaitSeconds)
                    issues.Add(new($"{path}.waitSeconds", $"等待秒数必须在 0 到 {MaxWaitSeconds} 秒之间"));

                var target = ResolveElement(elements, step.TargetId);
                var targetRequired = step.Action is AtomicAction.Tap or AtomicAction.LongPress
                    or AtomicAction.Swipe or AtomicAction.TypeChar;
                if (targetRequired && target is null)
                    issues.Add(new($"{path}.targetId", "点按、长按、滑动和输入动作必须指向当前屏幕中的元素"));
                if (targetRequired && target is not null && !target.Interactive)
                    issues.Add(new($"{path}.targetId", "目标元素不可交互"));
                if (!string.IsNullOrWhiteSpace(step.TargetId) && target is null)
                    issues.Add(new($"{path}.targetId", "目标元素不在当前环节的屏幕中"));

                switch (step.Action)
                {
                    case AtomicAction.Observe:
                        // WaitSeconds is also the renderer's idle timeout and historically
                        // defaults to ten seconds. It is therefore allowed on observe steps;
                        // only the explicit wait action uses it as completion duration.
                        break;
                    case AtomicAction.Wait:
                        if (step.WaitSeconds <= 0)
                            issues.Add(new($"{path}.waitSeconds", "wait 步骤必须配置正数等待秒数"));
                        if (!string.IsNullOrWhiteSpace(step.TargetId))
                            issues.Add(new($"{path}.targetId", "wait 步骤不应绑定点击目标"));
                        break;
                    case AtomicAction.LongPress:
                        if (step.DurationMs == 0)
                            issues.Add(new($"{path}.durationMs", "long_press 必须配置按住时长"));
                        break;
                    case AtomicAction.Swipe:
                        ValidateCoordinate(step.ToX, $"{path}.toX", issues);
                        ValidateCoordinate(step.ToY, $"{path}.toY", issues);
                        if (step.ToX == 0 && step.ToY == 0)
                            issues.Add(new($"{path}.toX", "swipe 必须配置终点坐标"));
                        if (target is not null &&
                            MathF.Abs(step.ToX - (target.X + target.Width / 2)) < 1 &&
                            MathF.Abs(step.ToY - (target.Y + target.Height / 2)) < 1)
                            issues.Add(new($"{path}.toX", "swipe 终点不能与起点目标中心相同"));
                        break;
                    case AtomicAction.TypeChar:
                        ValidateTypeInput(step, path, issues);
                        break;
                }
            }
        }

        return issues;
    }

    public void ValidateOrThrow(LearningScene scene)
    {
        var issues = Validate(scene);
        if (issues.Count == 0) return;
        throw new InvalidDataException(string.Join(Environment.NewLine, issues.Select(i => $"{i.Path}: {i.Message}")));
    }

    private static Dictionary<string, ScreenElement> ValidateScreen(
        ScreenDefinition? screen, string path, ICollection<ValidationIssue> issues)
    {
        var result = new Dictionary<string, ScreenElement>(StringComparer.OrdinalIgnoreCase);
        if (screen is null)
        {
            issues.Add(new(path, "屏幕定义不能为空"));
            return result;
        }

        var type = screen.Type?.Trim() ?? string.Empty;
        if (!ScreenTypes.Contains(type))
            issues.Add(new($"{path}.type", "屏幕类型只能是 image 或 synthetic"));
        if (string.Equals(type, "synthetic", StringComparison.OrdinalIgnoreCase) &&
            !SyntheticStyles.Contains(screen.Style ?? string.Empty))
            issues.Add(new($"{path}.style", "synthetic 屏幕样式不在允许的模板内"));
        if (string.Equals(type, "image", StringComparison.OrdinalIgnoreCase))
        {
            if (string.IsNullOrWhiteSpace(screen.Source))
                issues.Add(new($"{path}.source", "image 屏幕必须有本地资源路径"));
            else if (!IsSafeAssetPath(screen.Source))
                issues.Add(new($"{path}.source", "屏幕资源必须是应用内相对路径，禁止 URL、绝对路径和目录穿越"));
        }
        if (screen.Elements is null || screen.Elements.Count == 0)
            issues.Add(new($"{path}.elements", "屏幕至少需要一个元素或热点"));

        var screenElements = screen.Elements ?? [];
        for (var index = 0; index < screenElements.Count; index++)
        {
            var element = screenElements[index];
            var elementPath = $"{path}.elements[{index}]";
            if (element is null)
            {
                issues.Add(new(elementPath, "元素不能为 null"));
                continue;
            }
            RequireText(element.Id, $"{elementPath}.id", "元素必须有 id", issues, 100);
            if (!string.IsNullOrWhiteSpace(element.Id) && !result.TryAdd(element.Id, element))
                issues.Add(new($"{elementPath}.id", "同一屏幕内元素 id 不能重复"));
            RequireText(element.Kind, $"{elementPath}.kind", "元素必须有类型", issues, 40);
            if (!ElementKinds.Contains(element.Kind ?? string.Empty))
                issues.Add(new($"{elementPath}.kind", "元素类型不在允许的模板类型内"));
            ValidateSafeText(element.Text, $"{elementPath}.text", issues);
            ValidateSafeText(element.Icon, $"{elementPath}.icon", issues);
            ValidateColor(element.Color, $"{elementPath}.color", issues);
            ValidateRect(element.X, element.Y, element.Width, element.Height, elementPath, issues);
        }
        return result;
    }

    private static void ValidateSpeech(SpeechText? speech, string path, ICollection<ValidationIssue> issues)
    {
        if (speech is null)
        {
            issues.Add(new(path, "步骤必须有 child/senior 双轨话术"));
            return;
        }
        RequireText(speech.Child, $"{path}.child", "child 话术不能为空", issues, MaxChildSpeechCharacters);
        RequireText(speech.Senior, $"{path}.senior", "senior 话术不能为空", issues, MaxSeniorSpeechCharacters);
        if (CountText(speech.Child) > MaxChildSpeechCharacters)
            issues.Add(new($"{path}.child", "child 话术不能超过12字"));
        if (CountText(speech.Senior) > MaxSeniorSpeechCharacters)
            issues.Add(new($"{path}.senior", "senior 话术不能超过30字"));
        ValidateSafeText(speech.Child, $"{path}.child", issues);
        ValidateSafeText(speech.Senior, $"{path}.senior", issues);
        ValidateSafeText(speech.SeniorWhy, $"{path}.seniorWhy", issues);
        foreach (var word in SplitWords)
        {
            if (speech.Child.Contains(word, StringComparison.Ordinal) || speech.Senior.Contains(word, StringComparison.Ordinal))
                issues.Add(new(path, $"话术包含拆分红线连接词：{word}"));
        }
    }

    private static void ValidatePrompts(List<PromptLevel>? prompts, string path, ICollection<ValidationIssue> issues)
    {
        if (prompts is null || prompts.Count == 0)
        {
            issues.Add(new($"{path}.prompts", "每步必须包含三级辅助阶梯"));
            return;
        }
        var seen = new HashSet<int>();
        for (var i = 0; i < prompts.Count; i++)
        {
            var prompt = prompts[i];
            var promptPath = $"{path}.prompts[{i}]";
            if (prompt is null)
            {
                issues.Add(new(promptPath, "辅助提示不能为 null"));
                continue;
            }
            if (prompt.AfterErrors is < 1 or > 3)
                issues.Add(new($"{promptPath}.afterErrors", "辅助阶梯触发次数必须是1、2或3"));
            else if (!seen.Add(prompt.AfterErrors))
                issues.Add(new($"{promptPath}.afterErrors", "辅助阶梯触发次数不能重复"));
            if (!PromptEffects.Contains(prompt.Effect ?? string.Empty))
                issues.Add(new($"{promptPath}.effect", "辅助效果不在允许的枚举内"));
            ValidateSpeech(prompt.Say, $"{promptPath}.say", issues);
            if (prompt.AfterErrors == 3 && !string.Equals(prompt.Effect, "auto_complete_review", StringComparison.OrdinalIgnoreCase))
                issues.Add(new($"{promptPath}.effect", "第3级辅助必须是 auto_complete_review"));
        }
        for (var expected = 1; expected <= 3; expected++)
            if (!seen.Contains(expected)) issues.Add(new($"{path}.prompts", $"缺少第{expected}级辅助"));
    }

    private static void ValidateTypeInput(LearningStep step, string path, ICollection<ValidationIssue> issues)
    {
        if (!string.IsNullOrWhiteSpace(step.Character) && CountText(step.Character) != 1)
            issues.Add(new($"{path}.character", "type_char 的 character 必须恰好一个字符"));
        if (!string.IsNullOrWhiteSpace(step.InputId) && !IsSafeId(step.InputId))
            issues.Add(new($"{path}.inputId", "inputId 只能包含字母、数字、下划线和短横线"));
        if (string.IsNullOrWhiteSpace(step.Character) && string.IsNullOrWhiteSpace(step.InputId) && string.IsNullOrWhiteSpace(step.TargetId))
            issues.Add(new(path, "type_char 必须有 character、inputId 或 targetId"));
    }

    private static void ValidateRect(float x, float y, float width, float height, string path, ICollection<ValidationIssue> issues)
    {
        ValidateCoordinate(x, $"{path}.x", issues);
        ValidateCoordinate(y, $"{path}.y", issues);
        ValidateCoordinate(width, $"{path}.width", issues);
        ValidateCoordinate(height, $"{path}.height", issues);
        if (width <= 0 || height <= 0)
            issues.Add(new(path, "元素宽高必须大于0"));
        if (x < 0 || y < 0 || x + width > SurfaceSize || y + height > SurfaceSize)
            issues.Add(new(path, "元素坐标和尺寸必须完全位于0到1000范围内"));
    }

    private static void ValidateCoordinate(float value, string path, ICollection<ValidationIssue> issues)
    {
        if (float.IsNaN(value) || float.IsInfinity(value) || value < 0 || value > SurfaceSize)
            issues.Add(new(path, "坐标必须是0到1000范围内的有限数字"));
    }

    private static void ValidateColor(string? color, string path, ICollection<ValidationIssue> issues)
    {
        if (string.IsNullOrWhiteSpace(color) ||
            !System.Text.RegularExpressions.Regex.IsMatch(color, "^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$"))
            issues.Add(new(path, "颜色必须是 #RRGGBB 或 #RRGGBBAA"));
    }

    private static ScreenElement? ResolveElement(IReadOnlyDictionary<string, ScreenElement> elements, string? id) =>
        !string.IsNullOrWhiteSpace(id) && elements.TryGetValue(id, out var element) ? element : null;

    private static void RequireText(string? value, string path, string message, ICollection<ValidationIssue> issues, int maxLength)
    {
        if (string.IsNullOrWhiteSpace(value)) issues.Add(new(path, message));
        else if (CountText(value) > maxLength) issues.Add(new(path, $"文本长度不能超过{maxLength}字"));
    }

    private static void ValidateSafeText(string? value, string path, ICollection<ValidationIssue> issues)
    {
        if (string.IsNullOrEmpty(value)) return;
        if (value.Any(char.IsControl)) issues.Add(new(path, "文本不能包含控制字符"));
        foreach (var marker in AssistantInjectionMarkers)
            if (value.Contains(marker, StringComparison.OrdinalIgnoreCase))
                issues.Add(new(path, "文本包含不允许的 assistant/脚本指令"));
    }

    private static bool IsSafeAssetPath(string path)
    {
        if (string.IsNullOrWhiteSpace(path) || Path.IsPathRooted(path)) return false;
        if (path.Contains('\0') || path.Contains("..", StringComparison.Ordinal)) return false;
        if (path.StartsWith("/", StringComparison.Ordinal) || path.Contains("://", StringComparison.Ordinal)) return false;
        return path.All(c => char.IsLetterOrDigit(c) || c is '/' or '\\' or '.' or '_' or '-');
    }

    private static bool IsSafeId(string value) => value.Length <= 100 && value.All(c => char.IsLetterOrDigit(c) || c is '_' or '-');

    private static int CountText(string? value) => value is null ? 0 : new StringInfo(value).LengthInTextElements;
}
