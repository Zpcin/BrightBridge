export type Persona = 'child' | 'senior'
export type ActionType = 'tap' | 'long_press' | 'swipe'
export type Direction = 'up' | 'down' | 'left' | 'right'

/**
 * 一步练习：
 * - guide：形象化的操作说明（只描述长相和位置，不出英文词）
 * - why：给老人看的一句话原因
 * - action：要做什么动作、目标元素的 id
 * - html：这一步的完整界面（纯 HTML+CSS，在沙箱 iframe 里渲染）
 */
export interface Step {
  id: string
  guide: string
  why: string
  action: { type: ActionType; direction: Direction; targetId: string }
  html: string
}

export interface Course { title: string; steps: Step[] }

export type Gesture =
  | { type: 'tap' | 'long_press' | 'swipe'; direction: Direction }
  | 'invalid'

export function classifyGesture(dx: number, dy: number, dt: number, moved: number): Gesture {
  if (moved >= 35) {
    const direction: Direction = Math.abs(dx) >= Math.abs(dy) ? (dx > 0 ? 'right' : 'left') : (dy > 0 ? 'down' : 'up')
    return { type: 'swipe', direction }
  }
  if (dt >= 600) return { type: 'long_press', direction: 'right' }
  return { type: 'tap', direction: 'right' }
}

/** 清理危险内容：外部嵌入对象和危险链接。脚本和事件属性保留（用户要求不隔离 JS）。 */
function sanitize(root: Element) {
  root.querySelectorAll('iframe, object, embed').forEach(n => n.remove())
  const walk = (el: Element) => {
    for (const attr of Array.from(el.attributes)) {
      const name = attr.name.toLowerCase()
      const value = attr.value.trim().toLowerCase()
      // 只拦 javascript: 和 data:text/html，允许正常的 http 链接和事件属性
      const danger = (name === 'href' || name === 'src' || name === 'xlink:href')
        && (value.startsWith('javascript:') || value.startsWith('data:text/html'))
      if (danger) el.removeAttribute(attr.name)
    }
    Array.from(el.children).forEach(walk)
  }
  walk(root)
}

/**
 * 把 AI 生成的整份 HTML 课程文档解析成步骤列表。
 * 格式：每个步骤是一个 <section class="sb-step" data-guide data-why data-action data-target data-direction>。
 */
export function parseCourseHtml(raw: string): Course | { error: string } {
  let doc: Document
  try {
    doc = new DOMParser().parseFromString(raw, 'text/html')
  } catch {
    return { error: 'HTML 无法解析' }
  }
  const title = (doc.title || '').trim().slice(0, 20)
  if (!title) return { error: '缺少课程名 <title>' }
  const sections = Array.from(doc.querySelectorAll('section.sb-step'))
  if (sections.length < 2 || sections.length > 12) return { error: `步骤数量 ${sections.length} 不在 2 到 12 之间` }

  const steps: Step[] = []
  for (let i = 0; i < sections.length; i++) {
    const sec = sections[i]
    const guide = (sec.getAttribute('data-guide') || '').trim().slice(0, 80)
    const why = (sec.getAttribute('data-why') || '').trim().slice(0, 30)
    const type = (sec.getAttribute('data-action') || '') as ActionType
    const direction = (sec.getAttribute('data-direction') || 'right') as Direction
    const targetId = (sec.getAttribute('data-target') || '').trim().slice(0, 40)
    if (!guide) return { error: `第 ${i + 1} 步缺少操作说明` }
    if (!['tap', 'long_press', 'swipe'].includes(type)) return { error: `第 ${i + 1} 步动作不对` }
    if (type === 'swipe' && !['left', 'right'].includes(direction)) return { error: `第 ${i + 1} 步拖动方向不对` }
    if (!/^[a-zA-Z][\w-]*$/.test(targetId)) return { error: `第 ${i + 1} 步目标 id 不合法` }
    if (!sec.querySelector('#' + targetId)) return { error: `第 ${i + 1} 步找不到目标元素 ${targetId}` }
    if (sec.innerHTML.length > 40000) return { error: `第 ${i + 1} 步界面太大` }
    sanitize(sec)
    steps.push({ id: `s${i + 1}`, guide, why, action: { type, direction, targetId }, html: sec.innerHTML })
  }
  return { title, steps }
}

export function instruction(step: Step, persona: Persona): string {
  const why = persona === 'senior' && step.why ? `（${step.why}）` : ''
  return `${step.guide}${why}`
}

export function retry(level: number): string {
  if (level <= 1) return '没关系，慢慢来，再找一次。'
  if (level === 2) return '看黄色圈圈套住的地方。'
  return '我们一起做这一步，下一次你一定行。'
}
