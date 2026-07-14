# ChimeraOS workflow bundle

This bundle consolidates the workflows discussed for **ChimeraOS** / **Project Chimera 🐉** into one script.

## What is included
- dmux-style multi-branch git worktree setup with tmux panes
- branch sync flow against `main`
- pre-merge checks runner across worktrees
- merge-back flow into `main`
- Buildkite/ECR-style Docker build with BuildKit cache
- OCI image signing with cosign
- SPDX SBOM generation with Syft
- SBOM attachment with ORAS
- signature verification

## Main commands
```bash
chmod +x chimeraos_workflow_bundle.sh
./chimeraos_workflow_bundle.sh init-worktrees /path/to/repo
./chimeraos_workflow_bundle.sh sync-branches /path/to/repo
./chimeraos_workflow_bundle.sh premerge-checks /path/to/repo
./chimeraos_workflow_bundle.sh merge-back /path/to/repo
```

## Container supply-chain commands
```bash
export ECR_REPO=123456789.dkr.ecr.us-west-2.amazonaws.com/chimeraos
./chimeraos_workflow_bundle.sh build-image
./chimeraos_workflow_bundle.sh sign-image
./chimeraos_workflow_bundle.sh gen-sbom
./chimeraos_workflow_bundle.sh attach-sbom
./chimeraos_workflow_bundle.sh verify-signature
```

## Defaults baked into the script
Branches created by default:
- `chimeraos/dragon-auth`
- `chimeraos/dragon-ci`
- `chimeraos/dragon-sbom`

These are placeholders and should be adapted to your real internal task names.

## Notes
- The script uses `rebase` first during sync, then falls back to `merge` if rebase conflicts.
- `premerge-checks` tries common test commands opportunistically.
- Image signing is done by digest, not mutable tag.
- SBOM output is SPDX JSON.
- ORAS is used to attach SBOMs as OCI artifacts.

## Tooling expected
- git
- tmux
- docker buildx
- cosign
- syft
- oras
- optional: npm, pytest, make
