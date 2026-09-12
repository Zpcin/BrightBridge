using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using SmartBridge.Models;

namespace SmartBridge.Services;

public sealed class LocalStore
{
    private readonly string _root;
    private readonly JsonSerializerOptions _options = JsonOptions.Default;

    public LocalStore(string root)
    {
        _root = root;
        Directory.CreateDirectory(_root);
        Directory.CreateDirectory(Path.Combine(_root, "generated-scenes"));
    }

    public LearnerProfile LoadProfile()
    {
        var profile = Read<LearnerProfile>("profile.json");
        return profile ?? new LearnerProfile();
    }

    public void SaveProfile(LearnerProfile profile) => Write("profile.json", profile);

    public LearningProgress LoadProgress()
    {
        var progress = Read<LearningProgress>("progress.json");
        return progress ?? new LearningProgress();
    }

    public void SaveProgress(LearningProgress progress) => Write("progress.json", progress);

    public bool SaveGeneratedSceneAfterReview(LearningScene scene, string reviewerId)
    {
        var issues = new SceneValidator().Validate(scene);
        if (issues.Count != 0 || string.IsNullOrWhiteSpace(reviewerId)) return false;
        var json = JsonSerializer.Serialize(scene, _options);
        var hash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(json)));
        var safeId = string.Concat(scene.Id.Select(c => char.IsLetterOrDigit(c) || c is '-' or '_' ? c : '_'));
        Write(Path.Combine("generated-scenes", $"{safeId}.json"), scene);
        Write(Path.Combine("generated-scenes", $"{safeId}.manifest.json"), new ScenePackageManifest
        {
            SceneId = scene.Id, ContentHash = hash, ReviewedHash = hash, ReviewStatus = "approved",
            ReviewerId = reviewerId, ReviewedAt = DateTimeOffset.UtcNow
        });
        return true;
    }

    [Obsolete("Use SaveGeneratedSceneAfterReview so generated content cannot bypass teacher review.")]
    public void SaveGeneratedScene(LearningScene scene) => throw new InvalidOperationException("生成场景必须先经过老师确认");

    public IReadOnlyList<LearningScene> LoadGeneratedScenes()
    {
        var folder = Path.Combine(_root, "generated-scenes");
        var validator = new SceneValidator();
        var scenes = new List<LearningScene>();
        foreach (var path in Directory.EnumerateFiles(folder, "*.json").Where(x => !x.EndsWith(".manifest.json", StringComparison.OrdinalIgnoreCase)))
        {
            var scene = ReadAbsolute<LearningScene>(path);
            var manifest = ReadAbsolute<ScenePackageManifest>(Path.ChangeExtension(path, ".manifest.json"));
            if (scene is null || manifest is null || !string.Equals(manifest.ReviewStatus, "approved", StringComparison.OrdinalIgnoreCase)) continue;
            var json = JsonSerializer.Serialize(scene, _options);
            var hash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(json)));
            if (!string.Equals(hash, manifest.ContentHash, StringComparison.OrdinalIgnoreCase) || !string.Equals(hash, manifest.ReviewedHash, StringComparison.OrdinalIgnoreCase)) continue;
            if (validator.Validate(scene).Count == 0) scenes.Add(scene);
        }
        return scenes;
    }

    private T? Read<T>(string relativePath)
    {
        try
        {
            var path = Path.Combine(_root, relativePath);
            return File.Exists(path) ? JsonSerializer.Deserialize<T>(File.ReadAllText(path), _options) : default;
        }
        catch (JsonException) { return default; }
        catch (IOException) { return default; }
    }

    private T? ReadAbsolute<T>(string path)
    {
        try { return JsonSerializer.Deserialize<T>(File.ReadAllText(path), _options); }
        catch { return default; }
    }

    private void Write<T>(string relativePath, T value)
    {
        var path = Path.Combine(_root, relativePath);
        var directory = Path.GetDirectoryName(path);
        if (directory is not null) Directory.CreateDirectory(directory);
        var temp = path + ".tmp";
        File.WriteAllText(temp, JsonSerializer.Serialize(value, _options));
        File.Move(temp, path, true);
    }
}
