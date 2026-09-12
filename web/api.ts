import express from 'express'
import { createHash } from 'crypto'
import { readFile, writeFile, unlink, mkdir, stat, readdir } from 'fs/promises'
import { join } from 'path'

const API_URL = process.env.LLM_API_URL || 'https://aiping.cn/api/v1/chat/completions'
const API_KEY = process.env.LLM_API_KEY || process.env.AIPING_API_KEY || ''
const MODEL = process.env.LLM_MODEL || 'DeepSeek-V4.1-Flash'

const SYSTEM = `你是培智学校的生活技能课老师。用户说出想学的一件事，你把这件事拆成一步一步的练习，每一步的界面都用纯 HTML+CSS 画出来。
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
   - input 输入：data-target 是输入框，再加 data-value="要输入的内容"
   tap / long_press 的 data-direction 固定填 right。
4. data-target 填目标元素的 id，这个 id 必须真实出现在这一步的 HTML 里，目标要够大好点（至少 44×44 像素）。
5. 每一步都画完整界面，后一步要比前一步更接近完成，最后一步做完事情就完成。
6. 画布是 360×620 像素：最外层容器必须 style="width:100%;height:100%"，内部用 flex 布局铺满，不出现滚动条。
7. 什么设备就画什么样子：
   - 手机：深色圆角边框、顶部状态栏（时间+信号+电池）、4 列应用图标、设置页有搜索行和列表、开关、滑条。
   - ATM：金属机身、屏幕（蓝色标题条）、数字键盘（3 列 4 排）、插卡口、出钞口。
   - 还有地铁售票机、门禁机、快递柜、医院挂号机等生活场景，按用户说的事来画。
8. 界面要像真的设备：配色、布局、按钮位置都参考真实机器，字要大，对比要清楚。图标用内联 SVG 画。
9. 完全自由发挥：内联 <script>、事件属性、外链图片、字体、任何 http 链接都可以用，把动画和交互做得越像真机器越好。`

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

async function callModel(task: string, persona: string, fix?: string): Promise<string> {
  const controller = new AbortController()
  const timer = setTimeout(() => controller.abort(), 180000)
  try {
    const messages = [
      { role: 'system', content: SYSTEM },
      { role: 'user', content: `练习者：${persona === 'senior' ? '老年人或数字新手' : '培智学生或儿童'}。他要学的事情：${task}` },
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

function cacheKey(task: string, persona: string): string {
  return createHash('md5').update(`${persona}:${task}`).digest('hex')
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

async function cacheGet(task: string, persona: string): Promise<string | null> {
  const key = cacheKey(task, persona)
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

async function cachePut(task: string, persona: string, html: string) {
  const key = cacheKey(task, persona)
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
  if (!task || task.length > 120) return res.status(400).json({ error: '请先用语音说出想学的事情。' })
  if (!['child', 'senior'].includes(persona)) return res.status(400).json({ error: '练习模式不正确。' })
  if (!API_KEY) return res.status(503).json({ error: '服务端还没有配置模型密钥。', fallback: true })

  // 1. 先查缓存
  const cached = await cacheGet(task, persona)
  if (cached) {
    const problem = roughCheck(cached)
    if (!problem) return res.json({ html: cached, source: 'cache' })
    // 缓存内容不合法，删除后重新生成
    const key = cacheKey(task, persona)
    const base = join(CACHE_DIR, key)
    try { await unlink(base + '.html'); await unlink(base + '.meta.json') } catch { /* */ }
  }

  try {
    let html = await callModel(task, persona)
    let problem = roughCheck(html)
    if (problem) {
      html = await callModel(task, persona, problem)
      problem = roughCheck(html)
    }
    if (problem) return res.status(502).json({ error: `AI 画的界面没通过检查：${problem}`, fallback: true })
    // 2. 写入缓存
    await cachePut(task, persona, html)
    res.json({ html, source: 'ai' })
  } catch (e) {
    const timeout = e instanceof Error && e.name === 'AbortError'
    res.status(502).json({
      error: timeout ? 'AI 想得太久了，先用本地课程练习吧。' : `AI 暂时不可用：${e instanceof Error ? e.message : '未知错误'}`,
      fallback: true,
    })
  }
})

apiApp.get('/health', (_req, res) => res.json({ ok: true, model: MODEL, configured: !!API_KEY }))

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
