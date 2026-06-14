---
name: skylight
description: Read and manage a Skylight Calendar / Buddy household via the `skylight` CLI — calendar events, family profiles/categories, chores, lists, Meals (recipes + meal plan), rewards, photos/albums, Buddy devices & alarms, household members, routines, and the AI Sidekick. Use when asked to view, add, or change anything on the Skylight.
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

If a command returns `{"ok": false, "type": "SkylightPlusRequiredError", ...}`, that
endpoint needs an active **Skylight Plus** subscription (mostly the `/plus/*` status
and a couple of AI features; Meals/rewards/albums generally work without it).

The CLI covers nearly the whole private API (~145 commands). This skill shows the common
flows; run `skylight --help` or `skylight <command> --help` to discover the rest.

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
skylight lists                                     # then: list-show <id>, list-items <id>
skylight chores
skylight rewards                                   # reward-points shows balances
skylight devices                                   # then: alarms --device-id <id>  (Buddy alarms)
skylight messages                                  # photos/messages; albums for albums
skylight members                                   # household members
```

## Writing — calendar

```bash
skylight event-add --summary "Soccer" --starts-at 2026-06-21T17:00:00 --ends-at 2026-06-21T18:00:00 --tz America/Chicago --category-id <id>
skylight event-update <event_id> --summary "Soccer Practice"
skylight event-delete <event_id>
skylight webcal-add --sync-url "webcal://…"         # subscribe an ICS feed
skylight calendar-link --redirect-url … --failure-redirect-url …   # OAuth URL to connect Google
```

## Writing — meals

```bash
# Create / update / delete a recipe:
skylight create-recipe --summary "Sheet-pan chicken" --description "Weeknight staple" --meal-category-id <id>
skylight update-recipe <recipe_id> --description "…"
skylight delete-recipe <recipe_id>
skylight grocery-add <recipe_id>                   # push its ingredients to the grocery list

# Plan a meal (a "sitting" links a date + meal category + optional recipe):
skylight plan-add --date 2026-06-20 --meal-category-id <dinner_id> --recipe-id <recipe_id>
skylight plan-update <sitting_id> --recipe-id <recipe_id>
skylight plan-remove <sitting_id> --date 2026-06-20   # removes the instance on that date
```

## Writing — chores, lists, categories, rewards

```bash
skylight chore-add --summary "Take out trash" --category-id <profile_id> --reward-points 5
skylight chore-complete <chore_id>                 # add --instance-date for a recurring one
skylight list-create --label "Groceries" --kind shopping
skylight list-add <list_id> --label "Milk"         # then list-item-complete <list_id> <item_id>
skylight category-add --label "Anna" --color "#5DB671"
skylight reward-add --name "Movie night" --point-value 50 --category-id <profile_id>
skylight reward-redeem <reward_id>
```

## Devices, photos, AI

```bash
skylight alarms --device-id <id>                   # Buddy alarms; alarm-add/-update/-delete take --json
skylight photo-upload --file ./pic.jpg --caption "Hi"
skylight ai-intent-create --type meal_plan --json '{"prompt":"a week of easy dinners"}'
```

Some reverse-engineered write endpoints (device/alarm/member updates, source-calendar
create/update, household config, AI prompts) take a `--json '{...}'` body; see
`skylight <command> --help`. Account-level/billing actions are intentionally not exposed.

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
