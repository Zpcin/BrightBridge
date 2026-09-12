using SmartBridge.Models;

namespace SmartBridge.Services;

/// <summary>
/// Updates durable learning progress from completed sessions. Only three independent
/// successes of the same step count toward mastery; prompted, exposure and auto-completed
/// attempts remain visible but never inflate independent mastery.
/// </summary>
public sealed class ProgressTracker
{
    public const int MasteryIndependentAttempts = 3;

    public void Record(LearningProgress progress, SessionResult session)
    {
        ArgumentNullException.ThrowIfNull(progress);
        ArgumentNullException.ThrowIfNull(session);
        if (string.IsNullOrWhiteSpace(session.SceneId))
            throw new ArgumentException("session.SceneId 不能为空", nameof(session));
        progress.Sessions.RemoveAll(x => string.Equals(x.Id, session.Id, StringComparison.OrdinalIgnoreCase));
        progress.Sessions.Add(session);
    }

    public LearningProgress AddSession(LearningProgress progress, SessionResult session)
    {
        ArgumentNullException.ThrowIfNull(progress);
        ArgumentNullException.ThrowIfNull(session);
        if (string.IsNullOrWhiteSpace(session.SceneId))
            throw new ArgumentException("session.SceneId 不能为空", nameof(session));
        if (!progress.Sessions.Any(x => string.Equals(x.Id, session.Id, StringComparison.OrdinalIgnoreCase)))
            progress.Sessions.Add(session);
        return progress;
    }

    public bool IsMastered(LearningProgress progress, string sceneId) =>
        progress is not null && !string.IsNullOrWhiteSpace(sceneId) &&
        progress.Sessions.Where(x => x.Completed && string.Equals(x.SceneId, sceneId, StringComparison.OrdinalIgnoreCase))
            .SelectMany(x => x.Steps)
            .GroupBy(x => x.StepId, StringComparer.OrdinalIgnoreCase)
            .Any(group => group.Count(x => x.Outcome == AttemptOutcome.IndependentSuccess) >= MasteryIndependentAttempts);

    public IReadOnlySet<string> MasteredStepIds(LearningProgress progress, string sceneId)
    {
        if (progress is null || string.IsNullOrWhiteSpace(sceneId)) return new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        return progress.Sessions.Where(x => x.Completed && string.Equals(x.SceneId, sceneId, StringComparison.OrdinalIgnoreCase))
            .SelectMany(x => x.Steps)
            .Where(x => x.Outcome == AttemptOutcome.IndependentSuccess)
            .GroupBy(x => x.StepId, StringComparer.OrdinalIgnoreCase)
            .Where(x => x.Count() >= MasteryIndependentAttempts)
            .Select(x => x.Key)
            .ToHashSet(StringComparer.OrdinalIgnoreCase);
    }

    public bool HasReviewNeeded(SessionResult session) =>
        session is not null && session.Steps.Any(x => x.Outcome is AttemptOutcome.PromptedSuccess or AttemptOutcome.AutoCompleted or AttemptOutcome.Aborted);

    public IReadOnlyList<SessionResult> ReviewSessions(LearningProgress progress, string? sceneId = null)
    {
        if (progress is null) return [];
        return progress.Sessions
            .Where(x => (sceneId is null || string.Equals(x.SceneId, sceneId, StringComparison.OrdinalIgnoreCase)) && HasReviewNeeded(x))
            .OrderByDescending(x => x.CompletedAt)
            .ToList();
    }

    public double IndependentSuccessRate(SessionResult session)
    {
        if (session is null || session.Steps.Count == 0) return 0;
        return (double)session.Steps.Count(x => x.Outcome == AttemptOutcome.IndependentSuccess) / session.Steps.Count;
    }

    public string Summary(LearningProgress progress, string sceneId)
    {
        var sessions = progress.Sessions.Where(x => x.SceneId == sceneId && x.Completed).ToList();
        var independent = sessions.SelectMany(x => x.Steps).Count(x => x.Outcome == AttemptOutcome.IndependentSuccess);
        var prompted = sessions.SelectMany(x => x.Steps).Count(x => x.Outcome == AttemptOutcome.PromptedSuccess);
        var review = sessions.SelectMany(x => x.Steps).Count(x => x.Outcome is AttemptOutcome.AutoCompleted or AttemptOutcome.Aborted);
        return $"练习 {sessions.Count} 次 · 自己完成 {independent} 步 · 得到帮助 {prompted} 步 · 待复习 {review} 步";
    }
}
