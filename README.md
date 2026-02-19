# Duy Tran — Senior Game Engineer Portfolio

A Hugo-based portfolio website using the [Introduction theme](https://github.com/victoriadrake/hugo-theme-introduction), showcasing work on **Huli: Nine Tails of Vengeance** (UE 5.7 Action RPG) and 6 shipped mobile titles.

Live site: **https://peterduytran.github.io/**

## Quick Start

```bash
./dev.sh        # Start dev server at http://localhost:1313 (with drafts + live reload)
./build.sh      # Build for production → site/public/
./stop.sh       # Kill running Hugo server
```

Create new content:
```bash
./new-blog.sh post-title       # New blog post
./new-project.sh project-name  # New project page bundle
```

## Deployment

The site auto-deploys to GitHub Pages via GitHub Actions on every push to `main`.

- Workflow: `.github/workflows/deploy.yml`
- Live URL: `https://peterduytran.github.io/`
- Source: `PeterDuyTran/PeterDuyTran.github.io` repo, GitHub Actions source

### How it works
1. Pushes to `main` trigger the workflow
2. Hugo extended is installed (v0.155.3)
3. Node.js + PostCSS/autoprefixer are installed globally (required by the Introduction theme)
4. Site is built with `hugo --gc --minify` from the `site/` directory
5. Built output (`site/public/`) is uploaded and deployed to GitHub Pages

### First-time setup
1. Create repo named `{username}.github.io` on GitHub
2. Go to **Settings → Pages → Source → GitHub Actions**
3. Push code — first deploy happens automatically

## Directory Structure

```
portfolio/
├── .github/workflows/deploy.yml  # GitHub Actions deploy workflow
├── site/
│   ├── hugo.yaml                  # All site config (baseURL, theme, params)
│   ├── content/
│   │   ├── home/                  # About, contact sections + profile image
│   │   ├── projects/              # Page bundles per project (index.md + images)
│   │   └── blog/                  # Blog post markdown files
│   ├── assets/
│   │   ├── css/custom.css         # Custom styles (accent color, animations)
│   │   └── images/                # Hugo-processed images (author/, projects/, site/)
│   ├── static/images/             # Static images (copied as-is)
│   ├── layouts/
│   │   ├── index.html             # Custom SPA layout
│   │   └── partials/home/         # Tab content partials (projects, blog)
│   └── themes/introduction/       # Git submodule (victoriadrake/hugo-theme-introduction)
├── dev.sh / run-dev.sh            # Development server
├── build.sh                       # Production build
└── stop.sh                        # Kill Hugo server
```

## Editing Content

- **Personal info**: `site/hugo.yaml` (email, social links)
- **Bio/about text**: `site/content/home/about.md`
- **Projects**: `site/content/projects/{name}/index.md`
- **Blog posts**: `site/content/blog/{post}.md`
- **Custom styles**: `site/assets/css/custom.css`

## TODO

- [ ] Add Huli thumbnail image (`site/assets/images/projects/huli-thumb.png`)
- [ ] Add resume PDF (`site/static/files/resume.pdf`)
- [ ] Add avatar image (`site/assets/images/author/`)

## Troubleshooting

### PostCSS not found (GitHub Actions)
The Introduction theme requires PostCSS for CSS compilation. The workflow installs it globally before the Hugo build:
```yaml
- name: Install PostCSS
  run: npm install -g postcss postcss-cli autoprefixer
```
If this step is missing, Hugo will fail with: `binary with name "postcss" not found using npx`.

### Stale build artifacts
```bash
rm -rf site/public site/resources
./build.sh
```

### PDF export
Open the site in browser → `Ctrl+P` → Save as PDF. Print styles in `custom.css` automatically hide navigation and clean up typography.
