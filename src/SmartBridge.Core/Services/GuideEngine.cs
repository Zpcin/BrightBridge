using SmartBridge.Models;

namespace SmartBridge.Services;

public enum GuideState { Idle, Greeting, Demonstrating, AwaitingAction, ApplyingPrompt, Success, Completed, Paused, NeedHumanHelp }

public sealed record GuideSnapshot(GuideState State, int PhaseIndex, int StepIndex, int WrongActions, int AssistanceLevel, bool NeedsReview, DateTimeOffset StepStartedAt);
public sealed record GuideEventResult(GuideSnapshot Snapshot, string Message, bool IsCorrect, bool IsFinished, AttemptOutcome? Outcome = null);

/// <summary>本地练习状态机：只处理仿真，不调用拨号、付款或真实系统设置。</summary>
public sealed class GuideEngine
{
    private readonly LearningScene _scene;
    private readonly LearnerProfile _profile;
    private readonly string _sessionId = Guid.NewGuid().ToString("N");
    private readonly List<StepResult> _results = [];
    private readonly HashSet<string> _usedPromptIds = new(StringComparer.OrdinalIgnoreCase);
    private bool _hadAssistance;
    private GuideState _stateBeforePause = GuideState.AwaitingAction;
    private readonly GestureMatcher _matcher = new();
    private int _phaseIndex;
    private int _stepIndex;
    private int _wrongActions;
    private int _assistanceLevel;
    private bool _needsReview;
    private DateTimeOffset _stepStartedAt;
    private GuideState _state = GuideState.Idle;

    public GuideEngine(LearningScene scene, LearnerProfile profile)
    {
        ArgumentNullException.ThrowIfNull(scene);
        ArgumentNullException.ThrowIfNull(profile);
        new SceneValidator().ValidateOrThrow(scene);
        _scene = scene; _profile = profile; _stepStartedAt = DateTimeOffset.UtcNow;
    }
    public LearningScene Scene => _scene;
    public bool IsFinished => _state == GuideState.Completed;
    public LearningStep CurrentStep => _scene.Phases[_phaseIndex].Steps[_stepIndex];
    public ScreenDefinition CurrentScreen => _scene.ScreenFor(_phaseIndex);
    public GuideSnapshot Snapshot => new(_state, _phaseIndex, _stepIndex, _wrongActions, _assistanceLevel, _needsReview, _stepStartedAt);

    public GuideEventResult Start() { _state = GuideState.Greeting; _stepStartedAt = DateTimeOffset.UtcNow; return Result(CurrentStep.Say.For(_profile), false); }
    public GuideEventResult BeginAction()
    {
        if (_state is GuideState.Greeting or GuideState.Demonstrating or GuideState.Success) _state = GuideState.AwaitingAction;
        return Result(CurrentStep.Say.For(_profile), false);
    }
    public GuideEventResult ConfirmObserve()
    {
        if (_state == GuideState.Greeting) _state = GuideState.AwaitingAction;
        if (_state != GuideState.AwaitingAction || CurrentStep.Action != AtomicAction.Observe)
            return Result("先听我说完，再来试试。", false);
        return CompleteCurrent("看得很认真！", AttemptOutcome.ExposureCompleted);
    }

    public GuideEventResult ConfirmWait(TimeSpan? elapsed = null)
    {
        if (_state == GuideState.Greeting) _state = GuideState.AwaitingAction;
        if (_state != GuideState.AwaitingAction || CurrentStep.Action != AtomicAction.Wait)
            return Result("先听我说完，再来试试。", false);
        var actual = elapsed ?? (DateTimeOffset.UtcNow - _stepStartedAt);
        if (actual.TotalSeconds < CurrentStep.WaitSeconds)
            return Result($"还要等{Math.Max(1, CurrentStep.WaitSeconds - (int)actual.TotalSeconds)}秒。", false);
        return CompleteCurrent(ProfileSuccess(), AttemptOutcome.ExposureCompleted);
    }

    public GuideEventResult SubmitGesture(GestureInput input)
    {
        ArgumentNullException.ThrowIfNull(input);
        if (_state == GuideState.ApplyingPrompt) _state = GuideState.AwaitingAction;
        if (_state == GuideState.Greeting) _state = GuideState.AwaitingAction;
        if (_state != GuideState.AwaitingAction)
            return Result(_state == GuideState.NeedHumanHelp ? "请老师或家人帮忙。" : "先听我说完，再来试试。", false);
        var expected = CurrentStep;
        if (expected.Action is AtomicAction.Observe or AtomicAction.Wait)
            return Result("这一步要先看，不用点。", false);
        var matched = _matcher.Match(expected, CurrentScreen, input, _profile);
        return matched.IsMatch
            ? CompleteCurrent(ProfileSuccess(), _hadAssistance ? AttemptOutcome.PromptedSuccess : AttemptOutcome.IndependentSuccess)
            : Wrong(matched.Reason);
    }

    public GuideEventResult SubmitAction(AtomicAction action, string? targetId = null, string? value = null)
    {
        if (_state == GuideState.ApplyingPrompt) _state = GuideState.AwaitingAction;
        if (_state == GuideState.Greeting) _state = GuideState.AwaitingAction;
        if (_state != GuideState.AwaitingAction)
            return Result(_state == GuideState.NeedHumanHelp ? "请老师或家人帮忙。" : "先听我说完，再来试试。", false);
        if (action == AtomicAction.Observe) return ConfirmObserve();
        if (action == AtomicAction.Wait) return ConfirmWait();
        return SubmitGesture(new GestureInput(action, targetId, value));
    }

    public GuideEventResult Tick(TimeSpan idleFor)
    {
        // observe/wait are exposure/condition steps; they do not receive wrong-tap timeout prompts.
        if (_state != GuideState.AwaitingAction || CurrentStep.Action is AtomicAction.Observe or AtomicAction.Wait || idleFor.TotalSeconds < 10) return Result(string.Empty, false);
        _hadAssistance = true;
        _assistanceLevel = Math.Max(_assistanceLevel, 1); _state = GuideState.ApplyingPrompt;
        var timeout = CurrentStep.Prompts.FirstOrDefault(p => p.Trigger.Equals("idleSeconds", StringComparison.OrdinalIgnoreCase));
        if (timeout is not null && !string.IsNullOrWhiteSpace(timeout.Id)) _usedPromptIds.Add(timeout.Id);
        return Result(timeout?.Say.For(_profile) ?? "我们再看一次，目标会亮起来。", false);
    }
    public GuideEventResult ResumeAfterPrompt() { if (_state == GuideState.ApplyingPrompt) { _state = GuideState.AwaitingAction; _stepStartedAt = DateTimeOffset.UtcNow; } return Result(CurrentStep.Say.For(_profile), false); }
    public GuideEventResult Replay() { if (_state == GuideState.Completed) return Result("这一课已经完成了。", false, true); _state = GuideState.Demonstrating; return Result($"我来示范：{CurrentStep.Say.For(_profile)}", false); }
    public GuideEventResult Pause() { if (_state != GuideState.Completed && _state != GuideState.NeedHumanHelp) { _stateBeforePause = _state; _state = GuideState.Paused; } return Result("已暂停，准备好再继续。", false); }
    public GuideEventResult Resume() { if (_state == GuideState.Paused) { _state = _stateBeforePause is GuideState.Paused or GuideState.Idle ? GuideState.AwaitingAction : _stateBeforePause; _stepStartedAt = DateTimeOffset.UtcNow; } return Result(CurrentStep.Say.For(_profile), false); }

    public SessionResult ExportResult() => new() { Id = _sessionId, SceneId = _scene.Id, SceneTitle = _scene.Title, SceneVersion = _scene.SchemaVersion, Completed = _state == GuideState.Completed, Steps = [.. _results] };

    private GuideEventResult Wrong(string reason = "操作不正确")
    {
        _wrongActions++; _hadAssistance = true; _assistanceLevel = Math.Min(3, _wrongActions);
        var prompt = CurrentStep.Prompts.FirstOrDefault(p => p.AfterErrors == _wrongActions);
        if (prompt is not null && !string.IsNullOrWhiteSpace(prompt.Id)) _usedPromptIds.Add(prompt.Id);
        if (_wrongActions >= 3)
        {
            _needsReview = true;
            if (_scene.ExecutionMode == ExecutionMode.ScreenshotGuide)
            {
                _state = GuideState.NeedHumanHelp; _results.Add(CurrentStepResult(AttemptOutcome.Aborted));
                return Result("这个步骤需要老师或家人帮忙，我们不替您改手机。", false, false, AttemptOutcome.Aborted);
            }
            return CompleteCurrent("这次我帮你，下一次会更熟悉。", AttemptOutcome.AutoCompleted);
        }
        _state = GuideState.ApplyingPrompt;
        return Result(prompt?.Say.For(_profile) ?? reason, false);
    }

    private GuideEventResult CompleteCurrent(string message, AttemptOutcome outcome)
    {
        _results.Add(CurrentStepResult(outcome));
        var last = _phaseIndex == _scene.Phases.Count - 1 && _stepIndex == _scene.Phases[_phaseIndex].Steps.Count - 1;
        if (last) { _state = GuideState.Completed; return Result(message, outcome == AttemptOutcome.IndependentSuccess, true, outcome); }
        var phase = _scene.Phases[_phaseIndex];
        if (++_stepIndex >= phase.Steps.Count) { _phaseIndex++; _stepIndex = 0; }
        _wrongActions = 0; _assistanceLevel = 0; _hadAssistance = false; _usedPromptIds.Clear(); _stepStartedAt = DateTimeOffset.UtcNow; _state = GuideState.AwaitingAction;
        return Result(message, outcome == AttemptOutcome.IndependentSuccess, false, outcome);
    }

    private StepResult CurrentStepResult(AttemptOutcome outcome) => new()
    {
        StepRunId = Guid.NewGuid(),
        StepId = CurrentStep.Id,
        PhaseTitle = _scene.Phases[_phaseIndex].Title,
        Action = CurrentStep.Action,
        Outcome = outcome,
        Errors = _wrongActions,
        AssistanceLevel = _assistanceLevel,
        UsedPromptIds = [.. _usedPromptIds],
        FirstAttemptCorrect = _wrongActions == 0 && outcome == AttemptOutcome.IndependentSuccess,
        ActiveElapsedMs = Math.Max(0, (long)(DateTimeOffset.UtcNow - _stepStartedAt).TotalMilliseconds)
    };
    private string ProfileSuccess() => _profile.Persona == Persona.Senior ? "好了，现在可以自己操作了。" : "哇！你找到啦！太棒了！";
    private GuideEventResult Result(string message, bool correct, bool finished = false, AttemptOutcome? outcome = null) => new(Snapshot, message, correct, finished, outcome);
}
