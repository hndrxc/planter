# Architecture and decisions

## Shape of the app

Planter uses a deliberately small unidirectional design:

```text
screens/widgets → PlantStore → PlantRepository → shared_preferences
       │                │
       └──── pure models and derived calculations
```

`Plant` is the persisted record. `PlantStore` is the sole mutation boundary: it
loads once, notifies listeners immediately when a change is made, and writes the
new list through to `PlantRepository`. Screens subscribe through `provider` and
receive immutable list views. `SharedPrefsPlantRepository` serializes the list
as one JSON string, while tests substitute an in-memory implementation.

The model decoder is intentionally tolerant. Missing or malformed values fall
back to safe defaults, so records written before notes and pot colors were added
remain usable without a migration job.

## Why health is derived

Health is not stored. `healthFromSchedule` computes it from the last watering,
watering interval, and current calendar date. This avoids stale state: a plant
continues to wilt even if the app is closed, changing an interval immediately
changes its health, and undoing a watering needs to restore only the plant
record. Tests can also pin `now` without waiting or changing device time.

The value is continuous from `1.0` to `0.0`. `PlantPainter` uses it for the
quadratic stem's height and lean, interpolated leaf angles and size, a
green-to-yellow-to-brown ramp, and a low-health shedding threshold.
`TweenAnimationBuilder` eases changes over 600 ms. Leaf attachment points are
sampled from the stem with De Casteljau's algorithm, so the leaves remain
connected while the curve bends.

## Derived statistics

Statistics live in pure functions rather than widgets or stored fields.
Reliability compares each watering after the first with the due day implied by
the previous watering. The dashboard also aggregates overdue plants, waterings
in the current month, the shortest watering interval, and exactly 56 calendar
days of heatmap activity. The same functions drive UI and deterministic tests.

## UI and accessibility

The theme is generated from a muted green seed for light and dark system modes.
A shared spacing scale keeps layout values consistent. Interactive Material
controls retain at least 48×48 logical-pixel targets. Painted plants expose a
semantic image label containing their name, qualitative state, and health
percentage; heatmap cells expose their date and watering count.

## What I would do with more time

- Add species-specific watering tolerances instead of using one interval-long
  grace window for every plant.
- Store watering events as richer records so schedule edits cannot reinterpret
  historical reliability.
- Add notifications and optional cloud sync behind repository interfaces while
  preserving a fully offline mode.
- Add localization, dynamic-type screenshot coverage, and golden tests on each
  target platform.
- Add data export/import and explicit schema versioning before the saved model
  grows further.
