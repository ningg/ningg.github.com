# AGENTS.md — ningg.github.com

Jekyll static site (GitHub Pages) hosted at `https://ningg.top`. Personal Chinese blog of NingG (郭宁).

## Dev server

```bash
./bin/dev                      # http://127.0.0.1:4000, auto-kills stale ruby/jekyll on port 4000
JEKYLL_HOST=0.0.0.0 JEKYLL_PORT=4001 ./bin/dev   # override host/port
```

Manual fallback: `bundle exec jekyll serve --host 127.0.0.1 --port 4000 --trace`

`Gemfile.lock` is gitignored (intentional for local mac dev). Run `bundle install` if missing.

## Content types

| Type | Path | URL | Layout |
|------|------|-----|--------|
| Blog post | `_posts/blog/YYYY-MM-DD-slug.md` | `/:title/` | `post` |
| Collection (favorites) | `_favorites/YYYY-MM-DD-slug.md` | `/favorites/:title/` | `favorite` (auto) |

- `_favorites/template.md` — starter for new clippings
- `_posts/blog/template.md` — starter for new blog posts
- Collection front matter: `published: false` hides from `/favorites/` list
- Required Collection sections: `## 原文` + `## 批注`
- Blog categories used: `nature`, `AI`

## Git

- Commit messages: short English, ≤20 words, no automatic commit/push
- Cursor commit command at `.cursor/commands/commit.md`

## Available tooling

- **Cursor skill** `ningg-blog-clipping` at `.cursor/skills/ningg-blog-clipping/SKILL.md` — generates `_favorites/` clippings with 原文+批注 and optional companion blog posts
- No test suite, linter, or CI pipeline — verify by previewing locally via `./bin/dev`
