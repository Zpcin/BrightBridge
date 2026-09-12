using SmartBridge.Models;
using SmartBridge.Services;

static LearningStep Step(string id, AtomicAction action, string target, int errors = 1) => new()
{
    Id = id,
    Action = action,
    TargetId = target,
    Say = new SpeechText("点按钮", "请点按钮"),
    DurationMs = 800,
    Prompts = [
        new PromptLevel { Id = $"{id}-p1", AfterErrors = 1, Effect = "arrow_dim", Say = new SpeechText("看这里", "请看这里") },
        new PromptLevel { Id = $"{id}-p2", AfterErrors = 2, Effect = "hand_demo", Say = new SpeechText("我示范", "我先示范") },
        new PromptLevel { Id = $"{id}-p3", AfterErrors = 3, Effect = "auto_complete_review", Say = new SpeechText("我帮你", "我来帮您") }
    ]
};

static LearningScene Scene(bool multiScreen = false, ExecutionMode mode = ExecutionMode.Simulation)
{
    var root = new ScreenDefinition { Type = "synthetic", Style = "app_light", Elements = [
        new ScreenElement { Id = "root", Kind = "button", Text = "根按钮", X = 100, Y = 100, Width = 200, Height = 100 },
        new ScreenElement { Id = "wrong", Kind = "button", Text = "错误", X = 700, Y = 700, Width = 100, Height = 100 }
    ]};
    var next = new ScreenDefinition { Type = "synthetic", Style = "kiosk", Elements = [
        new ScreenElement { Id = "next", Kind = "button", Text = "下一屏", X = 500, Y = 400, Width = 200, Height = 100 }
    ]};
    return new LearningScene
    {
        Id = "test-scene", Title = "测试场景", Domain = "测试", Level = "L2", Sandbox = true, ExecutionMode = mode,
        Screen = root,
        Phases = [
            new LearningPhase { Id = "p1", Title = "第一屏", Steps = [
                new LearningStep { Id = "observe", Action = AtomicAction.Observe, TargetId = "root", Say = new SpeechText("看屏幕", "请看屏幕"), Prompts = ((LearningStep)Step("o", AtomicAction.Tap, "root")).Prompts },
                Step("tap", AtomicAction.Tap, "root")
            ]},
            new LearningPhase { Id = "p2", Title = "第二屏", Screen = multiScreen ? next : null, Steps = [
                Step("next", AtomicAction.Tap, multiScreen ? "next" : "root")
            ]}
        ]
    };
}

var validator = new SceneValidator();
var valid = Scene(multiScreen: true);
AssertEx.True(validator.Validate(valid).Count == 0, "valid multi-screen scene must pass");
var bad = Scene(multiScreen: true);
bad.Phases[1].Steps[0].TargetId = "root";
AssertEx.True(validator.Validate(bad).Any(x => x.Path.Contains("targetId")), "cross-screen target must fail");
bad = Scene(); bad.Screen.Elements[0].X = 950; bad.Screen.Elements[0].Width = 100;
AssertEx.True(validator.Validate(bad).Any(x => x.Message.Contains("完全位于")), "out of bounds must fail");
bad = Scene(); bad.Sandbox = false;
AssertEx.True(validator.Validate(bad).Any(x => x.Path == "sandbox"), "non-sandbox must fail");

var matcher = new GestureMatcher();
var tapStep = valid.Phases[0].Steps[1];
var rootScreen = valid.Screen;
AssertEx.True(matcher.IsMatch(tapStep, rootScreen, new GestureInput(AtomicAction.Tap, "root", X: 95, Y: 95, SurfaceWidth: 1000, SurfaceHeight: 1000), LearnerProfile.SeniorDefaults()), "senior tolerance should accept nearby tap");
AssertEx.True(!matcher.IsMatch(tapStep, rootScreen, new GestureInput(AtomicAction.Tap, "wrong", X: 750, Y: 750), LearnerProfile.ChildDefaults()), "wrong target must fail");

var engine = new GuideEngine(valid, LearnerProfile.ChildDefaults());
engine.Start(); engine.BeginAction();
var observe = engine.ConfirmObserve();
AssertEx.Equal(AttemptOutcome.ExposureCompleted, observe.Outcome, "observe outcome");
var wrong = engine.SubmitAction(AtomicAction.Tap, "wrong");
AssertEx.True(!wrong.IsCorrect && engine.Snapshot.AssistanceLevel == 1, "wrong action should prompt");
engine.ResumeAfterPrompt();
var success = engine.SubmitAction(AtomicAction.Tap, "root");
AssertEx.Equal(AttemptOutcome.PromptedSuccess, success.Outcome, "prompted success outcome");
AssertEx.Equal(2, engine.ExportResult().Steps.Count, "session should contain completed steps");

var progress = new LearningProgress();
var tracker = new ProgressTracker();
tracker.Record(progress, engine.ExportResult());
AssertEx.True(!tracker.IsMastered(progress, valid.Id), "one prompted step must not master scene");
Console.WriteLine("SmartBridge.Core.Tests: PASS");

static class AssertEx
{
    public static void True(bool value, string message)
    {
        if (!value) throw new InvalidOperationException(message);
    }
    public static void Equal<T>(T expected, T actual, string message)
    {
        if (!EqualityComparer<T>.Default.Equals(expected, actual))
            throw new InvalidOperationException($"{message}: expected {expected}, actual {actual}");
    }
}
