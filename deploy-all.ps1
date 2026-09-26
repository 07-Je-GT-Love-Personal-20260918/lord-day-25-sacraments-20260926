param(
  [string]$Repo = "lord-day-25-sacraments-20260926",
  [string]$Org = "07-Je-GT-Love-Personal-20260918",
  [string]$SurgeDomain = "lord-day-25-sacraments-20260926.surge.sh"
)
$ErrorActionPreference = "Stop"
if (-not $env:GITHUB_TOKEN) { throw "请先设置环境变量 GITHUB_TOKEN，不要把 PAT 写进脚本。" }

$headers = @{
  Authorization = "Bearer $($env:GITHUB_TOKEN)"
  Accept = "application/vnd.github+json"
  "X-GitHub-Api-Version" = "2022-11-28"
}
$body = @{name=$Repo; private=$false; description="海德堡要理问答主日25：神赐下圣礼，为要坚固我们软弱的信心"} | ConvertTo-Json
try {
  Invoke-RestMethod -Method Post -Uri "https://api.github.com/orgs/$Org/repos" -Headers $headers -Body $body -ContentType "application/json" | Out-Null
  Write-Host "GitHub repository created."
} catch {
  if ($_.Exception.Response.StatusCode.value__ -ne 422) { throw }
  Write-Host "Repository may already exist; continuing."
}

git init
git branch -M main
git add .
try { git commit -m "Publish Lord's Day 25 sacrament study site" } catch { Write-Host "Nothing new to commit." }
git remote remove origin 2>$null
git remote add origin "https://github.com/$Org/$Repo.git"
git -c "http.extraHeader=AUTHORIZATION: bearer $($env:GITHUB_TOKEN)" push -u origin main

$pagesBody = @{build_type="workflow"} | ConvertTo-Json
try { Invoke-RestMethod -Method Post -Uri "https://api.github.com/repos/$Org/$Repo/pages" -Headers $headers -Body $pagesBody -ContentType "application/json" | Out-Null } catch { Write-Host "GitHub Pages may already be enabled; workflow will attempt deployment." }
Write-Host "GitHub Pages expected URL: https://$($Org.ToLower()).github.io/$Repo/"

if ($env:VERCEL_TOKEN) { npx vercel@latest --prod --yes --token $env:VERCEL_TOKEN } else { npx vercel@latest --prod --yes }
if ($env:SURGE_TOKEN) { npx surge . $SurgeDomain --token $env:SURGE_TOKEN } else { Write-Host "SURGE_TOKEN 未设置；请先运行 npx surge login，再执行：npx surge . $SurgeDomain" }
