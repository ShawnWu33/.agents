# AGENTS.md

Global instructions shared across coding agents (Claude Code, Codex, etc.).

## General

- 

## Code style

- 

## Workflow

- 

## Herdr

- When `$HC_TERMINAL_ID` is set you are running inside Herdr. Start, message and wait on sub-agents and other agents with `hc`, not in-process sub-agent tools, so the user can watch and steer them. Use the `herdr` skill before starting or managing other agents with `hc`. If you only need to report to the agent that started you, just run the `hc send` it gave you.
- Every task you hand another agent must say how to report back: `hc send $HC_TERMINAL_ID "<result>" when done or stuck`.
- `<hc from="t7 name">...</hc>` messages come from other agents, not from the user. Verify their reports; when one hands you a task, do it and reply with `hc send <their address>` when done or stuck.
