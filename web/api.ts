import express from 'express'
import { createHash } from 'crypto'
import { readFile, writeFile, unlink, mkdir, stat, readdir } from 'fs/promises'
import { join } from 'path'

// 模型配置全部来自 .env（vite.config.ts 里用 dotenv 加载）：改地址、模型、密钥只动 .env，代码不写死
const API_URL = process.env.LLM_API_URL || ''
const API_KEY = process.env.LLM_API_KEY || ''
const MODEL = process.env.LLM_MODEL || ''
const configured = !!(API_URL && API_KEY && MODEL)

const SYSTEM = `你是培智学校的生活技能课老师。用户说出想学的一件事，你把这件事拆成一步一步的练习，每一步的界面都用纯 HTML+CSS 画出来。
教的不只是手机和机器，日常生活里的事都可以：用微波炉热饭、洗衣机洗衣服、垃圾分类、超市自助结账、坐公交刷卡、去医院挂号、按时分药、扫地拖地、过马路看红绿灯……只要能拆成一步一步操作的事都行。
只输出一个完整的 HTML 文档。不要 markdown 代码块，不要解释，不要 JSON。

输出格式（严格遵守）：
<!doctype html>
<html>
<head><title>课程名，最多10个字</title></head>
<body>
<section class="sb-step" data-guide="这一步的操作说明" data-why="这样做的原因，最多10个字" data-action="tap" data-target="元素id" data-direction="right">
<style>
/* 这一步界面用到的 CSS */
</style>
<div class="device" style="width:100%;height:100%">
<!-- 完整的设备界面，纯 HTML -->
</div>
</section>
<!-- 更多步骤，每一步一个 section -->
</body>
</html>

硬性规则：
1. 3 到 8 步，每步一个 section，每步只做一个动作。要按很多键的（如 ATM 输密码），每按一个键算一步。
2. data-guide：说清楚目标长什么样、在什么位置、做什么动作。只描述长相和位置（颜色、形状、图案、第几行第几个），不许出现英文单词和 WiFi 这类缩写。例：找第2行，蓝色的长方形条目，里面画着扇形信号，点一下。
3. data-action 六种动作，按真实操作选最贴切的：
   - tap 点一下
   - long_press 按住不动约一秒
   - swipe 滑动翻页，data-direction 填 up/down/left/right
   - drag 拖动：data-target 是被拖的东西，再加 data-drop="放置位置的id"，放置位置画得明显些
   - slider 拖滑条：data-target 是滑条上的圆点，data-direction 填拖动方向（通常 right）
   - input 输入：data-target 必须是真正的 <input type="text"> 或 <textarea> 标签，绝对不要用 <div> 画输入框（那样点不进去、打不了字），再加 data-value="要输入的内容"。
     如果内容不固定（如姓名、手机号、金额、密码），改用 data-check 写一条 JavaScript 判断式，v 表示用户当前输入的内容，返回真就算对，例如：手机号写 data-check="/^1\\d{10}$/.test(v)"、六位数字密码写 data-check="v.length === 6"、姓名包含姓写 data-check="v.includes('王')"。data-check 和 data-value 至少写一个，两个都写时以 data-check 为准。
   tap / long_press 的 data-direction 固定填 right。
4. data-target 填目标元素的 id，这个 id 必须真实出现在这一步的 HTML 里，目标要够大好点（至少 44×44 像素）。
5. 每一步都画完整界面，后一步要比前一步更接近完成，最后一步做完事情就完成。
6. 画布是 360×620 像素：最外层容器必须 style="width:100%;height:100%"，内部用 flex 布局铺满，不出现滚动条。
7. 什么设备就画什么样子：
   - 手机：必须画完整的手机外形，不能只画屏幕内容。每一帧都要有：深色圆角手机外框、顶部状态栏（时间+信号+电池）、底部圆角条（主页指示器）。然后里面才是当前页面的内容。设置页有搜索行和列表、开关、滑条；桌面有4列应用图标。
   - ATM：金属机身、屏幕（蓝色标题条）、数字键盘（3 列 4 排）、插卡口、出钞口。
   - 还有地铁售票机、门禁机、快递柜、医院挂号机等生活场景，按用户说的事来画。
8. 界面要像真的设备：配色、布局、按钮位置都参考真实机器，字要大，对比要清楚。图标用内联 SVG 画。不要放全屏透明元素挡住可点的东西。
9. 完全自由发挥：内联 <script>、事件属性、外链图片、字体、任何 http 链接都可以用，把动画和交互做得越像真机器越好。
10. 如果消息里附了参考图片（练习者拍的真实机器照片或界面截图），必须照着图片画这一课的界面：布局、配色、按键的数量和位置、屏幕上写什么字都尽量和图片一致，让练会的东西到真机器上一样找得到。`

/** 服务端只做最低限度的格式检查（结构是否完整），不做内容限制。 */
function roughCheck(html: string): string | null {
  const trimmed = html.trim()
  if (!trimmed.startsWith('<!doctype html') && !trimmed.startsWith('<!DOCTYPE html')) return '开头不是 HTML 文档'
  const sections = trimmed.match(/<section[^>]*class="[^"]*sb-step[^"]*"/g) || []
  if (sections.length < 2 || sections.length > 12) return `步骤数量 ${sections.length} 不在 2 到 12 之间`
  if (!/data-target="/.test(trimmed)) return '缺少 data-target'
  if (!/<title>[^<]+<\/title>/.test(trimmed)) return '缺少 <title>'
  return null
}

async function callModel(task: string, persona: string, images: string[] = [], fix?: string): Promise<string> {
  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), 180000)
  try {
    const text = `练习者：${persona === 'senior' ? '老年人或数字新手' : '培智学生或儿童'}。他要学的事情：${task}`
    // 有参考图：文本 + 图片一起发（图里的真实界面要照着画）；没图就纯文本
    const content: unknown[] | string = images.length
      ? [...images.map(img => ({ type: 'image_url', image_url: { url: img } })), { type: 'text', text }]
      : text
    const messages = [
      { role: 'system', content: SYSTEM },
      { role: 'user', content },
    ]
    if (fix) messages.push({ role: 'user', content: `上一次输出的 HTML 没通过检查：${fix}。请重新输出一份完整、正确的 HTML 文档，仍然只输出 HTML。` })
    const res = await fetch(API_URL, {
      method: 'POST',
      signal: controller.signal,
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${API_KEY}` },
      body: JSON.stringify({ model: MODEL, temperature: 0.3, messages }),
    })
    if (!res.ok) throw new Error(`模型服务返回 ${res.status}`)
    const data = await res.json() as { choices?: { message?: { content?: string } }[] }
    const raw = data?.choices?.[0]?.message?.content
    if (!raw) throw new Error('模型没有返回内容')
    // 模型常在 HTML 前加说明文字，或用 markdown 代码围栏包裹；只取 HTML 文档部分
    const match = raw.match(/<!doctype html>[\s\S]*<\/html>/i)
    if (match) return match[0].trim()
    // 没找到完整文档时退而求其次：去围栏、去前后文字
    return raw.replace(/```[a-z]*\s*/gi, '').replace(/```/g, '').replace(/^[\s\S]*?(<!doctype|<html)/i, '$1').trim()
  } finally {
    clearTimeout(timer)
  }
}

/* ===================== 磁盘缓存：保留高频使用、总大小不超过 1GB ===================== */

const CACHE_DIR = join(process.cwd(), '.cache', 'courses')
const MAX_BYTES = 1024 * 1024 * 1024 // 1 GB

/** 缓存条目元数据（JSON 文件，和 html 文件同名但后缀 .meta.json） */
interface Meta { hits: number; lastUsed: number; size: number; createdAt: number }

function cacheKey(task: string, persona: string, images: string[] = []): string {
  // 参考图参与键：不同的截图生成不同的课（图大，取头尾拼个指纹）
  const fp = images.length ? images.map(i => i.length + ':' + i.slice(24, 96)).join('|') : ''
  return createHash('md5').update(`${persona}:${task}:${fp}`).digest('hex')
}

async function readMeta(fileBase: string): Promise<Meta> {
  try {
    const raw = await readFile(fileBase + '.meta.json', 'utf8')
    return JSON.parse(raw) as Meta
  } catch {
    return { hits: 0, lastUsed: 0, size: 0, createdAt: 0 }
  }
}

async function writeMeta(fileBase: string, meta: Meta) {
  await writeFile(fileBase + '.meta.json', JSON.stringify(meta), 'utf8')
}

async function cacheGet(task: string, persona: string, images: string[] = []): Promise<string | null> {
  const key = cacheKey(task, persona, images)
  const base = join(CACHE_DIR, key)
  try {
    const html = await readFile(base + '.html', 'utf8')
    // 命中：更新使用频率
    const meta = await readMeta(base)
    meta.hits++
    meta.lastUsed = Date.now()
    await writeMeta(base, meta)
    return html
  } catch {
    return null
  }
}

/** 扫描缓存目录，按使用频率从低到高淘汰，直到总大小 <= MAX_BYTES */
async function evictIfNeeded() {
  try {
    const files = await readdir(CACHE_DIR)
    const htmlFiles = files.filter(f => f.endsWith('.html'))
    if (htmlFiles.length === 0) return

    const entries: { base: string; meta: Meta }[] = []
    for (const f of htmlFiles) {
      const base = join(CACHE_DIR, f.replace(/\.html$/, ''))
      const meta = await readMeta(base)
      if (meta.size === 0) {
        try {
          const st = await stat(base + '.html')
          meta.size = st.size
        } catch { meta.size = 0 }
      }
      entries.push({ base, meta })
    }

    let total = entries.reduce((s, e) => s + e.meta.size, 0)
    if (total <= MAX_BYTES) return

    // 按使用频率升序淘汰（hits 少的先淘汰，hits 相同的按 lastUsed 升序）
    entries.sort((a, b) => a.meta.hits - b.meta.hits || a.meta.lastUsed - b.meta.lastUsed)
    for (const e of entries) {
      if (total <= MAX_BYTES) break
      try {
        await unlink(e.base + '.html')
        await unlink(e.base + '.meta.json')
      } catch { /* 文件可能已被删 */ }
      total -= e.meta.size
    }
  } catch {
    // 缓存目录不存在或读取失败，静默跳过
  }
}

async function cachePut(task: string, persona: string, images: string[], html: string) {
  const key = cacheKey(task, persona, images)
  const base = join(CACHE_DIR, key)
  try {
    await mkdir(CACHE_DIR, { recursive: true })
    await writeFile(base + '.html', html, 'utf8')
    const st = await stat(base + '.html')
    const meta: Meta = { hits: 1, lastUsed: Date.now(), size: st.size, createdAt: Date.now() }
    await writeMeta(base, meta)
    await evictIfNeeded()
  } catch {
    // 写缓存失败不影响正常流程
  }
}

// 用完整的 express 应用而不是 Router：app.handle 会把原生 req/res 换成 Express 的原型，
// 这样才能安全地挂进 Vite 的 connect 中间件。
export const apiApp = express()
// 摄像头截图（base64 jpeg）会超过 16kb，放宽到 10mb
apiApp.use(express.json({ limit: '10mb' }))

apiApp.post('/generate-course', async (req, res) => {
  const task = typeof req.body?.task === 'string' ? req.body.task.trim() : ''
  const persona = req.body?.persona
  // 参考图（界面截图/机器照片）：最多 3 张，只收 data:image/，和任务一起发给模型照着画
  const images = Array.isArray(req.body?.images)
    ? (req.body.images as unknown[])
      .filter((i): i is string => typeof i === 'string' && i.startsWith('data:image/'))
      .slice(0, 3)
    : []
  if (!task || task.length > 120) return res.status(400).json({ error: '请先用语音说出想学的事情。' })
  if (!['child', 'senior'].includes(persona)) return res.status(400).json({ error: '练习模式不正确。' })
  if (!configured) return res.status(503).json({ error: '服务端还没有配置模型密钥。', fallback: true })

  // 1. 先查缓存
  const cached = await cacheGet(task, persona, images)
  if (cached) {
    const problem = roughCheck(cached)
    if (!problem) return res.json({ html: cached, source: 'cache' })
    // 缓存内容不合法，删除后重新生成
    const key = cacheKey(task, persona, images)
    const base = join(CACHE_DIR, key)
    try { await unlink(base + '.html'); await unlink(base + '.meta.json') } catch { /* */ }
  }

  try {
    let html = await callModel(task, persona, images)
    let problem = roughCheck(html)
    if (problem) {
      html = await callModel(task, persona, images, problem)
      problem = roughCheck(html)
    }
    if (problem) return res.status(502).json({ error: `AI 画的界面没通过检查：${problem}`, fallback: true })
    // 2. 写入缓存
    await cachePut(task, persona, images, html)
    res.json({ html, source: 'ai' })
  } catch (e) {
    const timeout = e instanceof Error && e.name === 'AbortError'
    res.status(502).json({
      error: timeout ? 'AI 想得太久了，先用本地课程练习吧。' : `AI 暂时不可用：${e instanceof Error ? e.message : '未知错误'}`,
      fallback: true,
    })
  }
})

apiApp.get('/health', (_req, res) => res.json({ ok: true, model: MODEL || '(未配置)', configured }))

/* ===================== 摄像头视觉：识别设备自动开课 + 练习中实时指导 ===================== */

const VISION_FRAMES_SYSTEM = `你看练习者摄像头连拍的几帧画面（同一场景的前后几眼）。人和环境都要看，综合这几帧判断他此刻在做什么、想完成什么事。
不只看设备，日常生活都看：在厨房用微波炉热饭、往洗衣机里放衣服、拎着垃圾准备分类、在超市自助机前结账、等公交、去医院挂号、拿着药盒分药、扫地拖地、拿着手机找设置……
硬性规则：只根据画面里真实存在的人和物来判断，画面里没有的不要编。比如几帧里都没有摄像头或电脑，就不要给视频通话、开视频会议这类任务；没有洗衣机就不要洗衣任务。以此类推。
返回严格 JSON，不要其他任何文字：
{"practices": [{"task": "练习任务，最多20字"}, {"task": "另一个不同的练习任务，最多20字"}]}
给 1 到 3 个不同的任务，按可能性从高到低排。看不出他在干什么时返回 {"practices": []}。`

const VISION_CHECK_SYSTEM = `你是耐心的数字技能助教。收到练习者的摄像头画面和他正在练习的一步操作说明。
判断他现在的状态，返回严格 JSON，不要其他任何文字：
{"onTrack": true或false, "hint": "一句话中文指导，最多30字"}
- onTrack：画面显示他正在做这一步（比如手持设备对着屏幕看、站在机器前操作、手指在找东西）。
- hint：偏了就温和提醒他现在该做什么；对了就给一句简短鼓励。
看不清就 {"onTrack": false, "hint": "看不清画面，请调整一下摄像头"}。`

/** 调视觉模型：文本 + 可选的多张 base64 图（多帧一起看），返回模型原始文本 */
async function callVision(system: string, userText: string, images?: string[]): Promise<string> {
  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), 45000)
  try {
    const content: unknown[] = [{ type: 'text', text: userText }]
    if (images) for (const img of images) content.push({ type: 'image_url', image_url: { url: img } })
    const res = await fetch(API_URL, {
      method: 'POST',
      signal: controller.signal,
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${API_KEY}` },
      body: JSON.stringify({
        model: MODEL,
        temperature: 0.2,
        messages: [
          { role: 'system', content: system },
          { role: 'user', content },
        ],
      }),
    })
    if (!res.ok) throw new Error(`模型服务返回 ${res.status}`)
    const data = await res.json() as { choices?: { message?: { content?: string } }[] }
    return data?.choices?.[0]?.message?.content || ''
  } finally {
    clearTimeout(timer)
  }
}

/** 模型偶尔在 JSON 外面包文字，宽松提取第一个 {...} */
function parseJsonLoose(raw: string): Record<string, unknown> | null {
  const m = raw.match(/\{[\s\S]*\}/)
  if (!m) return null
  try { return JSON.parse(m[0]) as Record<string, unknown> } catch { return null }
}

function validImage(body: { image?: unknown }): string | null {
  return typeof body.image === 'string' && body.image.startsWith('data:image/') ? body.image : null
}

// 多帧识别：连拍的几帧一起打包给模型，直接得出多个练习任务
apiApp.post('/vision-frames', async (req, res) => {
  const body = req.body ?? {}
  const who = body.persona === 'child' ? '儿童' : '老人'
  const images = Array.isArray(body.images)
    ? (body.images as unknown[])
      .filter((i): i is string => typeof i === 'string' && i.startsWith('data:image/'))
      .slice(0, 6)
    : []
  if (images.length === 0) return res.status(400).json({ error: '没有画面' })
  if (!configured) return res.status(503).json({ error: '服务端还没有配置模型密钥' })
  try {
    const raw = await callVision(VISION_FRAMES_SYSTEM, `练习者：${who}。这是连拍的 ${images.length} 帧画面，请综合判断。`, images)
    const parsed = parseJsonLoose(raw)
    if (!parsed || !Array.isArray(parsed.practices)) return res.status(502).json({ error: 'AI 没看明白' })
    const practices = parsed.practices
      .filter((p): p is Record<string, unknown> => !!p && typeof p === 'object')
      .map(p => ({ task: typeof p.task === 'string' ? p.task.slice(0, 60) : '' }))
      .filter(p => p.task)
      .slice(0, 3)
    res.json({ practices })
  } catch (e) {
    res.status(502).json({ error: e instanceof Error ? e.message : '识别失败' })
  }
})

// 练习中指导：看画面 + 当前步骤说明，判断是否跟得上并给提示
apiApp.post('/vision-check', async (req, res) => {
  const body = req.body ?? {}
  const image = validImage(body)
  const guide = typeof body.guide === 'string' ? body.guide.slice(0, 200) : ''
  const who = body.persona === 'child' ? '儿童' : '老人'
  if (!image) return res.status(400).json({ error: '画面格式不对' })
  if (!guide) return res.status(400).json({ error: '缺少步骤说明' })
  if (!configured) return res.status(503).json({ error: '服务端还没有配置模型密钥' })
  try {
    const raw = await callVision(VISION_CHECK_SYSTEM, `练习者：${who}。当前这一步：${guide}`, [image])
    const parsed = parseJsonLoose(raw)
    if (!parsed) return res.status(502).json({ error: 'AI 没看明白' })
    res.json({
      onTrack: !!parsed.onTrack,
      hint: typeof parsed.hint === 'string' ? parsed.hint.slice(0, 60) : '',
    })
  } catch (e) {
    res.status(502).json({ error: e instanceof Error ? e.message : '识别失败' })
  }
})

apiApp.get('/cache-stats', async (_req, res) => {
  try {
    const files = await readdir(CACHE_DIR)
    const htmlFiles = files.filter(f => f.endsWith('.html'))
    let total = 0
    let totalHits = 0
    for (const f of htmlFiles) {
      const base = join(CACHE_DIR, f.replace(/\.html$/, ''))
      const meta = await readMeta(base)
      total += meta.size
      totalHits += meta.hits
    }
    res.json({ entries: htmlFiles.length, totalBytes: total, maxBytes: MAX_BYTES, totalHits })
  } catch {
    res.json({ entries: 0, totalBytes: 0, maxBytes: MAX_BYTES, totalHits: 0 })
  }
})
