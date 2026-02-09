# Duy Tran — Lead Gameplay Engineer Portfolio

A Hugo-based portfolio website using the [Toha v4 theme](https://github.com/hugo-toha/toha) showcasing work on **Huli: Nine Tails of Vengeance** (UE 5.7 Action RPG) and 6 shipped mobile titles.

## Quick Start

1. **Run development server:**
   ```
   run-dev.bat
   ```
   Site available at: http://localhost:1313/

2. **Build for production:**
   ```
   build.bat
   ```
   Output: `site/public/`

3. **Export PDF:**
   Open a page in the browser → `Ctrl+P` → Save as PDF. Print styles hide nav/footer/sidebar automatically.

## Current Content

### Featured Project
- **Huli: Nine Tails of Vengeance** — Action RPG on UE 5.7 (PC/PS5/Xbox)
  - Deep-dive post: `site/content/posts/huli-technical-showcase.md`
  - Covers: combat systems (GAS, damage pipeline, parry, combo graph), AI framework, plugin architecture, performance engineering
  - No thumbnail yet (commented out in projects.yaml — add `huli-thumb.png` to `site/assets/images/projects/`)

### Shipped Mobile Games (Unity/C#)
Each has a thumbnail on the homepage card + a detail page with in-game screenshot:

| Game | Detail Page | Thumbnail | Screenshot |
|------|-------------|-----------|------------|
| Register Race | `mobile-register-race.md` | `port_registerace_01.png` | `port_registerace_02.png` |
| 2048 Park | `mobile-2048-park.md` | `port_2048_01.png` | `port_2048_02.jpg` |
| Climber | `mobile-climber.md` | `port_climber_01.png` | `port_climber_02.png` |
| Assorted Detective | `mobile-assorted-detective.md` | `port_detective_01.png` | `port_detective_02.png` |
| Assassin | `mobile-assassin.md` | `port_assasin_01.png` | `port_assasin_02.png` |
| Clay Art | `mobile-clay-art.md` | `port_clayart_01.png` | `port_clayart_02.png` |

### Homepage Sections
- **About** — Lead Gameplay Engineer bio with focus areas
- **Skills** — 6 skills: UE 5.7, C++, GAS, AI, Combat Architecture, Plugin Development
- **Projects** — Filterable cards (All / Combat / AI / Architecture / Mobile)
- **Posts** — Blog listing (technical showcase + mobile game detail pages)

## Editing Content

### Update Personal Info
- **Name/contact**: `site/data/en/author.yaml`
- **Bio/summary**: `site/data/en/sections/about.yaml`
- **Social links**: Both `author.yaml` (footer) and `about.yaml` (about section)
- **Site metadata**: `site/data/en/site.yaml`

### Update Projects
- **Project cards**: `site/data/en/sections/projects.yaml`
  - `image:` field → thumbnail on card (path relative to `site/assets/`)
  - `url:` field → links to detail page
  - `tags:` field → controls filter button visibility
- **Thumbnails**: Place in `site/assets/images/projects/` (processed by Hugo pipeline)
- **Detail screenshots**: Place in `site/static/images/projects/` (referenced by markdown)

### Add a New Project
1. Add entry to `projects.yaml` with `image`, `url`, `tags`
2. Place thumbnail in `site/assets/images/projects/`
3. Create detail post in `site/content/posts/`
4. Place in-game screenshots in `site/static/images/projects/`

### Add a Blog Post
```
new-blog.bat my-post-title
```
Edit `site/content/posts/my-post-title.md` and remove `draft: true`.

### Update Skills
Edit `site/data/en/sections/skills.yaml` — logos are optional (commented out).

## Directory Structure

```
Portfolio/
├── run-dev.bat              # Start dev server
├── build.bat                # Build for production
├── new-blog.bat             # Create new blog post
├── setup-toha.bat           # Re-run if modules need update
├── go/                      # Go runtime (for Hugo modules)
├── nodejs/                  # Node.js (for npm packages)
├── hugo-new/                # Hugo v0.147.4 executable
└── site/
    ├── hugo.yaml            # Site config (mounts, features, params)
    ├── data/en/
    │   ├── author.yaml      # Name, contact, rotating summary
    │   ├── site.yaml        # Copyright, meta description, OpenGraph
    │   └── sections/
    │       ├── about.yaml   # Bio, social links, soft skills
    │       ├── skills.yaml  # Technical skills (6 items)
    │       └── projects.yaml# Project cards with filters
    ├── content/posts/
    │   ├── huli-technical-showcase.md    # Huli deep-dive
    │   ├── mobile-register-race.md      # Mobile game pages...
    │   ├── mobile-2048-park.md
    │   ├── mobile-climber.md
    │   ├── mobile-assorted-detective.md
    │   ├── mobile-assassin.md
    │   ├── mobile-clay-art.md
    │   └── ue5-cpp-best-practices.md    # Blog post
    ├── assets/
    │   ├── images/projects/   # Thumbnails (Hugo resource pipeline)
    │   └── styles/
    │       └── override.scss  # Print styles + custom CSS
    └── static/
        ├── images/projects/   # In-game screenshots (markdown refs)
        └── files/             # Downloads (resume.pdf)
```

## Theme Notes

### CSS Customization
The Toha v4 theme uses SCSS compilation. Custom styles go in `site/assets/styles/override.scss` — this is imported at the end of the theme's SCSS build pipeline. **Do not use** `params.customCSS` (not supported by Toha v4).

### Print/PDF Styles
Print styles are in `override.scss` inside an `@media print` block. They:
- Hide navigation, footer, sidebar, TOC
- Reset backgrounds to white
- Clean typography for A4/Letter
- Page breaks between major sections
- Code blocks and tables avoid page splits

### Hugo Module Mounts
When custom mounts are specified in `hugo.yaml`, ALL default mounts are overridden. The config explicitly re-declares `assets`, `static`, `layouts`, `data`, and `content` mounts alongside the node_modules mounts.

### Project Card Images
- `image:` field → full-width card header via `resources.Get` (must be in `assets/`)
- `logo:` field → tiny 24x24 icon next to title (not for thumbnails)

## TODO

- [ ] Add Huli thumbnail image (`site/assets/images/projects/huli-thumb.png`)
- [ ] Fill in LinkedIn URL in `author.yaml` and `about.yaml`
- [ ] Fill in email in `author.yaml` and `about.yaml`
- [ ] Add resume PDF to `site/static/files/resume.pdf`
- [ ] Add skill logos (optional — currently commented out in `skills.yaml`)
- [ ] Add avatar image (`site/assets/images/author/avatar.png`)
- [ ] Update `baseURL` in `hugo.yaml` before deploying (currently `localhost:1313`)

## Troubleshooting

### "Access is denied" on sitemap.xml
The `public/` directory has read-only files (from previous builds). Fix:
```powershell
Get-ChildItem site\public -Recurse -File | ForEach-Object { $_.IsReadOnly = $false }
Remove-Item -Recurse -Force site\public
```

### Rebuild modules
```
setup-toha.bat
```

### Clear cache
```
rmdir /s site\public
rmdir /s site\resources
build.bat
```

### Project thumbnails not showing
Ensure images are in `site/assets/images/projects/` (NOT `static/`). The `image:` field in `projects.yaml` uses Hugo's resource pipeline which only reads from `assets/`.
