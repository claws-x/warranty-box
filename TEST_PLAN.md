# WarrantyBox Test Plan

## Required New Test Target

- `WarrantyBoxTests` is now present.
- Continue using Apple's `Testing` framework for new unit tests.

## First Tests To Add

- Verify `WarrantyItem.expirationDate` for common month values.
- Verify `WarrantyItem.daysRemaining` and `remainingDescription` for active, same-day, and expired warranties.
- Verify urgency ordering logic used by the home list.
- Verify reminder refresh only schedules future notifications.
- Verify disabling reminders cancels pending identifiers for the item.

## Suggested UI Coverage

- Add an item with reminder disabled.
- Add an item with reminder enabled after granting notification permission.
- Edit an existing item and confirm the list reflects updated values.
- Delete an item from the list and confirm it disappears.
- Toggle reminder state from the detail page.

## Manual Device Checks

- Test camera/photo flows on a real device after privacy keys are added.
- Test local notifications by using near-term dates during development.
- Test foreground/background reminder resync behavior.
