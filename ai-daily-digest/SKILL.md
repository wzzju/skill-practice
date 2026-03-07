---
name: ai-daily-digest
description: "Fetches RSS feeds from 90 top Hacker News blogs (curated by Karpathy), uses AI to score and filter articles, and generates a daily digest in Markdown with Chinese-translated titles, category grouping, trend highlights, and visual statistics (Mermaid charts + tag cloud). Use when user mentions 'daily digest', 'RSS digest', 'blog digest', 'AI blogs', 'tech news summary', or asks to run /digest command. Trigger command: /digest."
---

# AI Daily Digest

从 Karpathy 推荐的 90 个热门技术博客中抓取最新文章，通过 AI 评分筛选，生成每日精选摘要。

## 命令

### `/digest`

运行每日摘要生成器。

**使用方式**: 输入 `/digest`，Agent 通过交互式引导收集参数后执行。

---

## 脚本目录

**重要**: 所有脚本位于此 skill 的 `scripts/` 子目录。

**Agent 执行说明**:
1. 确定此 SKILL.md 文件的目录路径为 `SKILL_DIR`
2. 脚本路径 = `${SKILL_DIR}/scripts/<script-name>.ts`

| 脚本 | 用途 |
|------|------|
| `scripts/digest.ts` | 主脚本 - 支持三种模式: fetch（抓取）、report（报告）、full（一体化） |

---

## 配置持久化

配置文件路径: `~/.hn-daily-digest/config.json`

Agent 在执行前**必须检查**此文件是否存在：
1. 如果存在，读取并解析 JSON
2. 询问用户是否使用已保存配置
3. 执行完成后保存当前配置到此文件

**配置文件结构**:
```json
{
  "timeRange": 48,
  "topN": 15,
  "language": "zh",
  "lastUsed": "2026-02-14T12:00:00Z"
}
```

---

## 交互流程

### Step 0: 检查已保存配置

```bash
cat ~/.hn-daily-digest/config.json 2>/dev/null || echo "NO_CONFIG"
```

如果配置存在，询问是否复用：

```
question({
  questions: [{
    header: "使用已保存配置",
    question: "检测到上次使用的配置：\n\n• 时间范围: ${config.timeRange}小时\n• 精选数量: ${config.topN} 篇\n• 输出语言: ${config.language === 'zh' ? '中文' : 'English'}\n\n请选择操作：",
    options: [
      { label: "使用上次配置直接运行 (Recommended)", description: "使用所有已保存的参数立即开始" },
      { label: "重新配置", description: "从头开始配置所有参数" }
    ]
  }]
})
```

### Step 1: 收集参数

使用 `question()` 一次性收集：

```
question({
  questions: [
    {
      header: "时间范围",
      question: "抓取多长时间内的文章？",
      options: [
        { label: "24 小时", description: "仅最近一天" },
        { label: "48 小时 (Recommended)", description: "最近两天，覆盖更全" },
        { label: "72 小时", description: "最近三天" },
        { label: "7 天", description: "一周内的文章" }
      ]
    },
    {
      header: "精选数量",
      question: "AI 筛选后保留多少篇？",
      options: [
        { label: "10 篇", description: "精简版" },
        { label: "15 篇 (Recommended)", description: "标准推荐" },
        { label: "20 篇", description: "扩展版" }
      ]
    },
    {
      header: "输出语言",
      question: "摘要使用什么语言？",
      options: [
        { label: "中文 (Recommended)", description: "摘要翻译为中文" },
        { label: "English", description: "保持英文原文" }
      ]
    }
  ]
})
```

### Step 2a: 抓取 RSS 文章

使用 fetch 模式抓取 RSS 并按时间过滤，**不需要 AI 调用**：

```bash
mkdir -p ./output

mkdir -p .tmp && npx -y bun ${SKILL_DIR}/scripts/digest.ts \
  --mode fetch \
  --hours <timeRange> \
  --output .tmp/digest-articles.json
```

> **代理说明**: 脚本默认使用 `http://172.19.53.7:8128` 作为 RSS 抓取的回退代理（直连失败时才走代理）。可通过 `--proxy <url>` 自定义代理地址，或 `--no-proxy` 完全禁用代理。

### Step 2b: Agent 执行 AI 评分与摘要

**重要**: 此步骤由 Agent 直接完成（不调用 ducc/claude CLI），避免嵌套执行问题。

1. 使用 Read 工具读取 `.tmp/digest-articles.json`
2. 按照下方**评分标准**对所有文章进行评分
3. 按总分降序排序，取 Top N 篇
4. 对 Top N 篇文章生成**摘要、中文标题、推荐理由**
5. 生成 3-5 句话的**今日看点**趋势总结
6. 将结果写入 `.tmp/digest-scored.json`

#### 评分标准（三个维度，每项 1-10 分）

**相关性 (relevance)** — 对技术/编程/AI/互联网从业者的价值：
- 10: 所有技术人都应该知道的重大事件/突破
- 7-9: 对大部分技术从业者有价值
- 4-6: 对特定技术领域有价值
- 1-3: 与技术行业关联不大

**质量 (quality)** — 文章本身的深度和写作质量：
- 10: 深度分析，原创洞见，引用丰富
- 7-9: 有深度，观点独到
- 4-6: 信息准确，表达清晰
- 1-3: 浅尝辄止或纯转述

**时效性 (timeliness)** — 当前是否值得阅读：
- 10: 正在发生的重大事件/刚发布的重要工具
- 7-9: 近期热点相关
- 4-6: 常青内容，不过时
- 1-3: 过时或无时效价值

#### 分类标签（必须选一个）

- `ai-ml`: AI、机器学习、LLM、深度学习
- `security`: 安全、隐私、漏洞、加密
- `engineering`: 软件工程、架构、编程语言、系统设计
- `tools`: 开发工具、开源项目、新发布的库/框架
- `opinion`: 行业观点、个人思考、职业发展
- `other`: 以上都不适合的

#### 摘要要求

- **中文标题 (titleZh)**: 将英文标题翻译成自然中文。中文标题保持不变
- **摘要 (summary)**: 4-6 句话，包含：核心主题(1句)、关键论点/方案(2-3句)、结论(1句)。直接说重点，不用"本文讨论了..."开头。保留具体技术名词和数据
- **推荐理由 (reason)**: 1 句话说明"为什么值得读"
- **关键词 (keywords)**: 2-4 个英文关键词，如 "Rust", "LLM", "database"

#### 今日看点 (highlights)

根据 Top N 文章，写 3-5 句话的宏观趋势总结。要求：
- 提炼 2-3 个主要趋势或话题
- 不逐篇列举，做宏观归纳
- 风格简洁有力，像新闻导语

#### 输出 JSON 格式

Agent 将结果写入 `.tmp/digest-scored.json`。

**⚠️ 重要：JSON 写入规范**
- 所有字符串值中的双引号（`"`）必须转义为 `\"`，例如：`"title": "他说\"你好\""`
- 中文书名号内的引号同理，如：`"禁言令"` → `\"禁言令\"`
- 禁止在 JSON 文件内容之外写任何说明文字
- **必须使用 `Write` 工具**将完整 JSON 写入 `.tmp/digest-scored.json`，**禁止**将 JSON 内容塞进 Bash heredoc 命令（会导致整个 JSON 内容在对话中大量输出，干扰用户交互）
- 写入前确保 `.tmp/` 目录已创建：`mkdir -p .tmp`
- 写入后，用以下 Bash 命令验证 JSON 合法性：

```bash
python3 -c "import json; json.load(open('.tmp/digest-scored.json'))" && echo "JSON valid"
```

格式如下：

```json
{
  "meta": {
    "totalFeeds": 90,
    "successFeeds": 75,
    "totalArticles": 500,
    "filteredArticles": 120,
    "hours": 48,
    "lang": "zh"
  },
  "highlights": "今日看点文本...",
  "articles": [
    {
      "title": "Original English Title",
      "link": "https://example.com/article",
      "pubDate": "2026-03-07T10:00:00.000Z",
      "description": "原文描述...",
      "sourceName": "example.com",
      "sourceUrl": "https://example.com",
      "score": 25,
      "scoreBreakdown": {
        "relevance": 9,
        "quality": 8,
        "timeliness": 8
      },
      "category": "ai-ml",
      "keywords": ["LLM", "GPT", "benchmark"],
      "titleZh": "中文翻译标题",
      "summary": "4-6 句摘要...",
      "reason": "推荐理由..."
    }
  ]
}
```

**注意**: `meta` 字段的 `totalFeeds`、`successFeeds`、`totalArticles`、`filteredArticles`、`hours` 值直接从 `.tmp/digest-articles.json` 的 `meta` 字段复制。

### Step 2c: 生成 Markdown 报告

使用 report 模式，从评分后的 JSON 生成最终 Markdown，**不需要 AI 调用**：

```bash
npx -y bun ${SKILL_DIR}/scripts/digest.ts \
  --mode report \
  --input .tmp/digest-scored.json \
  --output ./output/digest-$(date +%Y%m%d).md
```

### Step 2d: 保存配置

```bash
mkdir -p ~/.hn-daily-digest
cat > ~/.hn-daily-digest/config.json << 'EOF'
{
  "timeRange": <hours>,
  "topN": <topN>,
  "language": "<zh|en>",
  "lastUsed": "<ISO timestamp>"
}
EOF
```

### Step 3: 结果展示

**成功时**：
- 📁 报告文件路径
- 📊 简要摘要：扫描源数、抓取文章数、精选文章数
- 🏆 **今日精选 Top 3 预览**：中文标题 + 一句话摘要

**报告结构**（生成的 Markdown 文件包含以下板块）：
1. **📝 今日看点** — AI 归纳的 3-5 句宏观趋势总结
2. **🏆 今日必读 Top 3** — 中英双语标题、摘要、推荐理由、关键词标签
3. **📊 数据概览** — 统计表格 + Mermaid 分类饼图 + 高频关键词柱状图 + ASCII 纯文本图（终端友好） + 话题标签云
4. **分类文章列表** — 按 6 大分类（AI/ML、安全、工程、工具/开源、观点/杂谈、其他）分组展示，每篇含中文标题、相对时间、综合评分、摘要、关键词

**失败时**：
- 显示错误信息
- 常见问题：网络问题、RSS 源不可用

---

## 参数映射

| 交互选项 | 脚本参数 |
|----------|----------|
| 24 小时 | `--hours 24` |
| 48 小时 | `--hours 48` |
| 72 小时 | `--hours 72` |
| 7 天 | `--hours 168` |
| 10 篇 | `--top-n 10` |
| 15 篇 | `--top-n 15` |
| 20 篇 | `--top-n 20` |
| 中文 | `--lang zh` |
| English | `--lang en` |
| 自定义代理 | `--proxy <url>` |
| 禁用代理 | `--no-proxy` |

---

## 环境要求

- `bun` 运行时（通过 `npx -y bun` 自动安装）
- 网络访问（需要能访问 RSS 源）
- **不需要** `claude` 或 `ducc` CLI（Agent 直接处理 AI 评分和摘要）

---

## 信息源

90 个 RSS 源来自 [Hacker News Popularity Contest 2025](https://refactoringenglish.com/tools/hn-popularity/)，由 [Andrej Karpathy 推荐](https://x.com/karpathy)。

包括：simonwillison.net, paulgraham.com, overreacted.io, gwern.net, krebsonsecurity.com, antirez.com, daringfireball.net 等顶级技术博客。

完整列表内嵌于脚本中。

---

## 故障排除

### "Failed to fetch N feeds"
部分 RSS 源可能暂时不可用，脚本会跳过失败的源并继续处理。可尝试添加 `--proxy` 参数使用代理。

### "No articles found in time range"
尝试扩大时间范围（如从 24 小时改为 48 小时）。

### 嵌套执行错误
如果使用 `--mode full` 在 ducc/claude 会话内运行时报嵌套执行错误，请改用三步流程（fetch → Agent 评分 → report），这是默认的推荐流程。
