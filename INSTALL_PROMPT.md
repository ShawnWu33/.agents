# Install prompt

Paste everything below the line into any coding agent (Claude Code, Codex, OpenCode, Pi, ...).

---

Set up my shared agent configuration from `~/.agents` on this machine.

1. Read `~/.agents/README.md` and `~/.agents/install.sh` so you know what will change.
   If `~/.agents` doesn't exist, ask me where the folder is (or which repo to clone) before going on.
2. Run `~/.agents/install.sh --dry-run` and show me the output.
3. If it reports a CONFLICT (an agent already has its own global instructions file), show me
   that file and propose how to merge its content into `~/.agents/AGENTS.md`. Only after I agree,
   merge it and re-run with `--force`. Never delete my existing content.
4. Run `~/.agents/install.sh` for real.
5. Verify, and show me the evidence:
   - `ls -la` each link the script reported.
   - For each installed agent, start a fresh non-interactive session from a folder outside
     `~/.agents` and ask it to list the skills it can see and quote the first heading of its
     global instructions. Use read-only flags where the agent has them.
6. If I use a coding agent the script doesn't cover, look up in its official docs where it reads
   global instructions and skills, add a block to `install.sh` matching the existing ones, run it
   again, and update the table in `README.md`.

Finish with a short summary of which agents are wired up and anything that still needs me.
