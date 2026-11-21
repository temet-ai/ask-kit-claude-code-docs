# ask-kit-claude-code-docs

An [ask-kit](https://github.com/temet-ai/ask-kit) kit that lets your coding agent's `ask` tool
answer questions about how Claude Code works: hooks, mods, plugins, skills, subagents, settings,
permissions, MCP, Code Mode, headless mode, the Agent SDK, and what changed in a release. A cheap
model reads a local copy of the official documentation and changelog outside your agent's context
and answers with the page, line and web address.

Questions from its bench, of the kind agents ask:

- Which hook event fires before a tool call in Claude Code, and can it block the call?
- In a Code Mode session, which features are unavailable, and can a PreToolUse hook see the code
  Claude runs?

## Install

You need [ask-kit](https://github.com/temet-ai/ask-kit#set-it-up), `bash` and `curl`.

Paste this into your agent:

```
Read ~/.config/ask-kit/AGENTS.md, then add this kit: github.com/temet-ai/ask-kit-claude-code-docs
```

Or run it yourself:

```sh
ask-kit kit install temet-ai/ask-kit-claude-code-docs        # shows what it reads and runs
ask-kit kit install temet-ai/ask-kit-claude-code-docs --yes  # installs, downloads the docs, enables it
```

Restart your agents so `ask` lists `claude-code-docs`.

Install runs `refresh.sh`, which downloads the documentation as Markdown from code.claude.com (the
pages its `llms.txt` lists) and the changelog from the anthropics/claude-code repository into
`copy/` in the kit. Run `bash refresh.sh` in the kit's folder to update it.

## Settings

| Setting | Default | What it is |
|---|---|---|
| `DOCS_DIR` | `copy/` in the kit | a copy of the docs you already keep |

Set it in the environment or in ask-kit's config as
`domains.claude-code-docs.settings.DOCS_DIR`.

## How well it works

The bench, `bench/questions.json`, holds real questions, each with patterns its answer must
match. `ask-kit kit test claude-code-docs` on 2026-11-18, two questions: deepseek-v4.1-flash 2/2
(median 16 s, $0.0020 for both).

## What is in it

`ask-kit.toml` (a folder source over the copy), `instructions.md` (how the copy is laid out and
how to cite a page) and `refresh.sh`. [RECIPE.md](RECIPE.md) says what it reads and runs, and how
to rebuild it.

The documentation is Anthropic's; this repository holds only the kit and the download script. The
kit is MIT licensed.
