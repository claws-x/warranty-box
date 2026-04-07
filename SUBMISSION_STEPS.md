# WarrantyBox Submission Steps

## In Xcode

1. Open the project and confirm `AppIcon` has no missing sizes.
2. Run the app on a real iPhone.
3. Verify notification permission flow and reminder scheduling.
4. Verify camera and photo-library permission prompts.
5. Run all tests and confirm they pass.
6. Increment `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` before archive.
7. Archive the app and validate the archive.

## In App Store Connect

1. Create or update the app record.
2. Fill in app name, subtitle, keywords, and description using `APP_STORE_METADATA.md`.
3. Upload screenshots using `SCREENSHOT_CHECKLIST.md`.
4. Add the support URL and privacy policy URL.
5. Complete the App Privacy questionnaire based on the current local-only data behavior.
6. Add review notes explaining notification, camera, and photo-library permissions.
7. Submit the build for review.

## Final Manual Check

- Confirm no placeholder links remain.
- Confirm contact email or website is valid.
- Confirm screenshots match the shipped UI.
- Confirm privacy policy wording matches the current app behavior.
