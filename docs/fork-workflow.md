# Fork workflow

`keyframe-one/seahelm` is a fork of `BetaYao/seahelm`. Remotes: `origin` = the fork, `upstream` = BetaYao (read-only — never push there).

Every change belongs to exactly one of three lanes. Pick the lane *before* starting the work, because it decides which branch the work is cut from.

## Lane A — mine only

Changes that encode personal taste and would not be accepted (or wanted) upstream: UI behaviour tuned to how I work, defaults, shortcuts, anything opinionated.

Examples: the island opening only on click, fixed pill width, no auto-expand.

- **Branch:** `mine/<topic>`, cut from `main` (the fork's).
- **Commit trailer:** `Fork-Only: yes` — so a later cherry-pick spree can't sweep it upstream by mistake.
- **Lands in:** the fork's `main` only.
- **Never:** cherry-picked into a branch that becomes an upstream PR.

## Lane B — fixes for the original repo

Bugs and features that help everyone using Seahelm.

Examples: close-pane fixes (PR #123), drag-and-drop files onto a pane (PR #126), hiding worktrees whose folder is gone.

1. `git fetch upstream`
2. Cut the branch from **upstream**, not from the fork: `git worktree add <tmp> -b pr/<topic> upstream/main`
   A temp worktree keeps the main checkout on the fork's `main`, so the running app never gets built from a branch missing the fork's own fixes.
   The worktree needs `GhosttyKit.xcframework` symlinked in from the main checkout, and `git worktree remove` it when the PR is up.
3. Apply only the commits for this fix (`git cherry-pick <sha>`), then `xcodegen generate` and amend if the project file changed.
4. Build and run the relevant tests in that worktree.
5. `git push -u origin pr/<topic>` and `gh pr create --repo BetaYao/seahelm --base main --head keyframe-one:pr/<topic>`.
6. The same work lands in the fork's `main` too — either merged there directly, or picked up when upstream merges and the fork syncs.

**Check before opening a PR:** the branch must contain nothing from Lane A, and `CLAUDE.md` edits must stay upstream-neutral (no fork-only policy in it — that belongs in this file).

## Lane C — his updates coming in

- **Weekly:** a cloud routine (Mondays, 9am Melbourne) lists new upstream commits as take / review / skip. It only reports.
- **On request or after the report:**
  1. `git fetch upstream && git merge upstream/main` on the fork's `main`
  2. `xcodegen generate` (the project file is generated; regenerate rather than resolve it by hand)
  3. Full unit suite, UI tests skipped: `xcodebuild -project seahelm.xcodeproj -scheme seahelmTests -configuration Debug -skipPackagePluginValidation -skipMacroValidation CODE_SIGN_IDENTITY="-" DEVELOPMENT_TEAM="" test -skip-testing:seahelmUITests`
  4. Push, and restart the app when convenient.
- **Conflicts:** expect them where Lane A changed things (the island above all). Keep the fork's behaviour, take his fix underneath it.
- **His test breakages** are fixed in the fork and can go back as a Lane B PR.

## When the lane is unclear

Default to Lane B. If the change only makes sense for how I work, it is Lane A. Ask rather than guess when it is genuinely both — the usual split is: the mechanism goes upstream, the preference stays here.

## Build notes

- Headless builds need `CODE_SIGN_IDENTITY="-" DEVELOPMENT_TEAM=""` (no Developer ID cert locally; `run.sh` does this already).
- Building from a branch that lacks the fork's own fixes and then restarting the app brings old bugs back — that is what the temp worktree in Lane B prevents.
- Auto-update still points at BetaYao's releases (`UpdateCoordinator.repositoryOwner`). Change it before shipping any release build of the fork.
