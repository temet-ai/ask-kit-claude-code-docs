# Recipe: claude-code-docs kit

## What it answers

How Claude Code itself behaves and is configured, from its official documentation: hooks, mods,
plugins, skills, subagents, settings, permissions, MCP, Code Mode, headless mode, the Agent SDK,
models and effort, and what changed in which release.

## What it needs

`bash` and `curl` for `refresh.sh` (the install step), network access to code.claude.com and
raw.githubusercontent.com once per refresh.

## What it reads and runs

- `refresh.sh` at install: downloads `llms.txt`, every page it lists and `CHANGELOG.md` into
  `copy/`, keeping the old copy if fewer than 90% of pages arrive.
- At question time: ask-kit's folder source over `copy/` (or `DOCS_DIR`): ripgrep and reads.

## Rebuild it from an empty folder

`ask-kit.toml` with a `DOCS_DIR` setting defaulting to `${KIT_DIR}/copy`, one folder source over
it, `[[build]] command = ["bash", "refresh.sh"]`, and `instructions.md` that maps topics to pages,
says to read `FETCHED.txt` for the copy's date, find the page with `find` or `llms.txt`, read
only the section with `outline` then `read`, and never answer from memory.

## Bench

`bench/questions.json`: questions of the kind agents ask about Claude Code.

## Results

ask-kit `kit test` on 2026-11-18: deepseek-v4.1-flash 2/2 (median 16 s, $0.0020).
