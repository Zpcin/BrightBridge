using Android.Speech.Tts;
using Java.Util;
using SmartBridge.Models;

namespace SmartBridge.Android.Services;

public sealed class AndroidTtsService : Java.Lang.Object, TextToSpeech.IOnInitListener, IDisposable
{
    private TextToSpeech? _tts;
    private bool _ready;
    private double _rate = .9;

    public AndroidTtsService(global::Android.Content.Context context) { _tts = new TextToSpeech(context, this); }
    public bool IsReady => _ready;
    public void OnInit(OperationResult status)
    {
        if (status != OperationResult.Success || _tts is null) return;
        var result = _tts.SetLanguage(Locale.SimplifiedChinese);
        _ready = result is LanguageAvailableResult.Available or LanguageAvailableResult.CountryAvailable or LanguageAvailableResult.CountryVarAvailable;
        _tts.SetSpeechRate((float)_rate);
    }
    public void Speak(string text, LearnerProfile profile)
    {
        if (string.IsNullOrWhiteSpace(text)) return;
        _rate = profile.SpeakRate;
        _tts?.SetSpeechRate((float)_rate);
        if (_ready) _tts?.Speak(text, QueueMode.Flush, null, "smartbridge-guide");
    }
    public void Stop() => _tts?.Stop();
    public new void Dispose() { _tts?.Stop(); _tts?.Shutdown(); _tts?.Dispose(); _tts = null; }
}
