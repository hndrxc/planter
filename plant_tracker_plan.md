# Plant care tracker — project plan

A Flutter app that tracks watering schedules for houseplants. Each plant is drawn
with a `CustomPainter` whose droop and color are a function of how overdue it is,
so the artwork wilts continuously rather than switching between fixed images.

**Stack:** Flutter, Dart, `shared_preferences` for persistence, `provider` for
state. No network, no native plugins, no auth.

**Board setup:** one Trello list per milestone, plus standing lists for `Backlog`,
`In progress`, `Blocked`, and `Done`. Labels: `model`, `ui`, `paint`, `persistence`,
`polish`, `writeup`.

---

## Milestone 1 — Data model and persistence

The foundation. Nothing is drawn yet; the goal is a plant that survives an app
restart.

**Exit criteria:** add a plant in code, hot-restart, and it's still there.

| Card | Detail |
| --- | --- |
| Scaffold the project | `flutter create`, set up folder structure (`models/`, `state/`, `widgets/`, `screens/`), commit. |
| Write the `Plant` model | Fields: `id`, `name`, `species`, `waterEveryDays`, `lastWatered`, `history`. Add `copyWith`. |
| Add `toJson` / `fromJson` | Encode `DateTime` as ISO-8601 strings. Handle a missing or malformed field without throwing. |
| Build `PlantRepository` | Load and save a `List<Plant>` as a single JSON string in `shared_preferences`. |
| Write unit tests for round-tripping | Serialize a plant, deserialize it, assert every field matches. Include an empty-list case. |
| Seed demo data | Three or four plants at different stages so the UI has something to show from day one. |

---

## Milestone 2 — Core screens and state

The app becomes usable. Still no custom artwork — use a placeholder icon.

**Exit criteria:** you can add, edit, water, and delete a plant entirely through
the UI, and the changes persist.

| Card | Detail |
| --- | --- |
| Set up `PlantStore` (`ChangeNotifier`) | Holds the list, exposes `add`, `update`, `remove`, `water`. Notifies listeners and writes through to the repository. |
| Home screen list | `ListView.builder` of plant rows: name, species, days-until-due text. |
| Sort by urgency | Most overdue first. Pure function on the list so it can be unit tested. |
| Add / edit form screen | Name, species, interval stepper, last-watered date picker. Validate that name is non-empty and interval is at least 1. |
| Water button | One tap sets `lastWatered` to now and appends to `history`. Show a snackbar with undo. |
| Delete with confirmation | Swipe-to-dismiss plus an "are you sure" dialog. |
| Detail screen | Full watering history as a list, plus edit and delete actions. |
| Empty state | "No plants yet" with a button that opens the add form. |

---

## Milestone 3 — The painter

**Status: Complete (September 3, 2026).**

The distinctive part, and the thing worth demoing.

**Exit criteria:** a slider in a debug screen drags `health` from 1.0 to 0.0 and
the plant visibly wilts, with no snapping or clipping.

| Card | Detail |
| --- | --- |
| Compute health from schedule | `healthFromSchedule` maps days overdue to a 0–1 value with a grace window. Unit test the boundaries: due today, one day over, fully lapsed. |
| Draw the static pot | Trapezoid body, rim, soil ellipse. All coordinates relative to `size` so it scales. |
| Draw the stem | Quadratic Bezier from soil to top. Length and lean both driven by health. |
| Draw one leaf | Two-Bezier teardrop from a base point along a direction vector. Get one right before adding the rest. |
| Sample leaf attachment points | De Casteljau along the stem curve so leaves follow the lean instead of floating. |
| Interpolate droop angle | Each leaf has a healthy angle and a wilted angle; lerp between them by health. |
| Color ramp | Green → yellow → brown across the health range, with alternating leaves shaded slightly apart. |
| Shed leaves at low health | Skip odd-indexed leaves below a threshold and draw one on the ground beside the pot. |
| Wrap in `TweenAnimationBuilder` | Health changes animate over ~600ms with `Curves.easeOutCubic` instead of jumping. |
| Debug slider screen | Dev-only route with a slider bound to health. This is what you use to demo. |
| Swap into the list and detail screens | Replace the placeholder icon. Small size in rows, large on the detail page. |

---

## Milestone 4 — Derived data and stats

**Status: Complete (September 4, 2026).**

Turns a list app into something that computes.

**Exit criteria:** a stats screen that shows numbers the user never typed in.

| Card | Detail |
| --- | --- |
| Due-today section | Group the home list into "needs water" and "all good" headers. |
| Streak / reliability metric | Percentage of waterings that happened on or before the due date, per plant. |
| Watering heatmap | Last eight weeks as a grid of squares, shaded by how many plants were watered that day. `GridView` or a second `CustomPainter`. |
| Stats screen | Total plants, number overdue, waterings this month, thirstiest plant. |
| Unit tests for aggregation | Feed a fixed history and assert the computed numbers. No widgets involved. |

---

## Milestone 5 — Polish and submission

**Status: Complete (September 4, 2026).**

Cut freely from here if you run short on time. Nothing in this list is load-bearing.

| Card | Detail |
| --- | --- |
| Per-plant pot color | Store a color index on the model, pass it into the painter. |
| Theme pass | Muted palette, consistent spacing scale, dark mode check. |
| Notes field | Free-text notes on the detail screen. |
| Accessibility pass | Semantic labels on the plant artwork, verify tap targets are at least 48dp. |
| README with screenshots | Include a shot of the same plant at four health values side by side. |
| Demo script | Set a plant's last-watered date back two weeks live, show the wilt animation run. |
| Writeup | Architecture, why health is derived rather than stored, what you'd do with more time. |

---

## Sequencing notes

Milestones 1 and 2 are strictly ordered — the store needs the model, the screens
need the store. Milestone 3 depends only on `healthFromSchedule`, so if you're
working with a partner, one person can build the painter against a hardcoded
slider while the other finishes the CRUD screens. Milestone 4 needs real history
data, so do it last of the substantive work.

The highest-risk card is "interpolate droop angle" — it's the one where the math
can look wrong in ways that are hard to debug. Build the debug slider screen
before you need it, not after.
