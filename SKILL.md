---
name: skylight
description: Read and manage a Skylight Calendar / Buddy household via the `skylight` CLI — calendar events, family profiles, chores, lists, and especially Meals (recipes + the meal plan). Use when asked to view, add, or change anything on the Skylight, list/create recipes, or plan meals.
---

# Skylight

Drive a [Skylight Calendar](https://www.skylightframe.com/) / Buddy household from the
shell using the `skylight` CLI (the open-source `pyskylight` package). Every command
prints JSON, so parse stdout.

Skylight has **no official API**; this uses the reverse-engineered private app API.
Personal use, the household's own account only.

## Prerequisites

The `skylight` CLI must be installed and credentials available in the environment:

```bash
command -v skylight || pipx install git+https://github.com/joshuaswarren/pyskylight

# Credentials — prefer 1Password references so secrets stay out of the environment:
export SKYLIGHT_EMAIL="op://Shared/Skylight/username"
export SKYLIGHT_PASSWORD="op://Shared/Skylight/password"
export SKYLIGHT_FRAME_ID="…"          # optional; avoids passing --frame each time
export SKYLIGHT_TIMEZONE="America/Chicago"
```

If a command returns `{"ok": false, "type": "SkylightPlusRequiredError", ...}`, the
Meals/Recipes features need an active **Skylight Plus** subscription.

## First run

```bash
skylight login        # caches the session token; shows user_id + is_plus
skylight frames       # find the household (frame) id -> set SKYLIGHT_FRAME_ID
```

The token is cached; you do not need to `login` before every command. On an expired
token the CLI re-authenticates automatically if the env credentials are set.

## Reading

```bash
skylight whoami
skylight frames
skylight categories                      # family-member profiles / colors
skylight events --from 2026-06-13T00:00:00 --to 2026-06-20T00:00:00 --tz America/Chicago
skylight meal-categories                 # Breakfast/Lunch/Dinner ids
skylight recipes                         # all recipes
skylight recipe <recipe_id>
skylight plan --from 2026-06-13 --to 2026-06-27   # planned meals (sittings)
skylight lists
skylight chores
```

## Writing (meals)

```bash
# Create a recipe (returns the new recipe object incl. its id):
skylight create-recipe --summary "Sheet-pan chicken" --description "Weeknight staple" --meal-category-id <id>

# Plan a meal on a date (a "sitting" links a date + meal category + optional recipe):
skylight plan-add --date 2026-06-20 --meal-category-id <dinner_id> --recipe-id <recipe_id>

# Remove a recipe:
skylight delete-recipe <recipe_id>
```

Calendar events can also be created/edited via the library; the CLI exposes reads
(`events`) plus meal writes. For richer calendar mutation use `pyskylight` directly.

## Working pattern

1. Resolve the `frame_id` once (`skylight frames`) and the meal-category ids
   (`skylight meal-categories`).
2. To add a planned meal: ensure the recipe exists (`recipes`, else `create-recipe`),
   then `plan-add` with that recipe id on the target date + meal category.
3. Treat every command's stdout as JSON. On `{"ok": false, ...}` read `.error`/`.type`
   and report it; do not retry blindly.

## Safety

- Writes change the family's real calendar/meal plan. Confirm intent before bulk
  changes or deletions, and prefer additive operations.
- The API is unofficial and can change without notice. Never log or echo credentials
  or the session token.
- For automated Plan to Eat → Skylight meal-plan syncing, use the dedicated
  `plantoeat-skylight-sync` tool rather than scripting this skill in a cron loop.
