using Android.App;
using Android.Content;
using Android.Graphics;
using Android.OS;
using Android.Views;
using Android.Widget;
using SmartBridge.Models;
using SmartBridge.Services;
using SmartBridge.Android.Services;

namespace SmartBridge.Android;

[Activity(Label = "智触心桥 SmartBridge", MainLauncher = true, Exported = true, Theme = "@style/AppTheme", ScreenOrientation = global::Android.Content.PM.ScreenOrientation.Portrait)]
public sealed class MainActivity : Activity
{
    LinearLayout _root = null!;
    LearnerProfile _profile = null!;
    LocalStore _store = null!;
    TextView _message = null!;
    TextView _profileLabel = null!;
    GuideCanvas _canvas = null!;
    AndroidTtsService? _tts;
    GuideEngine? _engine;
    System.Threading.Timer? _idleTimer;
    LearningScene? _scene;
    global::Android.Net.Uri? _pendingScreenshot;
    const int ScreenshotRequestCode = 401;

    protected override void OnDestroy()
    {
        _idleTimer?.Dispose();
        _tts?.Dispose();
        base.OnDestroy();
    }

    protected override void OnCreate(Bundle? savedInstanceState)
    {
        base.OnCreate(savedInstanceState);
        _store = new LocalStore(FilesDir?.AbsolutePath ?? CacheDir!.AbsolutePath);
        _profile = _store.LoadProfile();
        _tts = new AndroidTtsService(this);
        ShowHome();
    }

    void ShowHome()
    {
        var scroll = new ScrollView(this);
        _root = new LinearLayout(this) { Orientation = Orientation.Vertical };
        _root.SetPadding(28, 32, 28, 28);
        _root.SetBackgroundColor(Color.Rgb(247, 250, 255));
        scroll.AddView(_root);
        var title = Text("智触心桥 SmartBridge", 32, Color.Rgb(30, 55, 90));
        _root.AddView(title);
        _root.AddView(Text("一步一步练习，点错也没关系。", 18, Color.DarkGray));
        _profileLabel = Text(ProfileText(), 18, Color.Rgb(40, 100, 90));
        _root.AddView(_profileLabel);
        AddButton("选择儿童模式", () => ChooseProfile(Persona.Child));
        AddButton("选择老人模式", () => ChooseProfile(Persona.Senior));
        AddButton("开始练习", ShowCourses);
        AddButton("场景生成（截图预览）", ShowGeneratorInfo);
        _message = Text("全部课程都是仿真练习，不会真实拨号、付款或修改手机设置。", 16, Color.DarkGray);
        _root.AddView(_message);
        SetContentView(scroll);
    }

    string ProfileText() => _profile.Persona == Persona.Senior ? "当前：老人模式 · 字号放大 · 解释原因" : "当前：儿童模式 · 短句 · 温柔鼓励";

    void ChooseProfile(Persona persona)
    {
        _profile = persona == Persona.Senior ? LearnerProfile.SeniorDefaults() : LearnerProfile.ChildDefaults();
        _store.SaveProfile(_profile);
        _profileLabel.Text = ProfileText();
        _message.Text = persona == Persona.Senior ? "已切换老人模式：我们用平等、实用的话术。" : "已切换儿童模式：我们用短句，一步一步来。";
    }

    void ShowCourses()
    {
        _root.RemoveAllViews();
        _root.AddView(Text("选择练习", 28, Color.Rgb(30, 55, 90)));
        foreach (var scene in BuiltinScenes.All.Where(s => !s.SeniorOnly || _profile.Persona == Persona.Senior))
        {
            var button = new Button(this) { Text = $"{scene.Level}  ·  {scene.Title}" };
            button.SetTextSize(global::Android.Util.ComplexUnitType.Sp, (float)(17 * _profile.FontScale));
            button.Click += (_, _) => StartScene(scene);
            _root.AddView(button);
        }
        AddButton("返回首页", ShowHome);
    }

    void StartScene(LearningScene scene)
    {
        _scene = scene;
        _engine = new GuideEngine(scene, _profile);
        _root.RemoveAllViews();
        _root.AddView(Text(scene.Title, 25, Color.Rgb(30, 55, 90)));
        _root.AddView(Text(scene.Summary, 15, Color.DarkGray));
        _canvas = new GuideCanvas(this, scene.Screen, _profile.FontScale);
        _canvas.Tapped += (_, id) => Submit(id);
        _idleTimer?.Dispose();
        _idleTimer = new System.Threading.Timer(_ => RunOnUiThread(() =>
        {
            if (_engine is null) return;
            var r = _engine.Tick(TimeSpan.FromSeconds(10));
            if (!string.IsNullOrWhiteSpace(r.Message)) ShowResult(r);
        }), null, TimeSpan.FromSeconds(10), Timeout.InfiniteTimeSpan);
        var canvasParams = new LinearLayout.LayoutParams(-1, 0, 1) { TopMargin = 16, BottomMargin = 12 };
        _root.AddView(_canvas, canvasParams);
        _message = Text("正在准备练习…", (float)(20 * _profile.FontScale), Color.Rgb(30, 80, 120));
        _root.AddView(_message);
        AddButton("我准备好了 / 重播", () => { var r = _engine.Replay(); ShowResult(r); });
        AddButton("返回课程", ShowCourses);
        ShowResult(_engine.Start());
    }

    void Submit(string targetId)
    {
        if (_engine is null) return;
        var r = _engine.Snapshot.State == GuideState.Greeting ? _engine.BeginAction() : _engine.SubmitAction(_engine.CurrentStep.Action, targetId);
        ShowResult(r);
        if (r.IsFinished)
        {
            var progress = _store.LoadProgress();
            new ProgressTracker().Record(progress, _engine.ExportResult());
            _store.SaveProgress(progress);
            AddButton("再练一次", () => StartScene(_scene!));
        }
    }

    void ShowResult(GuideEventResult result)
    {
        if (_message is null) return;
        _message.Text = result.Message;
        if (!string.IsNullOrWhiteSpace(result.Message)) _tts?.Speak(result.Message, _profile);
        _canvas?.SetTarget(_engine?.CurrentStep.TargetId);
        _idleTimer?.Dispose();
        if (!result.IsFinished && _engine?.Snapshot.State is GuideState.AwaitingAction or GuideState.ApplyingPrompt)
            _idleTimer = new System.Threading.Timer(_ => RunOnUiThread(() =>
            {
                if (_engine is null) return;
                var timeout = _engine.Tick(TimeSpan.FromSeconds(10));
                if (!string.IsNullOrWhiteSpace(timeout.Message)) ShowResult(timeout);
            }), null, TimeSpan.FromSeconds(10), Timeout.InfiniteTimeSpan);
        if (result.IsFinished) _message.Text = $"完成啦！{result.Message}\n{(_engine?.Snapshot.NeedsReview == true ? "这一步下次再复习。" : "这次没有需要复习的步骤。")}";
    }

    void ShowGeneratorInfo()
    {
        _root.RemoveAllViews();
        _root.AddView(Text("截图生成器 · 老师审核", 26, Color.Rgb(30, 55, 90)));
        _root.AddView(Text("选择一张当前界面截图。这里只做本地预览；未确认前不会进入课程。", 17, Color.DarkGray));
        AddButton("选择截图", PickScreenshot);
        AddButton("使用离线示例预览", () => ShowDraftPreview("离线示例：设置页面"));
        AddButton("返回首页", ShowHome);
    }

    void PickScreenshot()
    {
        var intent = new Intent(Intent.ActionOpenDocument);
        intent.AddCategory(Intent.CategoryOpenable);
        intent.SetType("image/*");
        StartActivityForResult(intent, ScreenshotRequestCode);
    }

    protected override void OnActivityResult(int requestCode, global::Android.App.Result resultCode, Intent? data)
    {
        base.OnActivityResult(requestCode, resultCode, data);
        if (requestCode == ScreenshotRequestCode && resultCode == global::Android.App.Result.Ok && data?.Data is not null)
        {
            _pendingScreenshot = data.Data;
            ShowDraftPreview("已选择截图 · 等待老师确认");
        }
    }

    void ShowDraftPreview(string title)
    {
        _root.RemoveAllViews();
        _root.AddView(Text("老师预览", 28, Color.Rgb(30, 55, 90)));
        _root.AddView(Text(title, 18, Color.Rgb(40, 100, 90)));
        _root.AddView(Text("这是草稿。确认后才可以保存；当前版本不会把草稿直接提供给学员。", 16, Color.DarkGray));
        AddButton("确认并保存（需要审核人）", () =>
        {
            _message = Text("当前界面识别结果需要老师逐步编辑后再保存。已保留审核边界，内置课仍可离线练习。", 16, Color.DarkGray);
            _root.AddView(_message);
        });
        AddButton("取消，不保存", ShowHome);
    }

    TextView Text(string text, float size, Color color) { var view = new TextView(this) { Text = text, TextSize = size, Gravity = GravityFlags.CenterVertical }; view.SetTextColor(color); return view; }
    void AddButton(string label, Action action) { var b = new Button(this) { Text = label }; b.Click += (_, _) => action(); _root.AddView(b); }

    sealed class GuideCanvas : View
    {
        readonly ScreenDefinition _screen; readonly float _scale; string? _target;
        float _downX, _downY; long _downAt;
        public event EventHandler<string>? Tapped;
        public GuideCanvas(global::Android.Content.Context context, ScreenDefinition screen, double scale) : base(context) { _screen = screen; _scale = (float)scale; SetBackgroundColor(Color.White); }
        public void SetTarget(string? target) { _target = target; Invalidate(); }
        protected override void OnDraw(Canvas canvas)
        {
            base.OnDraw(canvas); var w = Width; var h = Height; var sx = w / 1000f; var sy = h / 1000f;
            using var paint = new Paint { AntiAlias = true }; paint.Color = Color.Rgb(35, 60, 90); paint.TextSize = 34 * _scale; canvas.DrawText("练习模式", 30, 55, paint);
            foreach (var e in _screen.Elements)
            {
                var rect = new RectF(e.X * sx, e.Y * sy, (e.X + e.Width) * sx, (e.Y + e.Height) * sy);
                paint.Color = Parse(e.Color); canvas.DrawRoundRect(rect, 18, 18, paint);
                paint.Color = Color.DarkGray; paint.TextSize = 26 * _scale; canvas.DrawText(e.Text, rect.Left + 14, rect.CenterY(), paint);
                if (e.Id == _target) { paint.SetStyle(Paint.Style.Stroke); paint.StrokeWidth = 7; paint.Color = Color.Rgb(35, 150, 95); canvas.DrawRoundRect(rect, 18, 18, paint); paint.SetStyle(Paint.Style.Fill); }
            }
        }
        public override bool OnTouchEvent(global::Android.Views.MotionEvent? e)
        {
            if (e is null) return true;
            if (e.Action == MotionEventActions.Down)
            {
                _downX = e.GetX(); _downY = e.GetY(); _downAt = SystemClock.ElapsedRealtime();
                return true;
            }
            if (e.Action != MotionEventActions.Up) return true;
            var x = e.GetX() / Math.Max(1, Width) * 1000f; var y = e.GetY() / Math.Max(1, Height) * 1000f;
            var downX = _downX / Math.Max(1, Width) * 1000f; var downY = _downY / Math.Max(1, Height) * 1000f;
            var elapsed = SystemClock.ElapsedRealtime() - _downAt;
            var distance = MathF.Abs(x - downX) + MathF.Abs(y - downY);
            var hit = _screen.Elements.LastOrDefault(a => a.Interactive && x >= a.X && x <= a.X + a.Width && y >= a.Y && y <= a.Y + a.Height);
            if (hit is null) return true;
            // The Canvas reports the atomic gesture to the host; duration and swipe are preserved
            // for future GestureInput-based screens. Current built-in lessons remain safe taps.
            Tapped?.Invoke(this, hit.Id);
            return true;
        }
        static Color Parse(string value) { try { return Color.ParseColor(value); } catch { return Color.Rgb(230, 240, 250); } }
    }
}
