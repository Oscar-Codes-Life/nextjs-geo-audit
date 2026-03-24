# nextjs-geo-audit

A Claude Code skill that runs technical SEO + GEO (Generative Engine Optimization) audits on Next.js App Router codebases.

## Installation

### Option 1: Install as a Skill (recommended)

Clone directly into your Claude Code skills directory:

**For all projects (personal):**

```bash
git clone https://github.com/Oscar-Codes-Life/nextjs-geo-audit.git ~/.claude/skills/nextjs-geo-audit
```

**For a specific project:**

```bash
git clone https://github.com/Oscar-Codes-Life/nextjs-geo-audit.git .claude/skills/nextjs-geo-audit
```

The skill loads automatically — no config changes needed. Claude Code will trigger it when you ask about SEO, GEO, or AI discoverability.

### Option 2: Install via Plugin Marketplace

Add the repository as a plugin marketplace in Claude Code:

```
/plugin marketplace add Oscar-Codes-Life/nextjs-geo-audit
```

Then install the skill:

```
/plugin install nextjs-geo-audit
```

Reload to activate:

```
/reload-plugins
```

## What It Does

Scans your Next.js project and produces a detailed Markdown report covering everything that determines whether AI agents (ChatGPT, Claude, Perplexity, Gemini) and search engines can crawl, parse, and cite your site.

The audit is **codebase-only** — no content strategy, no blog recommendations, no off-site advice. Just actionable technical findings with file paths, line numbers, and copy-paste-ready code fixes.

**Output includes:**
- Scores per category (0-10) and an overall GEO readiness score
- Prioritized findings (P0 blockers through P3 nice-to-haves)
- Working code snippets for every fix
- Complete file templates for anything missing

## What It Audits

| # | Category | What's checked |
|---|----------|----------------|
| 1 | **Robots configuration** | `robots.ts`/`robots.txt` existence, AI crawler access (GPTBot, ClaudeBot, PerplexityBot, etc.), private route blocking |
| 2 | **Sitemap** | `sitemap.ts`/`sitemap.xml` existence, page coverage, `lastModified`, `changeFrequency`, `priority` |
| 3 | **llms.txt** | Route handler or static file, content type, Markdown format, cache headers |
| 4 | **JSON-LD structured data** | `Organization`, `WebSite`, `FAQPage`, `Article`, `SoftwareApplication` schemas where applicable |
| 5 | **Metadata** | `metadataBase`, title templates, descriptions, canonical URLs, Open Graph, Twitter cards, accidental `noindex` |
| 6 | **SSR content visibility** | Server vs client components, state-driven content hiding, content present in initial HTML |
| 7 | **Link integrity** | Broken internal links, placeholder `href="#"` links |
| 8 | **Next.js configuration** | Middleware bot-blocking, custom 404/error pages, static generation settings |

## Scoring

Each category is scored 0-10 and weighted into an overall GEO readiness score:

| Category | Weight |
|----------|--------|
| Technical GEO (robots, sitemap, llms.txt) | 20% |
| Structured data (JSON-LD) | 20% |
| Metadata | 15% |
| SSR content visibility | 30% |
| Link integrity & Next.js config | 15% |

| Score | Meaning |
|-------|---------|
| 0-2 | Nothing implemented |
| 3-4 | Partially started, major gaps |
| 5-6 | Basics present, room to improve |
| 7-8 | Solid, minor gaps |
| 9-10 | Best-practice level |

## Project Structure

```
nextjs-geo-audit/
├── SKILL.md                        # Skill definition and full audit procedure
├── scripts/
│   └── audit.sh                    # Automated codebase scanner (bash)
└── references/
    ├── ai-crawlers.md              # AI crawler user agents reference
    ├── report-template.md          # Audit report Markdown template
    └── templates.md                # Copy-paste code templates for fixes
```

## Usage

### As a Claude Code Skill

Install this as a Claude Code skill, then trigger it by asking Claude Code to audit your Next.js project:

```
audit my site's SEO
run a GEO audit
check my AI discoverability
how do I show up in ChatGPT/Perplexity?
```

Claude Code will scan the codebase and generate a `GEO_AUDIT_REPORT.md` in the project root.

### Standalone Scanner

Run the bash scanner directly to collect raw codebase data:

```bash
bash scripts/audit.sh /path/to/your/nextjs-project
```

If no path is provided, it defaults to the current directory.

## Prerequisites

- Next.js 13+ project using the App Router (`app/` directory)
- Access to the project source code

## Author

**Oscar Gallo** — [oscarcodeslife.com](https://oscarcodeslife.com)
