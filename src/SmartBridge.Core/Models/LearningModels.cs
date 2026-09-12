using System.Text.Json.Serialization;

namespace SmartBridge.Models;

public enum Persona { Child, Senior }
public enum AtomicAction { Observe, Tap, LongPress, Swipe, TypeChar, Wait }
public enum ExecutionMode { Simulation, ScreenshotGuide, LiveSettingsGuide }
public enum AttemptOutcome { IndependentSuccess, PromptedSuccess, AutoCompleted, ExposureCompleted, Aborted }

public sealed class LearnerProfile
{
    public Persona Persona { get; set; } = Persona.Child;
    public double FontScale { get; set; } = 1.0;
    public double SpeakRate { get; set; } = 0.9;
    // dp, used only by logical hit testing. The visual simulation keeps its original size.
    public int TapTolerance { get; set; } = 24;
    public bool AutoReplay { get; set; } = true;
    public bool ExplainWhy { get; set; }
    public static LearnerProfile ChildDefaults() => new();
    public static LearnerProfile SeniorDefaults() => new() { Persona = Persona.Senior, FontScale = 1.4, TapTolerance = 36, ExplainWhy = true };
}

public sealed class SpeechText
{
    public SpeechText() { }
    public SpeechText(string child, string senior, string? why = null) { Child = child; Senior = senior; SeniorWhy = why; }
    public string Child { get; set; } = string.Empty;
    public string Senior { get; set; } = string.Empty;
    public string? SeniorWhy { get; set; }
    public string For(Persona persona) => persona == Persona.Senior ? Senior : Child;
    public string For(LearnerProfile profile) => profile.Persona == Persona.Senior && profile.ExplainWhy && !string.IsNullOrWhiteSpace(SeniorWhy) ? $"{Senior}。{SeniorWhy}" : For(profile.Persona);
}

// All coordinates use a 1000 x 1000 normalized surface. Android maps them to the content rectangle.
public sealed class ScreenElement
{
    public string Id { get; set; } = string.Empty;
    public string Kind { get; set; } = "button";
    public string Text { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Color { get; set; } = "#EAF3FF";
    public float X { get; set; }
    public float Y { get; set; }
    public float Width { get; set; } = 100;
    public float Height { get; set; } = 64;
    public bool Interactive { get; set; } = true;
}

public sealed class ScreenDefinition
{
    public string Type { get; set; } = "synthetic";
    public string Style { get; set; } = "app_light";
    public string? Source { get; set; }
    public List<ScreenElement> Elements { get; set; } = [];
}

public sealed class LearningStep
{
    public string Id { get; set; } = string.Empty;
    public AtomicAction Action { get; set; }
    public string TargetId { get; set; } = string.Empty;
    // type_char is a single virtual key selection, not arbitrary keyboard input.
    public string Character { get; set; } = string.Empty;
    public string InputId { get; set; } = string.Empty;
    public int DurationMs { get; set; } = 800;
    public float FromX { get; set; }
    public float FromY { get; set; }
    public float ToX { get; set; }
    public float ToY { get; set; }
    public SpeechText Say { get; set; } = new();
    public List<PromptLevel> Prompts { get; set; } = [];
    public int WaitSeconds { get; set; } = 10;
}

public sealed class PromptLevel
{
    public string Id { get; set; } = string.Empty;
    public string Trigger { get; set; } = "wrongActionCount";
    public int AfterErrors { get; set; }
    public string Effect { get; set; } = "arrow_dim";
    public List<string> Actions { get; set; } = [];
    public SpeechText Say { get; set; } = new();
}

public sealed class LearningPhase
{
    public string Id { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    // A phase can switch the simulated screen for a multi-screen flow.
    public ScreenDefinition? Screen { get; set; }
    public List<LearningStep> Steps { get; set; } = [];
}

public sealed class LearningScene
{
    public string Id { get; set; } = string.Empty;
    public int SchemaVersion { get; set; } = 1;
    public string Title { get; set; } = string.Empty;
    public string Domain { get; set; } = string.Empty;
    public string Level { get; set; } = "L2";
    public string Summary { get; set; } = string.Empty;
    public string Icon { get; set; } = "spark";
    public bool SeniorOnly { get; set; }
    public bool Sandbox { get; set; } = true;
    public ExecutionMode ExecutionMode { get; set; } = ExecutionMode.Simulation;
    public ScreenDefinition Screen { get; set; } = new();
    public List<LearningPhase> Phases { get; set; } = [];
    public ScreenDefinition ScreenFor(int phaseIndex) => Phases[phaseIndex].Screen ?? Screen;
    public int StepCount => Phases.Sum(p => p.Steps.Count);
}

public sealed class StepResult
{
    public Guid StepRunId { get; set; } = Guid.NewGuid();
    public string StepId { get; set; } = string.Empty;
    public string PhaseTitle { get; set; } = string.Empty;
    public AtomicAction Action { get; set; }
    public AttemptOutcome Outcome { get; set; }
    public int Errors { get; set; }
    public int AssistanceLevel { get; set; }
    public List<string> UsedPromptIds { get; set; } = [];
    public long ActiveElapsedMs { get; set; }
    public bool FirstAttemptCorrect { get; set; }
}

public sealed class SessionResult
{
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string SceneId { get; set; } = string.Empty;
    public string SceneTitle { get; set; } = string.Empty;
    public int SceneVersion { get; set; } = 1;
    public DateTimeOffset CompletedAt { get; set; } = DateTimeOffset.Now;
    public bool Completed { get; set; }
    public List<StepResult> Steps { get; set; } = [];
}

public sealed class LearningProgress
{
    public int Version { get; set; } = 1;
    public List<SessionResult> Sessions { get; set; } = [];
    public bool IsMastered(string sceneId)
    {
        var independentByStep = Sessions.Where(x => x.SceneId == sceneId && x.Completed)
            .SelectMany(x => x.Steps).Where(x => x.Outcome == AttemptOutcome.IndependentSuccess)
            .GroupBy(x => x.StepId);
        return independentByStep.Any() && independentByStep.All(x => x.Select(y => y.StepRunId).Distinct().Count() >= 3);
    }
}

// Content and approval are deliberately separate. A draft cannot be offered to learners.
public sealed class ScenePackageManifest
{
    public string SceneId { get; set; } = string.Empty;
    public string ContentHash { get; set; } = string.Empty;
    public string ReviewStatus { get; set; } = "draft";
    public string ReviewerId { get; set; } = string.Empty;
    public DateTimeOffset? ReviewedAt { get; set; }
    public string ReviewedHash { get; set; } = string.Empty;
}
