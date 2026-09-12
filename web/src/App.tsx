import { useEffect, useMemo, useRef, useState } from 'react'
import './App.css'
import { Icon } from './Icons'
import { demoCourses } from './demoCourses'
import {
  type Course, type Gesture, type Persona, type Step,
  classifyGesture, instruction, parseCourseHtml, retry,
} from './course'

type Phase = 'home' | 'generating' | 'practice' | 'done'
type Mood = 'normal' | 'happy' | 'care'

/** Web Speech API 的事件类型（TS 标准 DOM 库里没有） */
interface SRAlternative { transcript: string }
interface SRResult { 0: SRAlternative; length: number; [index: number]: SRAlternative }
interface SRResultList { 0: SRResult; length: number; [index: number]: SRResult }
interface SREvent { results: SRResultList }

const cheerLines = {
  child: ['你做对啦！', '真棒真棒！', '哇，好厉害！', '给自己鼓个掌！'],
  senior: ['做对了，很好。', '没错，就是它。', '很顺利，继续。', '就是这样，你记得真牢。'],
}
const pick = (arr: string[]) => arr[Math.floor(Math.random() * arr.length)]

/** 小引导员的脸：会根据心情换表情。 */
function Face({ mood }: { mood: Mood }) {
  const mouth = mood === 'happy' ? 'M14 29q10 9 20 0'
    : mood === 'care' ? 'M16 31q8 -5 16 0'
      : 'M15 30q9 6 18 0'
  return (
    <svg viewBox="0 0 48 48" className="face" aria-hidden>
      <circle cx="24" cy="24" r="22" fill="#ffd98a" />
      <circle cx="24" cy="24" r="22" fill="none" stroke="#e8a13c" strokeWidth="2" />
      <circle cx="16.5" cy="20" r="2.7" fill="#5b3a12" />
      <circle cx="31.5" cy="20" r="2.7" fill="#5b3a12" />
      <path d={mouth} stroke="#5b3a12" strokeWidth="2.8" fill="none" strokeLinecap="round" />
      {mood === 'happy' && <>
        <circle cx="10" cy="27" r="2.4" fill="#ff9e9e" opacity=".7" />
        <circle cx="38" cy="27" r="2.4" fill="#ff9e9e" opacity=".7" />
      </>}
    </svg>
  )
}

/**
 * 仿真舞台：把 AI 画的一步界面放进无脚本沙箱 iframe 里渲染。
 * sandbox 不带 allow-scripts，AI 的 HTML 无法运行任何脚本；
 * 渲染后由父页面注入点击 / 长按 / 拖动识别。
 */
function Stage({
  step, persona, onSuccess, onWrong, onInvalid, shake, cheer,
}: {
  step: Step
  persona: Persona
  onSuccess: () => void
  onWrong: (g: Gesture) => void
  onInvalid: () => void
  shake: boolean
  cheer: boolean
}) {
  const frame = useRef<HTMLIFrameElement>(null)
  const stepRef = useRef(step)
  const cbRef = useRef({ onSuccess, onWrong, onInvalid })
  stepRef.current = step
  cbRef.current = { onSuccess, onWrong, onInvalid }

  const scale = persona === 'senior' ? 1.12 : 1
  const srcDoc = useMemo(() => `<!doctype html><html><head><meta charset="utf-8">
<style>
html,body{margin:0;padding:0;height:100%;overflow:hidden}
body{font-family:system-ui,'PingFang SC','Microsoft YaHei',sans-serif;color:#1d2b36;font-size:${16 * scale}px}
body>:not(style):not(script){width:100%;height:100%;display:block}
.sb-target{outline:4px solid #e8a13c !important;outline-offset:3px;border-radius:12px;animation:sbglow 1.2s infinite !important}
@keyframes sbglow{50%{outline-color:rgba(232,161,60,.25)}}
</style></head><body>${step.html}</body></html>`, [step, scale])

  const handleLoad = () => {
    const doc = frame.current?.contentDocument
    if (!doc) return
    // 高亮这一步的目标
    doc.getElementById(stepRef.current.action.targetId)?.classList.add('sb-target')
    // 手势识别（父页面注入到 iframe document 上）
    let down: { x: number; y: number; t: number; moved: number } | null = null
    let holdTimer: number | undefined
    let settled = false

    const onTarget = (node: EventTarget | null) => {
      // 不能用 instanceof Element：iframe 有自己的 Element 构造函数，
      // 父页面的 instanceof 对 iframe 内元素永远返回 false
      if (!node || typeof (node as { closest?: unknown }).closest !== 'function') return false
      return !!(node as Element).closest('#' + stepRef.current.action.targetId)
    }
    doc.addEventListener('pointerdown', e => {
      down = { x: e.clientX, y: e.clientY, t: Date.now(), moved: 0 }
      settled = false
      if (stepRef.current.action.type === 'long_press' && onTarget(e.target)) {
        holdTimer = window.setTimeout(() => {
          if (down && down.moved < 12 && !settled) { settled = true; cbRef.current.onSuccess() }
        }, 600)
      }
    })
    doc.addEventListener('pointermove', e => {
      if (down) down.moved = Math.max(down.moved, Math.hypot(e.clientX - down.x, e.clientY - down.y))
    })
    doc.addEventListener('pointerup', e => {
      if (holdTimer !== undefined) { clearTimeout(holdTimer); holdTimer = undefined }
      if (!down || settled) return
      const g = classifyGesture(e.clientX - down.x, e.clientY - down.y, Date.now() - down.t, down.moved)
      const hit = onTarget(e.target)
      down = null
      if (g === 'invalid') return cbRef.current.onInvalid()
      if (!hit) return cbRef.current.onWrong(g)
      const a = stepRef.current.action
      const right = g.type === a.type && (g.type !== 'swipe' || g.direction === a.direction)
      right ? cbRef.current.onSuccess() : cbRef.current.onWrong(g)
    })
  }

  return (
    <div className={`stage${shake ? ' shake' : ''}${cheer ? ' cheer' : ''}`}>
      <iframe
        ref={frame}
        title="仿真界面"
        sandbox="allow-scripts allow-same-origin"
        srcDoc={srcDoc}
        onLoad={handleLoad}
      />
    </div>
  )
}

function App() {
  const [persona, setPersona] = useState<Persona>('senior')
  const [task, setTask] = useState('')
  const [course, setCourse] = useState<Course>()
  const [step, setStep] = useState(0)
  const [phase, setPhase] = useState<Phase>('home')
  const [listening, setListening] = useState(false)
  const [banner, setBanner] = useState('')
  const [errors, setErrors] = useState(0)
  const [shake, setShake] = useState(false)
  const [cheer, setCheer] = useState(false)
  const [mood, setMood] = useState<Mood>('normal')
  const [review, setReview] = useState<number[]>([])
  const [stage, setStage] = useState(0) // 生成页进度动画

  const speak = (s: string) => {
    speechSynthesis?.cancel()
    const u = new SpeechSynthesisUtterance(s)
    u.rate = persona === 'senior' ? 0.8 : 0.85
    speechSynthesis?.speak(u)
  }
  useEffect(() => () => speechSynthesis?.cancel(), [])

  const current = course?.steps[Math.min(step, (course?.steps.length ?? 1) - 1)]

  const voice = () => {
    const w = window as unknown as Record<string, unknown>
    type Rec = new () => {
      lang: string
      start(): void
      onresult: ((e: SREvent) => void) | null
      onerror: (() => void) | null
      onend: (() => void) | null
    }
    const R = (w.SpeechRecognition ?? w.webkitSpeechRecognition) as Rec | undefined
    if (!R) return setBanner('这个浏览器不支持语音输入，请换 Chrome 或 Edge 打开。')
    const r = new R()
    r.lang = 'zh-CN'
    setListening(true)
    r.onresult = (e: SREvent) => { setTask(e.results[0][0].transcript); setListening(false) }
    r.onerror = () => { setListening(false); setBanner('没有听清，请再按一次说。') }
    r.onend = () => setListening(false)
    r.start()
  }

  const startCourse = (c: Course, note: string) => {
    setCourse(c); setStep(0); setErrors(0); setReview([]); setMood('normal'); setPhase('practice')
    setBanner(note)
    speak(instruction(c.steps[0], persona))
  }

  const generate = async (input = task) => {
    if (!input.trim()) return setBanner('请先按住语音按钮，说出想学的事情。')
    setPhase('generating'); setStage(0); setBanner('')
    const timer = setInterval(() => setStage(s => (s + 1) % 3), 1200)
    try {
      const res = await fetch('/api/generate-course', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ task: input, persona }),
      })
      const data = await res.json() as { html?: string; error?: string }
      clearInterval(timer)
      if (!res.ok || !data.html) {
        setBanner(`${data.error ?? 'AI 这次没生成好'}，已换成本地课程。`)
        startCourse(demoCourses[0], '')
        return
      }
      const parsed = parseCourseHtml(data.html)
      if ('error' in parsed) {
        setBanner(`AI 画的界面没通过检查（${parsed.error}），已换成本地课程。`)
        startCourse(demoCourses[0], '')
        return
      }
      startCourse(parsed, `AI 为你生成好了：${parsed.title}`)
    } catch {
      clearInterval(timer)
      setBanner('连不上 AI，先用本地课程练习。')
      startCourse(demoCourses[0], '')
    }
  }

  const advance = (needReview: boolean) => {
    if (!course) return
    if (needReview) setReview(r => [...r, step + 1])
    const next = step + 1
    if (next < course.steps.length) {
      setStep(next); setErrors(0)
      speak(instruction(course.steps[next], persona))
    } else {
      setStep(next); setPhase('done')
      speak(persona === 'child' ? '你做对啦，全部完成！' : '练习完成，你已经学会了')
    }
  }

  const wrongHint = (g: Gesture) => {
    if (!current || g === 'invalid') return '再试一次。'
    const a = current.action
    if (a.type === 'long_press' && g.type === 'tap') return '要按住不动，等它变颜色。'
    if (a.type === 'swipe' && g.type === 'tap') return '要按住圆点，慢慢往右边拖。'
    return retry(errors)
  }

  const onWrong = (g: Gesture) => {
    const n = errors + 1; setErrors(n)
    setShake(true); setMood('care')
    setTimeout(() => { setShake(false); setMood('normal') }, 1000)
    if (n >= 3) {
      setBanner('没关系，我拉着你一起完成这一步。')
      advance(true)
    } else {
      const msg = wrongHint(g)
      setBanner(msg); speak(msg)
    }
  }

  const personaName = persona === 'senior' ? '老人 / 数字新手' : '儿童 / 学生'

  return (
    <main className={persona}>
      <header>
        <b>智触心桥 <span>SmartBridge</span></b>
        <small>安全仿真练习 · 不会动真实设备</small>
      </header>

      {phase === 'home' && (
        <section className="page home">
          <p className="eyebrow">数字生活训练助手 · {personaName}</p>
          <h1>想说要学什么，<em>我带你一步步练</em></h1>
          <div className="modes">
            <button className={persona === 'child' ? 'on' : ''} onClick={() => setPersona('child')}>儿童 / 学生</button>
            <button className={persona === 'senior' ? 'on' : ''} onClick={() => setPersona('senior')}>老人 / 数字新手</button>
          </div>
          <div className="voicebox">
            <div className="heard">{task || '还没听到内容，按下面的按钮开始说话'}</div>
            <button className={`mic ${listening ? 'rec' : ''}`} onClick={voice}>
              {listening ? '正在聆听…松开等结果' : '按一下，说出想学的事'}
            </button>
            <button className="go" onClick={() => generate()} disabled={!task.trim()}>让 AI 生成练习</button>
          </div>
          <div className="quick">
            <span>不想等？直接开始：</span>
            {demoCourses.map(c => (
              <button key={c.title} onClick={() => startCourse(c, '本地课程，一样可以练。')}>{c.title}</button>
            ))}
          </div>
          {banner && <p className="banner">{banner}</p>}
        </section>
      )}

      {phase === 'generating' && (
        <section className="page gen">
          <Face mood="normal" />
          <h1>我正在准备…</h1>
          <ol>
            {['听懂你说的事', '拆成小步骤', '画出练习界面'].map((s, i) => (
              <li key={s} className={i <= stage ? 'on' : ''}>{s}…</li>
            ))}
          </ol>
          <p className="banner">太久的话，可以返回用本地课程先练。</p>
          <button className="ghost" onClick={() => setPhase('home')}>返回</button>
        </section>
      )}

      {phase === 'practice' && course && current && (
        <section className="page practice">
          <div className="topbar">
            <button className="ghost" onClick={() => setPhase('home')}>← 退出</button>
            <span className="steps-tag">{course.title} · 第 {step + 1} / {course.steps.length} 步</span>
            <button className="ghost" onClick={() => speak(instruction(current, persona))}>重听</button>
          </div>
          <div className="mascot">
            <Face mood={mood} />
            <div className="bubble">{instruction(current, persona)}</div>
          </div>
          <div className="dots">{course.steps.map((_, i) => <i key={i} className={i <= step ? 'on' : ''} />)}</div>
          <Stage
            step={current}
            persona={persona}
            onSuccess={() => {
              setCheer(true); setMood('happy')
              setTimeout(() => { setCheer(false); setMood('normal') }, 900)
              setBanner(pick(cheerLines[persona]))
              advance(false)
            }}
            onWrong={onWrong}
            onInvalid={() => setBanner('手别抖，重新按一次。')}
            shake={shake}
            cheer={cheer}
          />
          {banner && <p className="banner">{banner}</p>}
        </section>
      )}

      {phase === 'done' && course && (
        <section className="page done">
          <div className="confetti" aria-hidden>
            {Array.from({ length: 24 }, (_, i) => (
              <i key={i} style={{
                left: `${(i * 37) % 100}%`,
                animationDelay: `${(i % 8) * 0.18}s`,
                background: ['#f4b740', '#2faa6b', '#3d8fdd', '#e2604f', '#8a6fd6'][i % 5],
              }} />
            ))}
          </div>
          <Face mood="happy" />
          <h1>{persona === 'child' ? '你做对啦！全部完成！' : '全部完成，你已经学会了'}</h1>
          <p className="sub">刚才是安全仿真练习，真实设备一点都没被动过。</p>
          <div className="learned">
            <b>这一课：{course.title}</b>
            {course.steps.map((s, i) => (
              <div key={s.id} className={review.includes(i + 1) ? 'row review' : 'row'}>
                <Icon name="check" /><span>{instruction(s, persona)}</span>
              </div>
            ))}
          </div>
          {review.length > 0 && <p className="banner">带 ⚠ 的步骤建议再练一次。</p>}
          <div className="btns">
            <button className="go" onClick={() => startCourse(course, '再来一遍。')}>再练一次</button>
            <button className="ghost" onClick={() => { setCourse(undefined); setTask(''); setPhase('home') }}>学新的事情</button>
          </div>
        </section>
      )}
    </main>
  )
}

export default App
