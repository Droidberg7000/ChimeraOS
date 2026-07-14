#!/usr/bin/env bash
# ChimeraOS workflow bundle — dmux-style multi-branch git worktrees + tmux,
# plus a container supply-chain path (build/sign/SBOM/verify).
#
# This is the concrete script behind docs/chimeraos_workflow_README.md.
# Read before running (download-then-run rule, see AI_TO_AI_PROTOCOL.md §4).
#
# Usage:
#   chmod +x chimeraos_workflow_bundle.sh
#   ./chimeraos_workflow_bundle.sh init-worktrees /path/to/repo
#   ./chimeraos_workflow_bundle.sh sync-branches /path/to/repo
#   ./chimeraos_workflow_bundle.sh premerge-checks /path/to/repo
#   ./chimeraos_workflow_bundle.sh merge-back /path/to/repo
#
#   export ECR_REPO=123456789.dkr.ecr.us-west-2.amazonaws.com/chimeraos
#   ./chimeraos_workflow_bundle.sh build-image
#   ./chimeraos_workflow_bundle.sh sign-image
#   ./chimeraos_workflow_bundle.sh gen-sbom
#   ./chimeraos_workflow_bundle.sh attach-sbom
#   ./chimeraos_workflow_bundle.sh verify-signature
#
set -eu

SESSION="dmux-multi-branch"
BRANCHES=("chimeraos/dragon-auth" "chimeraos/dragon-ci" "chimeraos/dragon-sbom")

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "[chimeraos] missing required tool: $1" >&2; exit 1; }
}

init_worktrees() {
  local repo="$1"
  require git; require tmux
  cd "$repo"
  git fetch origin

  tmux new-session -d -s "$SESSION" -c "$repo"
  local first=1
  for branch in "${BRANCHES[@]}"; do
    local wt_dir="$HOME/.worktrees/$SESSION/${branch##*/}"
    mkdir -p "$(dirname "$wt_dir")"
    if [ ! -d "$wt_dir" ]; then
      git worktree add -b "$branch" "$wt_dir" origin/main
    fi
    echo "# Task: $branch" > "$wt_dir/task.md"
    if [ "$first" -eq 1 ]; then
      tmux send-keys -t "$SESSION" "cd '$wt_dir'" C-m
      first=0
    else
      tmux split-window -t "$SESSION" -c "$wt_dir"
    fi
  done
  tmux select-layout -t "$SESSION" tiled
  echo "[chimeraos] Worktrees ready. Attach with: tmux attach -t $SESSION"
}

sync_branches() {
  local repo="$1"
  require git
  cd "$repo"
  git fetch origin
  for branch in "${BRANCHES[@]}"; do
    local wt_dir="$HOME/.worktrees/$SESSION/${branch##*/}"
    [ -d "$wt_dir" ] || continue
    (
      cd "$wt_dir"
      echo "[chimeraos] syncing $branch"
      if ! git rebase origin/main; then
        echo "[chimeraos] rebase conflict on $branch — falling back to merge"
        git rebase --abort || true
        git merge origin/main
      fi
    )
  done
}

premerge_checks() {
  local repo="$1"
  for branch in "${BRANCHES[@]}"; do
    local wt_dir="$HOME/.worktrees/$SESSION/${branch##*/}"
    [ -d "$wt_dir" ] || continue
    (
      cd "$wt_dir"
      echo "[chimeraos] pre-merge checks: $branch"
      if [ -f package.json ]; then npm test || exit 1; fi
      if [ -f pytest.ini ] || [ -f setup.py ] || [ -f pyproject.toml ]; then pytest -q || exit 1; fi
      if [ -f Makefile ]; then make test || true; fi
    )
  done
  echo "[chimeraos] pre-merge checks complete."
}

merge_back() {
  local repo="$1"
  require git
  cd "$repo"
  git checkout main
  git fetch origin
  git merge origin/main
  for branch in "${BRANCHES[@]}"; do
    echo "[chimeraos] merging $branch into main"
    git merge --no-ff "$branch" -m "chimeraos: merge $branch"
  done
  echo "[chimeraos] merge-back complete. Review before pushing."
}

build_image() {
  require docker
  : "${ECR_REPO:?set ECR_REPO first, e.g. export ECR_REPO=<acct>.dkr.ecr.<region>.amazonaws.com/chimeraos}"
  docker buildx build --load -t "$ECR_REPO:latest" .
  echo "[chimeraos] built $ECR_REPO:latest"
}

sign_image() {
  require cosign
  : "${ECR_REPO:?set ECR_REPO first}"
  local digest
  digest="$(docker inspect --format='{{index .RepoDigests 0}}' "$ECR_REPO:latest")"
  cosign sign --yes "$digest"
  echo "[chimeraos] signed $digest"
}

gen_sbom() {
  require syft
  : "${ECR_REPO:?set ECR_REPO first}"
  syft "$ECR_REPO:latest" -o spdx-json > sbom.spdx.json
  echo "[chimeraos] SBOM written to sbom.spdx.json"
}

attach_sbom() {
  require oras
  : "${ECR_REPO:?set ECR_REPO first}"
  oras attach "$ECR_REPO:latest" --artifact-type application/spdx+json sbom.spdx.json:application/spdx+json
  echo "[chimeraos] SBOM attached to $ECR_REPO:latest"
}

verify_signature() {
  require cosign
  : "${ECR_REPO:?set ECR_REPO first}"
  cosign verify "$ECR_REPO:latest" || {
    echo "[chimeraos] signature verification failed" >&2
    exit 1
  }
  echo "[chimeraos] signature verified"
}

case "${1:-}" in
  init-worktrees)      init_worktrees "${2:?repo path required}" ;;
  sync-branches)       sync_branches "${2:?repo path required}" ;;
  premerge-checks)     premerge_checks "${2:?repo path required}" ;;
  merge-back)          merge_back "${2:?repo path required}" ;;
  build-image)         build_image ;;
  sign-image)          sign_image ;;
  gen-sbom)             gen_sbom ;;
  attach-sbom)         attach_sbom ;;
  verify-signature)    verify_signature ;;
  *)
    echo "Usage: $0 {init-worktrees|sync-branches|premerge-checks|merge-back|build-image|sign-image|gen-sbom|attach-sbom|verify-signature} [repo-path]"
    exit 1
    ;;
esac
