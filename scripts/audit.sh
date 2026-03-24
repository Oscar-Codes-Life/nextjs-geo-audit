#!/bin/bash
# nextjs-geo-audit: Codebase scan
# Collects technical data from a Next.js App Router project for GEO analysis.
# Usage: bash audit.sh [project_root]

set -euo pipefail

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

echo "=== NEXTJS GEO AUDIT — CODEBASE SCAN ==="
echo "Project root: $(pwd)"
echo "Scan date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# --- Detect app directory ---
echo "=== APP DIRECTORY ==="
if [ -d "src/app" ]; then
  APP_DIR="src/app"
elif [ -d "app" ]; then
  APP_DIR="app"
else
  echo "ERROR: No app/ directory found. Is this a Next.js App Router project?"
  exit 1
fi
echo "APP_DIR=$APP_DIR"

# --- Next.js version ---
echo ""
echo "=== NEXT.JS VERSION ==="
grep -oP '"next"\s*:\s*"[^"]*"' package.json 2>/dev/null || echo "NOT FOUND"

# --- Deploy config ---
echo ""
echo "=== DEPLOY CONFIG ==="
echo "--- vercel.json ---"
cat vercel.json 2>/dev/null || echo "NOT FOUND"
echo ""
echo "--- next.config ---"
cat next.config.ts 2>/dev/null || cat next.config.js 2>/dev/null || cat next.config.mjs 2>/dev/null || echo "NOT FOUND"

# --- Robots ---
echo ""
echo "=== ROBOTS ==="
echo "--- Dynamic robots.ts ---"
ROBOTS_TS=$(find "$APP_DIR" -maxdepth 1 \( -name "robots.ts" -o -name "robots.js" \) 2>/dev/null | head -1)
if [ -n "$ROBOTS_TS" ]; then
  echo "FOUND: $ROBOTS_TS"
  cat "$ROBOTS_TS"
else
  echo "NOT FOUND"
fi
echo ""
echo "--- Static robots.txt ---"
if [ -f "public/robots.txt" ]; then
  echo "FOUND: public/robots.txt"
  cat public/robots.txt
else
  echo "NOT FOUND"
fi

# --- Sitemap ---
echo ""
echo "=== SITEMAP ==="
echo "--- Dynamic sitemap.ts ---"
SITEMAP_TS=$(find "$APP_DIR" -maxdepth 1 \( -name "sitemap.ts" -o -name "sitemap.js" \) 2>/dev/null | head -1)
if [ -n "$SITEMAP_TS" ]; then
  echo "FOUND: $SITEMAP_TS"
  cat "$SITEMAP_TS"
else
  echo "NOT FOUND"
fi
echo ""
echo "--- Static sitemap.xml ---"
if [ -f "public/sitemap.xml" ]; then
  echo "FOUND: public/sitemap.xml"
  head -50 public/sitemap.xml
else
  echo "NOT FOUND"
fi

# --- llms.txt ---
echo ""
echo "=== LLMS.TXT ==="
echo "--- Route handler ---"
LLMS_ROUTE=$(find "$APP_DIR" -path "*/llms.txt/route.ts" -o -path "*/llms.txt/route.js" 2>/dev/null | head -1)
if [ -n "$LLMS_ROUTE" ]; then
  echo "FOUND: $LLMS_ROUTE"
  cat "$LLMS_ROUTE"
else
  echo "NOT FOUND"
fi
echo ""
echo "--- llms-full.txt route ---"
LLMS_FULL=$(find "$APP_DIR" -path "*/llms-full.txt/route.ts" -o -path "*/llms-full.txt/route.js" 2>/dev/null | head -1)
if [ -n "$LLMS_FULL" ]; then
  echo "FOUND: $LLMS_FULL"
  cat "$LLMS_FULL"
else
  echo "NOT FOUND"
fi
echo ""
echo "--- Static llms.txt ---"
if [ -f "public/llms.txt" ]; then
  echo "FOUND: public/llms.txt"
  cat public/llms.txt
else
  echo "NOT FOUND"
fi

# --- JSON-LD / Structured Data ---
echo ""
echo "=== JSON-LD / STRUCTURED DATA ==="
echo "--- application/ld+json ---"
grep -rn "application/ld+json" "$APP_DIR/" --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" 2>/dev/null || echo "NONE FOUND"
echo ""
echo "--- schema.org ---"
grep -rn "schema.org" "$APP_DIR/" --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" 2>/dev/null || echo "NONE FOUND"
echo ""
echo "--- JsonLd component ---"
grep -rn "JsonLd\|jsonLd\|json-ld\|JSON_LD" "$APP_DIR/" --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" 2>/dev/null || echo "NONE FOUND"
echo ""
echo "--- Schema packages ---"
grep -E "next-seo|schema-dts|next-json-ld" package.json 2>/dev/null || echo "NONE FOUND"

# --- Metadata ---
echo ""
echo "=== METADATA ==="
echo "--- Root layout (first 100 lines) ---"
head -100 "$APP_DIR/layout.tsx" 2>/dev/null || echo "NOT FOUND"
echo ""
echo "--- metadataBase ---"
grep -rn "metadataBase" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null || echo "NONE FOUND"
echo ""
echo "--- generateMetadata ---"
grep -rn "generateMetadata" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null || echo "NONE FOUND"
echo ""
echo "--- Canonical URLs ---"
grep -rn "canonical" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null || echo "NONE FOUND"
echo ""
echo "--- Open Graph / Twitter ---"
grep -rn "openGraph\|twitter" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null | head -15 || echo "NONE FOUND"
echo ""
echo "--- noindex / nofollow ---"
grep -rn "noindex\|nofollow" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null || echo "NONE FOUND (good)"

# --- SSR Content Visibility ---
echo ""
echo "=== SSR CONTENT VISIBILITY ==="
echo "--- Page component type (server vs client) ---"
find "$APP_DIR" \( -name "page.tsx" -o -name "page.ts" -o -name "page.jsx" -o -name "page.js" \) 2>/dev/null | grep -v "node_modules" | while read -r f; do
  if head -3 "$f" | grep -q "use client"; then
    echo "CLIENT: $f"
  else
    echo "SERVER: $f"
  fi
done
echo ""
echo "--- State-driven content hiding ---"
grep -rn "useState.*open\|useState.*active\|useState.*expanded\|useState.*show\|isOpen\|setOpen\|setActive\|setExpanded\|setShow" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null | head -30 || echo "NONE FOUND"
echo ""
echo "--- Conditional rendering ---"
grep -rn "isOpen &&\|isExpanded &&\|isActive &&\|show &&\|open &&" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null | head -20 || echo "NONE FOUND"
echo ""
echo "--- SSR-safe patterns (details/summary/forceMount) ---"
grep -rn "<details\|<summary\|forceMount\|Disclosure" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null | head -20 || echo "NONE FOUND"

# --- Page inventory ---
echo ""
echo "=== PAGE INVENTORY ==="
find "$APP_DIR" \( -name "page.tsx" -o -name "page.ts" -o -name "page.jsx" -o -name "page.js" \) 2>/dev/null | grep -v "node_modules" | sort

# --- Link integrity ---
echo ""
echo "=== LINK INTEGRITY ==="
echo "--- Internal links ---"
grep -rohP 'href="\/[^"]*"' "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null | sort -u | head -40
echo ""
echo "--- Placeholder # links ---"
grep -rn 'href="#"' "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null | head -20 || echo "NONE FOUND (good)"

# --- Middleware ---
echo ""
echo "=== MIDDLEWARE ==="
for f in "$APP_DIR/middleware.ts" "src/middleware.ts" "middleware.ts"; do
  if [ -f "$f" ]; then
    echo "FOUND: $f"
    cat "$f"
  fi
done
[ -z "$(find . -maxdepth 2 -name 'middleware.ts' 2>/dev/null)" ] && echo "NOT FOUND"

# --- Error pages ---
echo ""
echo "=== ERROR PAGES ==="
ls "$APP_DIR/not-found.tsx" 2>/dev/null && echo "Custom 404: YES" || echo "Custom 404: NO"
ls "$APP_DIR/error.tsx" 2>/dev/null && echo "Custom error: YES" || echo "Custom error: NO"

# --- Static generation ---
echo ""
echo "=== STATIC GENERATION ==="
grep -rn "revalidate\|generateStaticParams\|dynamic.*=.*'force" "$APP_DIR/" --include="*.tsx" --include="*.ts" 2>/dev/null | head -10 || echo "NONE FOUND"

echo ""
echo "=== SCAN COMPLETE ==="
