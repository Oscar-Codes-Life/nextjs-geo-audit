# GEO Audit Report Template

Use this exact structure. Replace all `{{placeholders}}` with actual findings. Every finding must include the file path and line number where relevant. Every fix must include a working code snippet.

---

```markdown
# SEO + GEO Technical Audit Report

**Project**: {{project_name}}
**URL**: {{live_url or "Not deployed / not provided"}}
**Framework**: Next.js {{version}} (App Router)
**Deploy target**: {{Vercel / Netlify / Self-hosted / Unknown}}
**Audit date**: {{YYYY-MM-DD}}
**Auditor**: Claude Code (nextjs-geo-audit skill)

---

## Overall GEO Readiness Score: {{X}} / 10

{{One-sentence summary of the overall technical state.}}

### Score Breakdown

| Category | Score | Weight | Weighted |
|----------|-------|--------|----------|
| Technical GEO (robots, sitemap, llms.txt) | {{X}}/10 | 20% | {{X}} |
| Structured data (JSON-LD) | {{X}}/10 | 20% | {{X}} |
| Metadata | {{X}}/10 | 15% | {{X}} |
| SSR content visibility | {{X}}/10 | 30% | {{X}} |
| Link integrity & Next.js config | {{X}}/10 | 15% | {{X}} |
| **Overall** | | | **{{X}}/10** |

---

## Blockers (P0)

{{List any P0 blockers. If none, write "No blockers found."}}

{{For each blocker:}}
### 🚫 {{Blocker title}}

**Impact**: {{Why this blocks AI discoverability}}
**Location**: `{{file_path}}:{{line_number}}` (or "Missing — needs to be created")
**Evidence**: {{What you found}}

**Fix**:
```{{language}}
{{Code snippet showing the fix}}
```

---

## Critical Issues (P1)

{{For each P1 issue:}}
### ⚠️ {{Issue title}}

**Category**: {{Technical GEO / Structured Data / SSR / Metadata / Config}}
**Impact**: {{How this hurts discoverability}}
**Location**: `{{file_path}}:{{line_number}}`
**Current state**: {{What exists now}}
**Expected state**: {{What should exist}}

**Fix**:
```{{language}}
{{Code snippet showing the fix}}
```

---

## Important Issues (P2)

{{Same format as P1 but with ### ℹ️ prefix}}

---

## Nice to Have (P3)

{{Same format but with ### 💡 prefix}}

---

## Detailed Findings by Category

### 1. Technical GEO — Score: {{X}}/10

#### robots.txt / robots.ts

| Check | Status | Detail |
|-------|--------|--------|
| File exists | {{✅/❌}} | {{file path or "Missing"}} |
| Uses dynamic convention (robots.ts) | {{✅/❌/➖}} | {{detail}} |
| Allows all crawlers (userAgent: *) | {{✅/❌}} | {{detail}} |
| AI crawlers not blocked | {{✅/❌}} | {{which are blocked, if any}} |
| Sitemap referenced | {{✅/❌}} | {{detail}} |
| Private routes blocked | {{✅/❌}} | {{detail}} |
| No static/dynamic conflict | {{✅/❌}} | {{detail}} |

{{If file exists, show contents:}}
**Current configuration:**
```
{{file contents}}
```

#### sitemap.xml / sitemap.ts

| Check | Status | Detail |
|-------|--------|--------|
| File exists | {{✅/❌}} | {{file path or "Missing"}} |
| Uses dynamic convention (sitemap.ts) | {{✅/❌/➖}} | {{detail}} |
| All public pages listed | {{✅/❌}} | {{list missing pages}} |
| lastModified present | {{✅/❌}} | {{detail}} |
| changeFrequency set | {{✅/❌}} | {{detail}} |
| priority set | {{✅/❌}} | {{detail}} |

**Pages in codebase vs sitemap:**
| Route | Page file exists | In sitemap |
|-------|-----------------|------------|
{{For each public route}}

#### llms.txt

| Check | Status | Detail |
|-------|--------|--------|
| llms.txt exists | {{✅/❌}} | {{file path or "Missing"}} |
| Returns text/plain | {{✅/❌/N/A}} | {{detail}} |
| Valid Markdown format | {{✅/❌/N/A}} | {{detail}} |
| Lists key pages | {{✅/❌/N/A}} | {{detail}} |
| llms-full.txt exists | {{✅/❌}} | {{file path or "Missing"}} |
| Cache headers set | {{✅/❌/N/A}} | {{detail}} |

### 2. Structured Data — Score: {{X}}/10

| Page | Required Schema | Found | Location |
|------|----------------|-------|----------|
| Root layout | Organization | {{Yes/No}} | {{file:line or "Missing"}} |
| Homepage | WebSite / SoftwareApplication | {{Yes/No}} | {{file:line or "Missing"}} |
| FAQ | FAQPage | {{Yes/No}} | {{file:line or "Missing"}} |
{{Only include rows for pages that exist in the project}}

{{For each schema found, show its location. For each missing, provide the code to add it.}}

### 3. Metadata — Score: {{X}}/10

| Check | Status | Detail |
|-------|--------|--------|
| metadataBase set in root layout | {{✅/❌}} | {{value or "Missing"}} |
| Title template configured | {{✅/❌}} | {{template or "Missing"}} |
| Unique titles per page | {{✅/❌}} | {{pages with missing/duplicate titles}} |
| Meta descriptions on all pages | {{✅/❌}} | {{pages missing descriptions}} |
| Canonical URLs set | {{✅/❌}} | {{detail}} |
| Open Graph configured | {{✅/❌}} | {{detail}} |
| Twitter cards configured | {{✅/❌}} | {{detail}} |
| No accidental noindex | {{✅/❌}} | {{list any pages with noindex}} |

**Per-page metadata audit:**
| Page | Title | Description | Canonical | OG |
|------|-------|-------------|-----------|-----|
{{For each public page}}

### 4. SSR Content Visibility — Score: {{X}}/10

| Page | Server/Client | Content in initial HTML | Issues |
|------|--------------|------------------------|--------|
{{For each public page:}}
| {{route}} | {{Server/Client}} | {{Full/Partial/Empty}} | {{specific issue or "None"}} |

**SSR issues found:**
{{Detail each page where content is hidden from crawlers, with file paths, line numbers, and the specific pattern used (useState, conditional rendering, etc.). For each, explain the fix.}}

### 5. Link Integrity & Next.js Config — Score: {{X}}/10

#### Link integrity

| Check | Status | Detail |
|-------|--------|--------|
| No broken internal links | {{✅/❌}} | {{list broken links with locations}} |
| No placeholder # links | {{✅/❌}} | {{count and file:line locations}} |

**Broken links found:**
{{List each broken link: the href, the file it appears in, and whether a matching page exists}}

**Placeholder links found:**
{{List each href="#" with its file:line location}}

#### Next.js configuration

| Check | Status | Detail |
|-------|--------|--------|
| Middleware safe for crawlers | {{✅/❌/N/A}} | {{detail}} |
| Custom not-found page | {{✅/❌}} | {{detail}} |
| Custom error page | {{✅/❌}} | {{detail}} |
| Public pages use SSG/ISR | {{✅/❌}} | {{detail}} |

---

## Action Plan (Priority Order)

### Immediate (P0)

{{Numbered list of P0 fixes with one-line description}}

### This Week (P1)

{{Numbered list of P1 fixes}}

### Next Sprint (P2)

{{Numbered list of P2 fixes}}

### Backlog (P3)

{{Numbered list of P3 improvements}}

---

## Appendix: Code for Missing Files

Complete, copy-paste-ready code for each missing file.

{{For each missing file:}}
### `{{file_path}}` (NEW)

**Purpose**: {{Why this file is needed}}

```{{language}}
{{Complete file contents}}
```

---

*Report generated by the nextjs-geo-audit skill for Claude Code.*
```

---

## Notes for the auditor

- Fill in EVERY cell in every table. Use ✅, ❌, ➖ (not applicable).
- Every finding must reference a specific file path and line number.
- Every fix must include a complete, working code snippet.
- The Appendix must contain COMPLETE files, not fragments. Copy-paste-ready.
- Only flag missing schemas for pages that exist in the project.
- Do not recommend creating new pages, writing blog posts, or any content strategy. Stick to the technical codebase.
- If a page exists but its content is client-rendered, flag the SSR issue — do not comment on whether the content itself is good or bad.
