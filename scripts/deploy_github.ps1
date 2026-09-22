# One-click GitHub push + Pages live after `gh auth login`
# Usage: powershell -ExecutionPolicy Bypass -File scripts/deploy_github.ps1 -Username YOUR_GITHUB_USERNAME -Repo messenger
param(
  [string]$Username = "",
  [string]$Repo = "messenger",
  [string]$Branch = "master"
)

$ErrorActionPreference = "Stop"

# Ensure gh logged in
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
try { gh auth status 2>&1 | Out-Null } catch { }
if ($LASTEXITCODE -ne 0) {
  Write-Host "`n[!] gh not logged in. Run ONE of:" -ForegroundColor Yellow
  Write-Host "    gh auth login --web  # opens browser, paste device code from https://github.com/login/device"
  Write-Host "    # or:  echo YOUR_PAT | gh auth login --with-token"
  exit 1
}

if (-not $Username) {
  $u = gh api user --jq .login 2>$null
  if ($u) { $Username = $u.Trim() }
}
if (-not $Username) { Write-Host "Provide -Username <github_login>" -ForegroundColor Red; exit 1 }

$remoteUrl = "https://github.com/$Username/$Repo.git"
$exists = git remote 2>$null | Select-String "origin"
if (-not $exists) {
  git remote add origin $remoteUrl
  Write-Host "Added remote origin -> $remoteUrl" -ForegroundColor Green
} else {
  git remote set-url origin $remoteUrl
  Write-Host "Updated origin -> $remoteUrl" -ForegroundColor Cyan
}

# Ensure branch name
git branch -M $Branch

# Check if GitHub repo exists, create if not
$repoExists = gh repo view "$Username/$Repo" 2>$null; 
if ($LASTEXITCODE -ne 0) {
  Write-Host "Creating GitHub repo $Username/$Repo (public)..." -ForegroundColor Cyan
  gh repo create "$Username/$Repo" --public --source=. --remote=origin --push 2>&1 | Write-Host
  # gh repo create already pushes; ensure tags
  git push --tags
} else {
  Write-Host "Repo exists. Pushing $Branch + tags..." -ForegroundColor Cyan
  git push -u origin $Branch
  git push --tags
}

Write-Host "`n✅ Pushed to https://github.com/$Username/$Repo" -ForegroundColor Green
Write-Host "Next (one-time GitHub UI):" -ForegroundColor Yellow
Write-Host "  1. GitHub repo -> Settings -> Pages -> Build and deployment -> Source: GitHub Actions"
Write-Host "  2. Settings -> Secrets and variables -> Actions -> New secret:"
Write-Host "       SUPABASE_URL = https://YOUR_PROJECT.supabase.co"
Write-Host "       SUPABASE_ANON_KEY = eyJ..."
Write-Host "     (optional TURN_* - defaults to openrelay.metered.ca)"
Write-Host "  3. Push triggers deploy: git push origin $Branch  -> Actions tab shows 'Deploy Messenger Web' -> green check"
Write-Host "  4. Live URL: https://$Username.github.io/$Repo/"
Write-Host "     Hard-refresh /home to test SPA 404 fallback (workflow copies index.html->404.html)"
Write-Host "`nLocal preview: npx serve build/web  (already built with --base-href /$Repo/ )`n"
