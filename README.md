# openclaw-skylight

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![OpenClaw skill](https://img.shields.io/badge/OpenClaw-skill-7c3aed)

> Part of a three-repo set: [`pyskylight`](https://github.com/joshuaswarren/pyskylight)
> (client + CLI) · **openclaw-skylight** (this) ·
> [`plantoeat-skylight-sync`](https://github.com/joshuaswarren/plantoeat-skylight-sync) (meal-plan sync).

An [OpenClaw](https://openclaw.ai/) **skill** that lets your OpenClaw agents read and
manage a [Skylight Calendar](https://www.skylightframe.com/) / Buddy household —
calendar events, family chores/lists, and especially **Meals** (recipes + the meal
plan) — by driving the open-source [`pyskylight`](https://github.com/joshuaswarren/pyskylight)
CLI.

Skylight has no official API; this builds on the community-reverse-engineered private
app API. **Personal use, your own account only.**

## What it is

A single `SKILL.md` (plus this README and an installer). OpenClaw reads `SKILL.md` and
learns how to call the `skylight` CLI. No long-running process, no gateway restart —
it's a drop-in skill.

## Install

```bash
git clone https://github.com/joshuaswarren/openclaw-skylight
cd openclaw-skylight
./install.sh
```

`install.sh` will:

1. Install the `skylight` CLI (`pipx install pyskylight`, falling back to `pip --user`).
2. Copy `SKILL.md` into `~/.openclaw/skills/skylight/` (override with `OPENCLAW_SKILLS_DIR`).

Then make credentials available to the OpenClaw environment (1Password references
recommended):

```bash
export SKYLIGHT_EMAIL="op://Shared/Skylight/username"
export SKYLIGHT_PASSWORD="op://Shared/Skylight/password"
export SKYLIGHT_FRAME_ID="…"        # optional
export SKYLIGHT_TIMEZONE="America/Chicago"
```

## Usage

Ask your agent things like *"what meals are planned this week on the Skylight?"* or
*"add tacos to the Skylight meal plan for Friday dinner."* The agent runs the
`skylight` CLI and parses the JSON output. See [`SKILL.md`](SKILL.md) for the full
command surface.

## Related

- [`pyskylight`](https://github.com/joshuaswarren/pyskylight) — the client + CLI this skill wraps.
- [`plantoeat-skylight-sync`](https://github.com/joshuaswarren/plantoeat-skylight-sync) — scheduled Plan to Eat → Skylight meal-plan sync.

## License

[MIT](LICENSE). Unofficial; not affiliated with or endorsed by Skylight or OpenClaw.
