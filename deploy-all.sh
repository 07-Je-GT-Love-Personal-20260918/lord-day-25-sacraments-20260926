#!/usr/bin/env bash
set -euo pipefail
ORG="${ORG:-07-Je-GT-Love-Personal-20260918}"
REPO="${REPO:-lord-day-25-sacraments-20260926}"
SURGE_DOMAIN="${SURGE_DOMAIN:-lord-day-25-sacraments-20260926.surge.sh}"
: "${GITHUB_TOKEN:?Set GITHUB_TOKEN first; never hard-code a PAT in this script.}"

curl -fsS -X POST "https://api.github.com/orgs/$ORG/repos" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "{\"name\":\"$REPO\",\"private\":false,\"description\":\"Heidelberg Catechism Lord's Day 25 study site\"}" || true

git init
git branch -M main
git add .
git commit -m "Publish Lord's Day 25 sacrament study site" || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/$ORG/$REPO.git"
git -c "http.extraHeader=AUTHORIZATION: bearer $GITHUB_TOKEN" push -u origin main

curl -fsS -X POST "https://api.github.com/repos/$ORG/$REPO/pages" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d '{"build_type":"workflow"}' || true

echo "GitHub Pages expected URL: https://${ORG,,}.github.io/$REPO/"
if [[ -n "${VERCEL_TOKEN:-}" ]]; then npx vercel@latest --prod --yes --token "$VERCEL_TOKEN"; else npx vercel@latest --prod --yes; fi
if [[ -n "${SURGE_TOKEN:-}" ]]; then npx surge . "$SURGE_DOMAIN" --token "$SURGE_TOKEN"; else echo "Set SURGE_TOKEN or run: npx surge login && npx surge . $SURGE_DOMAIN"; fi
