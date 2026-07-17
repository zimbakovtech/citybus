# Git workflow

How branches, merges and releases work in this repo. The model is a light
gitflow: two long-lived branches, short-lived topic branches, and a merge
strategy chosen per direction so history stays readable.

## Branches

```
main ────●───────────────●──────────────●──→   releasable, tagged
          \             / \            /
develop ───●──●──●──●──●───●──●──●──●─●───→   integration
               \    /          \   /
feat/fix ───────●──●            ●─●           short-lived topic branches
```

| Branch | Purpose | Branched from | Merges into | Lifetime |
|---|---|---|---|---|
| `main` | Always releasable. What gets graded/demoed/deployed. | — | — | permanent |
| `develop` | Integration branch; latest accepted work. | `main` | `main` | permanent |
| `feat/<slug>` | One feature. | `develop` | `develop` | until merged |
| `fix/<slug>` | One bug fix. | `develop` | `develop` | until merged |
| `chore/<slug>`, `docs/<slug>`, `refactor/<slug>` | Tooling, docs, restructuring. | `develop` | `develop` | until merged |
| `hotfix/<slug>` | Urgent fix for something broken on `main`. | `main` | `main` (then back into `develop`) | until merged |

Naming: lowercase kebab-case slug describing the change —
`feat/route-favorites`, `fix/planner-midnight-window`, `docs/erd-update`.
One topic per branch; if the scope grows, split it.

## Merge strategy

| Direction | Strategy | Why |
|---|---|---|
| `feat/*`, `fix/*`, `chore/*`, … → `develop` | **Squash merge** | One branch = one reviewable change = one commit on `develop`. WIP commits ("wip", "fix typo") never pollute history. |
| `develop` → `main` | **Merge commit** (`--no-ff`) | Preserves the individual squashed commits and marks an explicit release point that can be tagged. |
| `hotfix/*` → `main` | **Squash merge** | Same one-change-one-commit rule. |
| `main` → `develop` (after a hotfix) | **Merge commit** | Brings the hotfix back without rewriting it. |

Never merge `main` into topic branches; rebase topic branches onto `develop`
instead when they fall behind:

```bash
git fetch origin
git rebase origin/develop
```

## Commit messages

Conventional Commits on everything that lands in `develop`/`main`:

```
<type>(<scope>): <summary>        # e.g. fix(mobile): handle after-midnight departures
```

Types used here: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `ci`.
Scopes: `backend`, `mobile`, `db`, or omit when repo-wide. The squash commit
title must follow this format — it is what history keeps.

## Day-to-day flow

```bash
# start work
git switch develop && git pull
git switch -c feat/route-favorites

# ...commit freely on the branch (messy commits are fine, they get squashed)...

# stay current
git fetch origin && git rebase origin/develop

# open a PR to develop; fill in the PR template
# CI (.github/workflows/ci.yml) must be green before merging
# merge with "Squash and merge"; the squash title follows Conventional Commits

# release: PR develop -> main, merge with a merge commit, tag it
git switch main && git pull
git tag -a v1.1.0 -m "v1.1.0" && git push origin v1.1.0
```

## Rules

- `main` and `develop` are protected: no direct pushes, changes land via PR
  with green CI.
- Delete topic branches after merging.
- A PR should be small enough to review in one sitting; prefer several small
  PRs over one large one.
- Schema changes must keep `database/sql/` and the Alembic migration in sync
  (see the PR template checklist).
- Tags on `main` follow semver: `vMAJOR.MINOR.PATCH`.
