# AI Crawler User Agents Reference

This file lists all known AI crawler user agents as of early 2026. Use this to verify that `robots.ts` is not blocking any of them, and to generate the recommended robots configuration.

## Crawler List

| User Agent | Company | Purpose | Should Allow? |
|------------|---------|---------|---------------|
| `GPTBot` | OpenAI | Training data collection | Yes — needed for ChatGPT to know about you |
| `ChatGPT-User` | OpenAI | Real-time browsing when user asks ChatGPT | Yes — this is the live citation crawler |
| `OAI-SearchBot` | OpenAI | OpenAI search feature | Yes |
| `ClaudeBot` | Anthropic | Training and retrieval | Yes |
| `anthropic-ai` | Anthropic | Alternative identifier | Yes |
| `PerplexityBot` | Perplexity | Real-time search and citation | Yes — Perplexity is a major AI search engine |
| `Google-Extended` | Google | Gemini training data | Yes — needed for Gemini/AI Overviews |
| `Googlebot` | Google | Traditional search + AI Overviews | Yes (never block) |
| `Applebot-Extended` | Apple | Siri and Safari AI features | Yes |
| `Bytespider` | ByteDance | TikTok AI features | Optional |
| `cohere-ai` | Cohere | Cohere model training | Optional |
| `Diffbot` | Diffbot | Knowledge graph extraction | Optional |
| `FacebookExternalHit` | Meta | Link previews + AI | Yes (for social sharing) |
| `meta-externalagent` | Meta | Meta AI features | Optional |
| `Amazonbot` | Amazon | Alexa and Amazon AI | Optional |
| `YouBot` | You.com | You.com AI search | Optional |

## Recommended robots.ts Configuration (Next.js App Router)

```typescript
import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || 'https://www.example.com'

  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/api/', '/auth/', '/dashboard/', '/admin/', '/private/'],
      },
      // Explicitly allow all AI crawlers (reinforces intent)
      {
        userAgent: [
          'GPTBot',
          'ChatGPT-User',
          'OAI-SearchBot',
          'ClaudeBot',
          'anthropic-ai',
          'PerplexityBot',
          'Google-Extended',
          'Applebot-Extended',
          'Bytespider',
          'cohere-ai',
        ],
        allow: '/',
        disallow: ['/api/', '/auth/', '/dashboard/', '/admin/'],
      },
    ],
    sitemap: `${baseUrl}/sitemap.xml`,
    host: baseUrl,
  }
}
```

## How to Check if AI Crawlers are Being Blocked

### In the codebase
Look for any of these user agent strings in:
- `robots.ts` / `robots.txt` — check `disallow` rules
- `middleware.ts` — check if user-agent filtering is applied
- `next.config.ts` — check `headers()` for bot-specific rules
- `vercel.json` — check for firewall or bot protection rules

### On Vercel
Check the Vercel dashboard:
1. Go to Project Settings → Security
2. Check "Bot Protection" — if enabled, verify AI bots are not challenged
3. Check "Firewall Rules" — verify no rules block AI user agents

### Via server logs
If you have access to Vercel analytics or server logs:
```bash
# Look for AI crawler visits
grep -E "GPTBot|ChatGPT-User|ClaudeBot|PerplexityBot|Google-Extended" access.log
```
