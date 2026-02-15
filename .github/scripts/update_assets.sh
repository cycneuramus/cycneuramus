#!/bin/bash

set -euo pipefail

stats_endpoint="https://denvercoder1-github-readme-stats.vercel.app"
trophies_endpoints=(
	"https://github-profile-trophy.vercel.app"
	"https://github-profile-trophy-liard-delta.vercel.app"
	"https://github-profile-trophy-fork-two.vercel.app"
	"https://github-profile-trophy-winning.vercel.app"
	"https://github-profile-trophy-kannan.vercel.app"
	"https://trophy.ryglcloud.net"
	"https://github-profile-trophy-tawny.vercel.app"
)

declare -A trophies_paths=(
	["trophies-dark"]="?username=cycneuramus&no-bg=true&theme=gitdimmed&title=MultiLanguage,Stars,Commits,Experience,PullRequest,Repositories&rank=-B,-C,-?&column=-1"
	["trophies-light"]="?username=cycneuramus&no-bg=true&title=MultiLanguage,Stars,Commits,Experience,PullRequest,Repositories&rank=-B,-C,-?&column=-1"
)

declare -A stats_paths=(
	["nmgr-dark"]="api/pin/?username=cycneuramus&repo=nmgr&theme=github_dark"
	["nmgr-light"]="api/pin/?username=cycneuramus&repo=nmgr"
	["cloudflare-dns-failover-dark"]="api/pin/?username=cycneuramus&repo=cloudflare-dns-failover&theme=github_dark"
	["cloudflare-dns-failover-light"]="api/pin/?username=cycneuramus&repo=cloudflare-dns-failover"
	["deceptimeed-dark"]="api/pin/?username=cycneuramus&repo=deceptimeed&theme=github_dark"
	["deceptimeed-light"]="api/pin/?username=cycneuramus&repo=deceptimeed"
	["signal-aichat-dark"]="api/pin/?username=cycneuramus&repo=signal-aichat&theme=github_dark"
	["signal-aichat-light"]="api/pin/?username=cycneuramus&repo=signal-aichat"
	["homelab-dark"]="api/pin/?username=cycneuramus&repo=homelab&theme=github_dark"
	["homelab-light"]="api/pin/?username=cycneuramus&repo=homelab"
	["ansible-hybrid-cloud-dark"]="api/pin/?username=cycneuramus&repo=ansible-hybrid-cloud&theme=github_dark"
	["ansible-hybrid-cloud-light"]="api/pin/?username=cycneuramus&repo=ansible-hybrid-cloud"
	["immich-dark"]="api/pin/?username=immich-app&repo=immich&theme=github_dark&show_description=false"
	["immich-light"]="api/pin/?username=immich-app&repo=immich&show_description=false"
	["rclone-dark"]="api/pin/?username=rclone&repo=rclone&theme=github_dark&show_description=false"
	["rclone-light"]="api/pin/?username=rclone&repo=rclone&show_description=false"
	["seaweedfs-dark"]="api/pin/?username=seaweedfs&repo=seaweedfs&theme=github_dark&show_description=false"
	["seaweedfs-light"]="api/pin/?username=seaweedfs&repo=seaweedfs&show_description=false"
	["packages-dark"]="api/pin/?username=nim-lang&repo=packages&theme=github_dark&show_description=false"
	["packages-light"]="api/pin/?username=nim-lang&repo=packages&show_description=false"
	["redlib-dark"]="api/pin/?username=redlib-org&repo=redlib&theme=github_dark&show_description=false"
	["redlib-light"]="api/pin/?username=redlib-org&repo=redlib&show_description=false"
)

changed=false

update_asset() {
	local name="$1" url="$2"
	local path="assets/cards/${name}.svg"
	local tmp="${path}.tmp"

	curl --fail --silent --show-error --location "$url" -o "$tmp" || {
		rm -f "$tmp"
		return 1
	}

	grep -q "<svg" "$tmp" || {
		rm -f "$tmp"
		return 1
	}

	if [ ! -f "$path" ] || ! cmp -s "$path" "$tmp"; then
		mv "$tmp" "$path"
		git add "$path"
		changed=true
	else
		rm "$tmp"
	fi
}

for name in "${!trophies_paths[@]}"; do
	for endpoint in $(printf '%s\n' "${trophies_endpoints[@]}" | shuf); do
		if update_asset "$name" "${endpoint}/${trophies_paths[$name]}"; then
			echo "Fetched ${name} from ${endpoint}."
			continue 2
		fi

		echo "Failed to fetch ${name} from ${endpoint}, trying another endpoint."
	done

	echo "Failed to fetch ${name}: no working trophies endpoint."
done

for name in "${!stats_paths[@]}"; do
	if ! update_asset "$name" "${stats_endpoint}/${stats_paths[$name]}"; then
		echo "Failed to fetch ${name} from ${stats_endpoint}/${stats_paths[$name]}."
	fi
done

if [ "$changed" = false ]; then
	echo "No asset changes detected."
	exit 0
fi

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git commit -m "Update dynamic assets"
git push
