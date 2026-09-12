import express from 'express'

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
3. data-action 只能是 tap（点一下）、long_press（按住不动）、swipe（拖动）。tap 和 long_press 的 data-direction 写 right；swipe 只能写 left 或 right。
4. data-target 填目标元素的 id，这个 id 必须真实出现在这一步的 HTML 里，目标要够大好点（至少 44×44 像素）。
5. 每一步都画完整界面，后一步要比前一步更接近完成，最后一步做完事情就完成。
6. 画布是 360×620 像素：最外层容器必须 style="width:100%;height:100%"，内部用 flex 布局铺满，不出现滚动条。
7. 什么设备就画什么样子：
   - 手机：深色圆角边框、顶部状态栏（时间+信号+电池）、4 列应用图标、设置页有搜索行和列表、开关、滑条。
   - ATM：金属机身、屏幕（蓝色标题条）、数字键盘（3 列 4 排）、插卡口、出钞口。
   - 还有地铁售票机、门禁机、快递柜、医院挂号机等生活场景，按用户说的事来画。
8. 界面要像真的设备：配色、布局、按钮位置都参考真实机器，字要大，对比要清楚。图标用内联 SVG 画。
9. 可以用内联 <script> 和事件属性来实现动画和交互效果；禁止外链图片、字体、任何 http 链接。
10. 只做安全仿真：绝对不能教真的转账、付款、拨号；ATM 只到钱出来为止。`

/** 服务端先做一遍粗检查，浏览器端还会做完整解析和安全清理。 */
function roughCheck(html: string): string | null {
  const trimmed = html.trim()
  if (!trimmed.startsWith('<!doctype html') && !trimmed.startsWith('<!DOCTYPE html')) return '开头不是 HTML 文档'
  const sections = trimmed.match(/<section[^>]*class="[^"]*sb-step[^"]*"/g) || []
  if (sections.length < 2 || sections.length > 12) return `步骤数量 ${sections.length} 不在 2 到 12 之间`
  if (!/data-target="/.test(trimmed)) return '缺少 data-target'
  if (!/<title>[^<]+<\/title>/.test(trimmed)) return '缺少 <title>'
  if (/<\s*(iframe|object|embed)\b/i.test(trimmed)) return '不允许嵌入外部对象'
  // SVG 的 xmlns 是官方命名空间，不算外链；其余 http 链接一律拒绝
  const noSvgNs = trimmed.replace(/https?:\/\/www\.w3\.org\/2000\/svg/gi, '')
  if (/https?:\/\//i.test(noSvgNs)) return '不允许出现外链'
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

// 用完整的 express 应用而不是 Router：app.handle 会把原生 req/res 换成 Express 的原型，
// 这样才能安全地挂进 Vite 的 connect 中间件。
export const apiApp = express()
apiApp.use(express.json({ limit: '16kb' }))

apiApp.post('/generate-course', async (req, res) => {
  const task = typeof req.body?.task === 'string' ? req.body.task.trim() : ''
  const persona = req.body?.persona
  if (!task || task.length > 120) return res.status(400).json({ error: '请先用语音说出想学的事情。' })
  if (!['child', 'senior'].includes(persona)) return res.status(400).json({ error: '练习模式不正确。' })
  if (!API_KEY) return res.status(503).json({ error: '服务端还没有配置模型密钥。', fallback: true })

  try {
    let html = await callModel(task, persona)
    let problem = roughCheck(html)
    if (problem) {
      html = await callModel(task, persona, problem)
      problem = roughCheck(html)
    }
    if (problem) return res.status(502).json({ error: `AI 画的界面没通过检查：${problem}`, fallback: true })
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
