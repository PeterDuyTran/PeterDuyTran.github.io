# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

**Development server:**
```bash
./dev.sh                       # Starts Hugo server at http://localhost:1313 with drafts and live reload
# or
./run-dev.sh                   # Same, with stale public dir cleanup
```

**Production build:**
```bash
./build.sh                     # Builds minified site to site/public/
```

**Create new content:**
```bash
./new-blog.sh post-title       # Creates new blog post
./new-project.sh project-name  # Creates new portfolio project (page bundle)
```

**Stop server:**
```bash
./stop.sh                      # Kills any lingering Hugo server processes
```

## Architecture Overview

This is a Hugo static site using the **Introduction** theme for a game developer portfolio. The site is a single-page app with tab-based navigation (About, Projects, Blog, Contact).

```
Portfolio/
├── site/
│   ├── hugo.yaml              # All site configuration (single file)
│   ├── content/
│   │   ├── home/              # Page bundle: index.md, about.md, contact.md, profile.jpg
│   │   ├── projects/          # Page bundles per project (index.md + images)
│   │   └── blog/              # Blog post markdown files
│   ├── assets/
│   │   ├── css/custom.css     # Typing animation styles
│   │   └── images/            # Hugo-processed images (author/, projects/, site/)
│   ├── static/images/         # Static images copied as-is
│   ├── layouts/
│   │   ├── index.html         # Main SPA layout (hero + tabs + inline CSS/JS)
│   │   └── partials/home/     # Tab content: projects.html, blog.html
│   ├── archetypes/default.md  # Content template
│   └── themes/introduction/   # Git submodule (hugo-theme-introduction)
├── archived/                  # Old theme experiments (gitignored)
├── dev.sh / run-dev.sh        # Development server scripts
├── build.sh                   # Production build script
└── stop.sh                    # Kill Hugo server processes
```

## Key Configuration

- **site/hugo.yaml** — Base URL, theme, params, social links, language settings
- Theme: `introduction` (git submodule from victoriadrake/hugo-theme-introduction)
- Dark/light mode: follows system preference (`themeStyle: auto`)
- Content ordering: `weight` param in front matter (lower = first)

## Content Front Matter

**Home sections (about.md, contact.md) use YAML:**
```yaml
---
title: "About"
image: "profile.jpg"    # optional, for avatar
weight: 8               # tab ordering
---
```

**Projects use page bundles (projects/name/index.md):**
```yaml
---
title: "Project Name"
description: "Brief description shown in project preview"
weight: 1
project_timeframe: "2023 - 2024"    # optional
---
```

## Layout Architecture

The site uses a custom single-page layout (`site/layouts/index.html`) that:
- Renders a fullscreen hero with typing animation
- Builds tab navigation from home page resources + blog/projects sections
- Each tab shows a panel rendered by its respective partial
- Projects partial (`partials/home/projects.html`) has an interactive list/preview switcher
- Tab state is synced with URL hash for deep linking

## Theme Customization

- Override theme templates by placing files in `site/layouts/` matching theme structure
- Custom CSS goes in `site/assets/css/custom.css`
- Accent color: `#4fc3f7` (light blue) used across tabs, indicators, and contact links
- Images: use Hugo's image processing via page resources (`.Resources.GetMatch` + `.Resize`)
