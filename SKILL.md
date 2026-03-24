---
name: nextjs-geo-audit
description: "Run a technical SEO + GEO (Generative Engine Optimization) audit on a Next.js App Router codebase and produce a detailed Markdown report. Use this skill whenever the user asks to audit, analyze, check, review, or optimize their site's SEO, GEO, AEO, AI discoverability, LLM visibility, or search engine presence — and the project is a Next.js application. Also trigger when the user mentions robots.txt, sitemap, llms.txt, JSON-LD, structured data, schema markup, AI crawlers, or asks 'how do I show up in ChatGPT/Claude/Gemini/Perplexity'. Focuses exclusively on what can be checked and fixed in the codebase — no content strategy, no blog recommendations, no off-site advice. The output is a detailed Markdown audit report with scores, findings, and actionable fix instructions with code snippets."
---

# Next.js SEO + GEO Technical Audit

## What this skill does

Audits a Next.js App Router codebase for technical SEO and GEO (Generative Engine Optimization) signals — everything that determines whether AI agents and search engines can crawl, parse, and cite your site.

This skill is scoped exclusively to what exists (or should exist) in the codebase. It does not make recommendations about content strategy, blog topics, social media presence, or off-site authority.

It produces a Markdown report with:
- Scores per category (0-10)
- An overall GEO readiness score
- Specific findings with file paths and line numbers
- Actionable fix instructions with copy-paste code snippets
- Priority-ranked action plan

## Prerequisites

- Next.js 13+ project using the App Router (`app/` directory)
- Access to the project source code

---

## Audit Procedure

Follow these steps in order. Collect all findings, then generate the report.

### Step 1: Identify the project structure

```bash
# Find the app directory
find . -type d -name "app" -not -path "*/node_modules/*" -not -path "*/.next/*" | head -5

# Next.js version
grep -oP '"next"\s*:\s*"[^"]*"' package.json 2>/dev/null

# Check src/ convention
ls src/app 2>/dev/null && echo "Uses src/app" || echo "Uses app/"

# Deployment config
cat vercel.json 2>/dev/null || echo "No vercel.json"
cat next.config.ts 2>/dev/null || cat next.config.js 2>/dev/null || cat next.config.mjs 2>/dev/null
```

Record `APP_DIR` (e.g., `src/app` or `app`) and `NEXT_VERSION`.

### Step 2: Audit robots configuration

```bash
# Dynamic robots.ts (preferred)
find $APP_DIR -maxdepth 1 \( -name "robots.ts" -o -name "robots.js" \) 2>/dev/null | head -1

# Static robots.txt
ls public/robots.txt 2>/dev/null

# Read contents
cat $APP_DIR/robots.ts 2>/dev/null || cat $APP_DIR/robots.js 2>/dev/null || cat public/robots.txt 2>/dev/null
```

**Checks:**

| Signal | Pass | Fail |
|--------|------|------|
| File exists | `robots.ts` or `robots.txt` present | Neither exists |
| Uses dynamic convention | `app/robots.ts` with `MetadataRoute.Robots` | Static file only (minor) |
| Allows all crawlers | `userAgent: '*', allow: '/'` | Blocks root |
| AI crawlers not blocked | GPTBot, ClaudeBot, PerplexityBot, Google-Extended not disallowed | Any AI crawler blocked |
| Sitemap referenced | `sitemap:` field present | No sitemap reference |
| Private routes blocked | `/api/`, `/auth/`, `/dashboard/` disallowed | Sensitive routes exposed |
| No conflict | Not both `robots.ts` AND `public/robots.txt` | Both exist |

Refer to `references/ai-crawlers.md` for the full list of AI crawler user agents to verify.

### Step 3: Audit sitemap configuration

```bash
find $APP_DIR -maxdepth 1 \( -name "sitemap.ts" -o -name "sitemap.js" \) 2>/dev/null | head -1
ls public/sitemap.xml 2>/dev/null
cat $APP_DIR/sitemap.ts 2>/dev/null || cat $APP_DIR/sitemap.js 2>/dev/null
```

**Checks:**

| Signal | Pass | Fail |
|--------|------|------|
| File exists | `sitemap.ts` or `sitemap.xml` present | Neither exists |
| Uses dynamic convention | `app/sitemap.ts` with `MetadataRoute.Sitemap` | Static only (minor) |
| All public pages listed | Every public route has an entry | Missing routes |
| Has lastModified | Present on entries | Missing |
| Has changeFrequency | Set appropriately | Missing |
| Has priority | Set (1.0 homepage, lower for others) | Missing |
| No conflict | Not both `sitemap.ts` AND `public/sitemap.xml` | Both exist |

Cross-reference sitemap entries against actual page files discovered in Step 1.

### Step 4: Audit llms.txt

```bash
# Route handler
find $APP_DIR -path "*/llms.txt/route.ts" -o -path "*/llms.txt/route.js" 2>/dev/null
find $APP_DIR -path "*/llms-full.txt/route.ts" -o -path "*/llms-full.txt/route.js" 2>/dev/null

# Static file
ls public/llms.txt 2>/dev/null
```

**Checks:**

| Signal | Pass | Fail |
|--------|------|------|
| llms.txt exists | Route handler or static file present | Missing |
| Returns text/plain | Content-Type header is `text/plain` | Wrong content type |
| Valid Markdown format | Has H1 title, blockquote summary, sections with links | Malformed or empty |
| Lists key pages | Links to public pages with descriptions | No links |
| Cache headers set | `Cache-Control` with reasonable TTL | No caching |
| llms-full.txt exists | Extended version available | Missing (minor) |

### Step 5: Audit JSON-LD structured data

```bash
grep -rn "application/ld+json" $APP_DIR/ --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" 2>/dev/null | head -20
grep -rn "schema.org" $APP_DIR/ --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" 2>/dev/null | head -20
grep -rn "JsonLd\|jsonLd\|json-ld\|JSON_LD" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null | head -20
grep -E "next-seo|schema-dts|next-json-ld" package.json 2>/dev/null
```

Only evaluate schemas for pages that actually exist in the project:

| If page exists | Required Schema |
|---------------|----------------|
| Root layout (always) | `Organization` |
| Homepage | `WebSite`; also `SoftwareApplication` if SaaS |
| FAQ page | `FAQPage` with Q&A pairs |
| Blog posts | `Article` or `BlogPosting` |
| Pricing page | `Product` or `Offer` |
| How-to / guide pages | `HowTo` |

Do not flag missing schemas for pages that do not exist.

### Step 6: Audit metadata configuration

```bash
# Root layout metadata
head -100 $APP_DIR/layout.tsx 2>/dev/null

# metadataBase
grep -rn "metadataBase" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null

# Dynamic metadata
grep -rn "generateMetadata" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null

# Canonical URLs
grep -rn "canonical\|alternates" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null

# Open Graph / Twitter
grep -rn "openGraph\|twitter" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null

# noindex check
grep -rn "noindex\|nofollow" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null
```

**Checks:**

| Signal | Pass | Fail |
|--------|------|------|
| metadataBase set | In root layout | Missing (OG images break) |
| Title template | `title: { template: '%s \| Site' }` | No template |
| Unique titles per page | Each page exports its own `metadata.title` | Same/missing titles |
| Meta descriptions | Every public page has `description` | Missing on any page |
| Canonical URLs | `alternates.canonical` set | Missing |
| Open Graph | `openGraph` with image | Missing |
| Twitter cards | `twitter` card configured | Missing |
| No accidental noindex | No `noindex` on public pages | Public page has noindex |

### Step 7: Audit SSR content visibility

AI crawlers do not execute JavaScript. Content must be in the server-rendered HTML.

```bash
# Which page files are client components
find $APP_DIR -name "page.tsx" -o -name "page.ts" 2>/dev/null | while read -r f; do
  if head -3 "$f" | grep -q "use client"; then
    echo "CLIENT: $f"
  else
    echo "SERVER: $f"
  fi
done

# State-driven content hiding patterns
grep -rn "useState.*open\|useState.*active\|useState.*expanded\|isOpen\|setOpen\|setExpanded" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null | head -30

# Conditional rendering that hides content from SSR
grep -rn "isOpen &&\|isExpanded &&\|isActive &&\|show &&\|open &&" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null | head -20

# Good SSR patterns
grep -rn "<details\|<summary\|Disclosure\|Accordion\|Collapsible\|forceMount" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null | head -20
```

**Checks:**

| Signal | Pass | Fail |
|--------|------|------|
| Page files are Server Components | No `'use client'` on page.tsx | Page itself is client component |
| FAQ answers in server HTML | Answers in DOM on initial render (CSS-hidden OK) | Answers behind `{isOpen && ...}` |
| Pricing data in server HTML | Plans, prices, features in initial DOM | Client-rendered pricing cards |
| Accordion content in DOM | Uses `<details>`, CSS visibility, or `forceMount` | Content conditionally rendered via state |

For each page with interactive show/hide, trace the rendering:
1. Find the component rendering the content
2. Check if it uses `'use client'`
3. Check if content is behind a state conditional (`{state && <content>}`)
4. If content is absent from server HTML, flag it

### Step 8: Audit link integrity

```bash
# All internal href links
grep -rohP 'href="\/[^"]*"' $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null | sort -u

# Cross-reference with page files
find $APP_DIR -name "page.tsx" -o -name "page.ts" 2>/dev/null | sort

# Placeholder links
grep -rn 'href="#"' $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null | head -20
```

**Checks:**

| Signal | Pass | Fail |
|--------|------|------|
| No broken internal links | Every `href="/path"` has a matching page | Links to nonexistent pages |
| No placeholder links | No `href="#"` anywhere | Placeholder `#` links found |

### Step 9: Audit Next.js configuration

```bash
# Full next.config
cat next.config.ts 2>/dev/null || cat next.config.js 2>/dev/null || cat next.config.mjs 2>/dev/null

# Middleware
cat $APP_DIR/middleware.ts 2>/dev/null || cat src/middleware.ts 2>/dev/null || cat middleware.ts 2>/dev/null

# ISR / static generation
grep -rn "revalidate\|generateStaticParams\|dynamic.*=.*'force-static'\|dynamic.*=.*'force-dynamic'" $APP_DIR/ --include="*.tsx" --include="*.ts" 2>/dev/null | head -10

# Error pages
ls $APP_DIR/not-found.tsx $APP_DIR/error.tsx $APP_DIR/global-error.tsx 2>/dev/null
```

**Checks:**

| Signal | Pass | Fail |
|--------|------|------|
| Middleware doesn't block crawlers | No user-agent filtering that blocks bots | Middleware blocks bots |
| Custom 404 page | `not-found.tsx` exists | Default Next.js 404 |
| Custom error page | `error.tsx` exists | Missing (minor) |
| Public pages use SSG/ISR | Static generation where appropriate | Unnecessary `force-dynamic` on public pages |

---

## Report Generation

After all findings, generate `GEO_AUDIT_REPORT.md` in the project root. Read `references/report-template.md` for the exact template.

**Scoring — each category 0-10:**

| Score | Meaning |
|-------|---------|
| 0-2 | Nothing implemented |
| 3-4 | Partially started, major gaps |
| 5-6 | Basics present, room to improve |
| 7-8 | Solid, minor gaps |
| 9-10 | Best-practice level |

**Overall score** = weighted average:
- Technical GEO (robots, sitemap, llms.txt): 20%
- Structured data (JSON-LD): 20%
- Metadata: 15%
- SSR content visibility: 30%
- Link integrity & Next.js config: 15%

**Priority classification:**
- **P0 — Blocker**: `noindex` on public pages, AI crawlers blocked, page files are client components with no server content
- **P1 — Critical**: No robots.ts, no sitemap.ts, no JSON-LD, content hidden from SSR
- **P2 — Important**: No llms.txt, missing meta descriptions, no Open Graph, no canonical URLs
- **P3 — Nice to have**: Missing Twitter cards, no llms-full.txt, no custom 404 page

Every fix must include a working code snippet that can be applied directly in the codebase. Refer to `references/templates.md` for complete file templates to include in the report appendix.
