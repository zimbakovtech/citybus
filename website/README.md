# CityBus website

Public project website, served at **https://citybus.zimbakov.dev** via
GitHub Pages.

Built with Vite + React + TypeScript and Tailwind CSS 4. Fully static —
no runtime data fetching; screenshots are pre-compressed WebP copies of
[`docs/screenshots/`](../docs/screenshots).

## Development

```bash
npm install
npm run dev        # local dev server
npm run build      # type-check + static build into dist/
npm run preview    # serve the production build locally
```

## Deployment

[`.github/workflows/website.yml`](../.github/workflows/website.yml) builds
`dist/` and deploys it to GitHub Pages whenever a `v*.*.*` tag is pushed
(or manually via *workflow_dispatch*). The custom domain is set by
[`public/CNAME`](public/CNAME).
