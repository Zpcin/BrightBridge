using SmartBridge.Models;

namespace SmartBridge.Services;

/// <summary>A normalized (0..1000) learner gesture submitted by a renderer.</summary>
public sealed record GestureInput(
    AtomicAction Action,
    string? TargetId = null,
    string? Value = null,
    float? X = null,
    float? Y = null,
    float? ToX = null,
    float? ToY = null,
    int DurationMs = 0,
    // Physical pixels are optional; coordinates themselves are always normalized 0..1000.
    int SurfaceWidth = 0,
    int SurfaceHeight = 0);

/// <summary>Result of matching one gesture against the current atomic step.</summary>
public sealed record GestureMatchResult(bool IsMatch, string Reason)
{
    public static GestureMatchResult Match() => new(true, "匹配");
    public static GestureMatchResult Mismatch(string reason) => new(false, reason);
}

/// <summary>
/// Performs logical hit testing independently of Android. Visual controls remain at their
/// authored size; profile tolerance only expands the invisible hit area.
/// </summary>
public sealed class GestureMatcher
{
    private const float SurfaceSize = 1000f;

    public GestureMatchResult Match(
        LearningStep step,
        ScreenDefinition screen,
        GestureInput input,
        LearnerProfile? profile = null)
    {
        ArgumentNullException.ThrowIfNull(step);
        ArgumentNullException.ThrowIfNull(screen);
        ArgumentNullException.ThrowIfNull(input);
        profile ??= LearnerProfile.ChildDefaults();

        if (step.Action != input.Action)
            return GestureMatchResult.Mismatch("动作不正确");
        if (step.Action is AtomicAction.Observe or AtomicAction.Wait)
            return GestureMatchResult.Mismatch("observe 和 wait 不能由触摸动作完成");

        var target = ResolveTarget(step, screen, input, profile, out var targetError);
        if (target is null)
            return GestureMatchResult.Mismatch(targetError);
        if (!target.Interactive)
            return GestureMatchResult.Mismatch("目标不可操作");

        return step.Action switch
        {
            AtomicAction.Tap => MatchTap(target, input, profile),
            AtomicAction.LongPress => MatchLongPress(target, step, input, profile),
            AtomicAction.Swipe => MatchSwipe(target, step, input, profile),
            AtomicAction.TypeChar => MatchTypeChar(step, target, input, profile),
            _ => GestureMatchResult.Mismatch("未知动作")
        };
    }

    public bool IsMatch(LearningStep step, ScreenDefinition screen, GestureInput input, LearnerProfile? profile = null) =>
        Match(step, screen, input, profile).IsMatch;

    private static ScreenElement? ResolveTarget(
        LearningStep step,
        ScreenDefinition screen,
        GestureInput input,
        LearnerProfile profile,
        out string error)
    {
        error = "目标元素不存在";
        if (string.IsNullOrWhiteSpace(step.TargetId))
        {
            error = "步骤缺少目标元素";
            return null;
        }

        var target = screen.Elements.FirstOrDefault(e =>
            e is not null && string.Equals(e.Id, step.TargetId, StringComparison.OrdinalIgnoreCase));
        if (target is null)
        {
            error = "目标不在当前屏幕中";
            return null;
        }
        if (!string.IsNullOrWhiteSpace(input.TargetId) &&
            !string.Equals(input.TargetId, target.Id, StringComparison.OrdinalIgnoreCase))
        {
            error = "点到了错误的目标";
            return null;
        }

        // If the renderer reports coordinates, require them to hit the expected control.
        // An ID-only event is accepted for renderers that have already performed hit testing.
        if (input.X.HasValue || input.Y.HasValue)
        {
            if (!input.X.HasValue || !input.Y.HasValue ||
                !IsInside(target, input.X.Value, input.Y.Value, profile, input))
            {
                error = "触点不在目标范围内";
                return null;
            }
        }
        return target;
    }

    private static GestureMatchResult MatchTap(ScreenElement target, GestureInput input, LearnerProfile profile)
    {
        if (input.DurationMs < 0) return GestureMatchResult.Mismatch("点击时长无效");
        return GestureMatchResult.Match();
    }

    private static GestureMatchResult MatchLongPress(ScreenElement target, LearningStep step, GestureInput input, LearnerProfile profile)
    {
        var required = Math.Max(1, step.DurationMs);
        return input.DurationMs >= required
            ? GestureMatchResult.Match()
            : GestureMatchResult.Mismatch($"按住时间不足，需要至少{required}毫秒");
    }

    private static GestureMatchResult MatchSwipe(ScreenElement target, LearningStep step, GestureInput input, LearnerProfile profile)
    {
        if (!input.ToX.HasValue || !input.ToY.HasValue)
            return GestureMatchResult.Mismatch("滑动缺少终点");
        if (!IsFiniteCoordinate(input.ToX.Value) || !IsFiniteCoordinate(input.ToY.Value))
            return GestureMatchResult.Mismatch("滑动终点无效");
        if (!Near(input.ToX.Value, step.ToX, profile, input) || !Near(input.ToY.Value, step.ToY, profile, input))
            return GestureMatchResult.Mismatch("滑动方向或终点不正确");
        if (input.X.HasValue && input.Y.HasValue &&
            MathF.Abs(input.ToX.Value - input.X.Value) < 1 && MathF.Abs(input.ToY.Value - input.Y.Value) < 1)
            return GestureMatchResult.Mismatch("滑动距离太短");
        return GestureMatchResult.Match();
    }

    private static GestureMatchResult MatchTypeChar(LearningStep step, ScreenElement target, GestureInput input, LearnerProfile profile)
    {
        if (!string.IsNullOrWhiteSpace(step.InputId) &&
            !string.Equals(step.InputId, input.TargetId, StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(step.InputId, target.Id, StringComparison.OrdinalIgnoreCase))
            return GestureMatchResult.Mismatch("输入框不正确");
        if (!string.IsNullOrWhiteSpace(step.Character) && !string.Equals(step.Character, input.Value, StringComparison.Ordinal))
            return GestureMatchResult.Mismatch("输入字符不正确");
        if (input.Value is not null && input.Value.Length != 1)
            return GestureMatchResult.Mismatch("一次只能输入一个字符");
        return GestureMatchResult.Match();
    }

    private static bool IsInside(ScreenElement target, float x, float y, LearnerProfile profile, GestureInput input)
    {
        if (!IsFiniteCoordinate(x) || !IsFiniteCoordinate(y)) return false;
        var toleranceX = NormalizedTolerance(profile.TapTolerance, input.SurfaceWidth);
        var toleranceY = NormalizedTolerance(profile.TapTolerance, input.SurfaceHeight);
        return x >= target.X - toleranceX && x <= target.X + target.Width + toleranceX &&
               y >= target.Y - toleranceY && y <= target.Y + target.Height + toleranceY;
    }

    private static bool Near(float actual, float expected, LearnerProfile profile, GestureInput input) =>
        IsFiniteCoordinate(actual) && IsFiniteCoordinate(expected) &&
        MathF.Abs(actual - expected) <= NormalizedTolerance(profile.TapTolerance, Math.Min(input.SurfaceWidth, input.SurfaceHeight));

    private static float NormalizedTolerance(int tolerance, int pixels)
    {
        if (tolerance <= 0 || pixels <= 0) return 0;
        // Core receives normalized coordinates. For a physical surface, convert dp tolerance
        // back to the normalized surface; zero means the caller already hit-tested.
        return MathF.Min(SurfaceSize / 2, tolerance * SurfaceSize / pixels);
    }

    private static bool IsFiniteCoordinate(float value) =>
        !float.IsNaN(value) && !float.IsInfinity(value) && value >= 0 && value <= SurfaceSize;
}
