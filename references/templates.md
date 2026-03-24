# Recommended File Templates for Next.js GEO

Use these in the report Appendix when the audit finds missing files. Customize all `{{}}` placeholders based on the project.

---

## robots.ts

**Path**: `app/robots.ts`

```typescript
import type { MetadataRoute } from 'next'

const BASE_URL = process.env.NEXT_PUBLIC_BASE_URL || 'https://www.example.com'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/api/', '/auth/', '/dashboard/', '/admin/', '/private/'],
      },
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
    sitemap: `${BASE_URL}/sitemap.xml`,
    host: BASE_URL,
  }
}
```

---

## sitemap.ts

**Path**: `app/sitemap.ts`

Populate the `staticPages` array with every public route that exists in the project. If dynamic routes exist (e.g., blog posts from a CMS), add the dynamic fetch logic.

```typescript
import type { MetadataRoute } from 'next'

const BASE_URL = process.env.NEXT_PUBLIC_BASE_URL || 'https://www.example.com'

export default function sitemap(): MetadataRoute.Sitemap {
  const staticPages: MetadataRoute.Sitemap = [
    {
      url: BASE_URL,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 1,
    },
    // Add one entry per public page file found in the project
  ]

  return staticPages
}
```

---

## llms.txt Route Handler

**Path**: `app/llms.txt/route.ts`

```typescript
export async function GET() {
  const content = `# {{Site Name}}

> {{One-paragraph factual description of the site/product.}}

## Key Pages

- [Homepage]({{base_url}}/): {{Brief description}}
- [Pricing]({{base_url}}/pricing): {{Brief description}}
- [FAQ]({{base_url}}/faq): {{Brief description}}

## Company

{{Company info and contact email}}
`

  return new Response(content, {
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
      'Cache-Control': 'public, max-age=86400, s-maxage=86400',
    },
  })
}
```

---

## JSON-LD Utility Component

**Path**: `components/json-ld.tsx`

```tsx
type JsonLdProps = {
  data: Record<string, unknown>
}

export function JsonLd({ data }: JsonLdProps) {
  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  )
}
```

### Organization Schema (root layout)

```tsx
<JsonLd
  data={{
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: '{{Site Name}}',
    url: '{{base_url}}',
    logo: '{{base_url}}/logo.png',
    description: '{{One-sentence description}}',
    email: '{{contact_email}}',
    sameAs: [],
  }}
/>
```

### SoftwareApplication Schema (homepage, for SaaS)

```tsx
<JsonLd
  data={{
    '@context': 'https://schema.org',
    '@type': 'SoftwareApplication',
    name: '{{Product Name}}',
    url: '{{base_url}}',
    applicationCategory: 'BusinessApplication',
    operatingSystem: 'Web',
    description: '{{Description}}',
    offers: {
      '@type': 'Offer',
      price: '0',
      priceCurrency: 'USD',
      description: '{{e.g. "Free trial"}}',
    },
    featureList: [],
  }}
/>
```

### FAQPage Schema

Generate dynamically from the same data source the FAQ page uses:

```tsx
<JsonLd
  data={{
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqItems.map((item) => ({
      '@type': 'Question',
      name: item.question,
      acceptedAnswer: {
        '@type': 'Answer',
        text: item.answer,
      },
    })),
  }}
/>
```

### Article Schema (blog posts, if blog exists)

```tsx
<JsonLd
  data={{
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.title,
    description: post.excerpt,
    url: `${BASE_URL}/blog/${post.slug}`,
    datePublished: post.publishedAt,
    dateModified: post.updatedAt,
    author: { '@type': 'Person', name: post.author },
    publisher: {
      '@type': 'Organization',
      name: '{{Site Name}}',
      logo: { '@type': 'ImageObject', url: `${BASE_URL}/logo.png` },
    },
  }}
/>
```

---

## Root Layout Metadata

**Path**: `app/layout.tsx` (metadata export)

```typescript
import type { Metadata } from 'next'

const BASE_URL = process.env.NEXT_PUBLIC_BASE_URL || 'https://www.example.com'

export const metadata: Metadata = {
  metadataBase: new URL(BASE_URL),
  title: {
    default: '{{Site Name}} — {{Tagline}}',
    template: '%s | {{Site Name}}',
  },
  description: '{{60-160 char description}}',
  alternates: {
    canonical: BASE_URL,
  },
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: BASE_URL,
    siteName: '{{Site Name}}',
    title: '{{Site Name}} — {{Tagline}}',
    description: '{{OG description}}',
    images: [{ url: '/og-image.png', width: 1200, height: 630 }],
  },
  twitter: {
    card: 'summary_large_image',
    title: '{{Site Name}} — {{Tagline}}',
    description: '{{Twitter description}}',
    images: ['/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: { index: true, follow: true },
  },
}
```

---

## SSR-Safe FAQ Pattern

Replace state-driven accordions with `<details>/<summary>` so answers are always in the server HTML:

```tsx
function FAQItem({ question, answer }: { question: string; answer: string }) {
  return (
    <details className="border-b py-4">
      <summary className="cursor-pointer font-medium text-lg">
        {question}
      </summary>
      <p className="mt-3 text-muted-foreground">{answer}</p>
    </details>
  )
}
```

If using Radix Accordion, add `forceMount` to `AccordionContent` and use CSS to hide/show:

```tsx
<AccordionContent forceMount className="data-[state=closed]:hidden">
  {answer}
</AccordionContent>
```

This keeps content in the DOM for crawlers while still toggling visibility for users.
