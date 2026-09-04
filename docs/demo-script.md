# Planter demo script

This walkthrough takes about two minutes and demonstrates the app with no
network connection.

1. Launch the app. Point out the **Needs water** and **All good** groups and how
   the four demo plants already show distinct wilt stages and pot colors.
2. Open **Monty**. Show the due date, care note, watering history, reliability,
   and large painted plant.
3. Tap **Edit**. Change **Last watered** to a date two weeks earlier, then tap
   **Save**. Keep the detail screen visible while Monty's stem leans, leaves
   droop, and color changes during the 600 ms animation.
4. Tap **Water now**. The date and history update, the artwork returns to full
   health, and the undo snackbar appears. Tap **Undo** once to demonstrate that
   both the data and artwork are restored, then water again.
5. Return home and open **Plant insights** from the chart button. Show the four
   computed totals, eight-week heatmap, and per-plant on-time percentages.
6. Edit any plant, add a short note, and select a different pot color. Save and
   show both values on the detail screen.
7. Finish with the debug-only flask button. Drag **Health** slowly between 100%
   and 0% to show continuous interpolation and low-health leaf shedding.

For a clean repeat, clear the app's storage; the four demonstration plants are
seeded again only when no saved value exists.
