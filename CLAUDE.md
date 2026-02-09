# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

**Development server:**
```bash
run-dev.bat                    # Starts Hugo server at http://localhost:1313 with draft content and live reload
```

**Production build:**
```bash
build.bat                      # Builds minified site to site/public/
```

**Create new content:**
```bash
new-blog.bat post-title        # Creates new blog post from archetype
new-project.bat project-name   # Creates new portfolio project from archetype
```

**Theme CSS (from site/themes/blowfish/):**
```bash
npm run dev-windows            # Watch CSS changes during development
npm run build-windows          # Production CSS build
```

## Architecture Overview

This is a Hugo static site using the Blowfish theme for a game developer portfolio.

```
Portfolio/
├── hugo-bin/                  # Hugo extended executable (Windows)
├── site/
│   ├── config/_default/       # Site configuration (hugo.toml, params.toml, menus.en.toml)
│   ├── content/               # Markdown content organized by section
│   │   ├── portfolio/         # Project showcase pages
│   │   ├── blog/              # Technical blog posts
│   │   └── contact/           # Contact page
│   ├── layouts/shortcodes/    # Custom Hugo shortcodes
│   ├── static/                # Static assets (images/, videos/, cv/)
│   ├── archetypes/            # Content templates (blog.md, portfolio.md)
│   └── themes/blowfish/       # Blowfish theme (Git submodule)
```

## Key Configuration Files

- **site/config/_default/hugo.toml** - Base URL, theme, pagination, syntax highlighting
- **site/config/_default/params.toml** - Theme settings (colors, layouts, features, dark mode)
- **site/config/_default/menus.en.toml** - Navigation structure
- **site/config/_default/languages.en.toml** - Author info and language settings

## Content Front Matter

**Blog posts use YAML:**
```yaml
---
title: "Post Title"
date: YYYY-MM-DD
draft: true
summary: "Brief overview"
tags: ["UE5", "C++"]
---
```

**Portfolio projects use YAML with weight for ordering:**
```yaml
---
title: "Project Name"
description: "Brief description"
date: YYYY-MM-DD
draft: true
tags: ["UE5", "C++"]
weight: 10
---
```

## Custom Shortcodes

**video-card** (`site/layouts/shortcodes/video-card.html`) - Interactive card that shows thumbnail and plays video on hover:
```markdown
{{< video-card
    title="Project Name"
    thumbnail="/images/thumb.jpg"
    video="/videos/teaser.mp4"
    description="Brief description"
    link="/portfolio/project"
>}}
```

## Theme Customization

- Dark mode is always enabled (configured in params.toml)
- Color scheme uses CSS variables: `--color-neutral-*`, `--color-primary-*`, `--color-secondary-*`
- Tailwind CSS with typography, forms, and scrollbar plugins
- Override theme templates by placing files in site/layouts/ matching theme structure
