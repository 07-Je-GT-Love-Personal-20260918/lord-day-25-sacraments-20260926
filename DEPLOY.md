# Deployment notes

This project is static and requires no build step.

## GitHub
Create a public repository under `07-Je-GT-Love-Personal-20260918`, then push the project root to `main`. The included `.github/workflows/pages.yml` deploys GitHub Pages.

## Vercel
Import the GitHub repository as a project. Framework preset: **Other**. Build command: leave empty. Output directory: `.`.

## Surge
From the project root after logging in with Surge:

```bash
npx surge . <your-site-name>.surge.sh
```

Do not commit GitHub PATs, Vercel tokens, Surge passwords, or Surge tokens into the repository.
