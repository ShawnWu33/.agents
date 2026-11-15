# ~/.agents

One set of instructions and skills for every coding agent: Claude Code, Codex, OpenCode and Pi.

```
~/.agents/
├── AGENTS.md          # global instructions every agent loads
├── skills/<name>/     # skills (one folder each, with SKILL.md)
├── install.sh         # links this folder into each agent
└── INSTALL_PROMPT.md  # paste into any agent to install for you
```

## Install

This folder must live at `~/.agents` (or be linked there), because Codex, OpenCode and Pi read
`~/.agents/skills` directly.

```sh
git clone <this-repo> ~/.agents   # or copy the folder there
~/.agents/install.sh --dry-run    # preview
~/.agents/install.sh
```

Or open any coding agent and paste the contents of [INSTALL_PROMPT.md](INSTALL_PROMPT.md).

The script only configures agents it finds (binary on `PATH` or config folder present); pass
`--all` to configure every supported agent anyway. It never overwrites an existing file: if, say,
`~/.codex/AGENTS.md` already holds your own rules, it reports a conflict. Merge that content into
`~/.agents/AGENTS.md`, then run with `--force` (the old file is kept as `*.bak.<timestamp>`).
Re-run it any time; it only changes what is missing.

## How each agent is wired

| Agent | Instructions | Skills |
|---|---|---|
| Claude Code | `~/.claude/CLAUDE.md` gets the line `@~/.agents/AGENTS.md` | symlink per skill in `~/.claude/skills/` |
| Codex | `~/.codex/AGENTS.md` → symlink | reads `~/.agents/skills` itself |
| OpenCode | `~/.config/opencode/AGENTS.md` → symlink | reads `~/.agents/skills` itself |
| Pi | `~/.pi/agent/AGENTS.md` → symlink | reads `~/.agents/skills` itself |

Custom locations are respected: `CLAUDE_CONFIG_DIR`, `CODEX_HOME`, `XDG_CONFIG_HOME`,
`PI_CODING_AGENT_DIR`.

Claude Code keeps its existing `CLAUDE.md` content; the script only appends the import line.
Claude-specific notes can go there, below the import.

## Day to day

- **Edit instructions:** change `~/.agents/AGENTS.md`. Every agent sees it in its next session.
- **Add a skill:** put it in `~/.agents/skills/<name>/SKILL.md`, then run `install.sh` so Claude
  Code gets its link. The other agents pick it up on their own.
- **Remove a skill:** delete its folder and run `install.sh`; it prunes the dead Claude link.
- **Refer to skills by name** in `AGENTS.md` (“use the `herdr` skill”), never by path: each agent
  finds skills in different folders.

## Notes

- OpenCode also reads `~/.claude/skills`, so it may see each skill twice (once per folder). Both
  point to the same files.
- Adding another agent: find where it reads global instructions and skills, then add a block to
  `install.sh` following the existing ones (link `AGENTS.md`; link skills only if it can't read
  `~/.agents/skills`).

## Included skills

- `herdr`: coordinate agents through Herdr's `hc` CLI. From
  [binbandit/bin-stack](https://github.com/binbandit/bin-stack/tree/main/skills/herdr). Codex
  also needs bin-stack's `codex/rules/herdr.rules` to run `hc` inside its sandbox.
- `orchestrate`: act as orchestrator for a multi-PR plan: split it into work pieces, fan them out
  to sub-agents over `hc` (one worktree and PR each), share the e2e slot, review, squash-merge in
  dependency order and report. Builds on `herdr`.
