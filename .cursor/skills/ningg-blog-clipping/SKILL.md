---
name: ningg-blog-clipping
description: >-
  Generate Jekyll Collection (favorites) clippings with 原文+批注 structure, or
  companion blog posts for ningg.github.com. Use when the user mentions 剪藏,
  Collection, favorites, 收藏一篇, 原文批注, _favorites, or quick blog drafting for
  this site.
---

# NingG Blog Clipping

Generate content for [ningg.github.com](https://ningg.top): **Collection** (`_favorites/`) and optional **Blog** (`_posts/blog/`).

## Repository conventions

| Type | Path | URL pattern | Layout |
|------|------|-------------|--------|
| Collection | `_favorites/YYYY-MM-DD-slug.md` | `/favorites/slug/` (date prefix stripped from URL) | `favorite` (auto) |
| Blog post | `_posts/blog/YYYY-MM-DD-slug.md` | `/slug/` | `post` |

- Collection list: `/favorites/` — hides `published: false`
- Nav label stays **Collection** (do not rename to 剪藏 unless user asks)
- Full examples: [examples.md](examples.md)
- Entry template: `_favorites/template.md`

## Step 1: Confirm output type

Ask or infer:

1. **Collection only** — clipping with 原文 + 批注
2. **Blog only** — original reflection post
3. **Both** — clipping plus a related blog post with cross-links

## Step 2: Collect inputs

| Field | Required | Notes |
|-------|----------|-------|
| `source_url` | For external clippings | Use WebFetch when user gives URL; extract title and key points |
| User 批注 | Yes for Collection | Why saved, conflicts, open questions |
| `tags` | Optional | e.g. `[AI]`, `[nature]` |
| `category` | Blog only | Default `nature`; use `AI` for tech/AI topics |
| `published` | Default `false` | Set `true` only after user confirms |

## Step 3: Generate Collection file

**Filename:** `_favorites/YYYY-MM-DD-<slug>.md`

- `slug`: lowercase English, hyphens; file still named `YYYY-MM-DD-slug.md`, but public URL is `/favorites/slug/` (Jekyll strips the date prefix from collection `:title`)

**Front matter:**

```yaml
---
title: ...
description: 一句话说明为什么收藏
date: YYYY-MM-DD
source_url: https://...   # omit if no external URL
tags: [tag1]
published: false
---
```

**Body — mandatory sections:**

```markdown
## 原文

（摘录、翻译或 bullet 要点）

## 批注

（为什么收藏、冲突/印证、待验证问题；可含关联博文链接）
```

Do not paraphrase copyrighted text at length; prefer summaries and short quotes.

## Step 4: Generate Blog (if requested)

**Filename:** `_posts/blog/YYYY-MM-DD-<slug>.md`

```yaml
---
layout: post
title: ...
description: ...
published: false
category: nature
---
```

**Style** (match site voice):

- Opening `>` blockquote for a distilled thesis
- Short sections with `##` headings
- Bullet lists where appropriate
- End with links to `/favorites/` or the new clipping URL

## Step 5: Cross-links

When both exist:

- Blog → `/favorites/<slug>/`
- Favorite 批注 → `/blog-slug/` (post permalink is `/:title/` without date)

## Step 6: Verify

1. Remind user: `./bin/dev` (or `bundle exec jekyll serve`)
2. Check `/favorites/` list and item URL
3. Check blog post on home list
4. Confirm `published: false` items do not appear on Collection list

**Do not** run `git commit` or `git push` unless the user explicitly asks.

## Slug and date rules

- Use today's date in filename unless user specifies otherwise
- Avoid collision with existing files in `_favorites/` and `_posts/blog/`
- `template.md` and `*-example.md` with `published: false` are drafts — do not overwrite

## Quality checklist

- [ ] Collection has both `## 原文` and `## 批注`
- [ ] `description` is one clear sentence
- [ ] `source_url` present when clipping external content
- [ ] Cross-links use site-relative paths (`/favorites/...`, `/post-slug/`)
- [ ] No secrets or private data in committed files
