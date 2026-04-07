# WarrantyBox Release Checklist

## Before Submission

- Add `NSCameraUsageDescription` to the app's `Info.plist`.
- Add `NSPhotoLibraryUsageDescription` to the app's `Info.plist`.
- Decide whether you need `NSPhotoLibraryAddUsageDescription`; add it if the app will save images back to Photos.
- Create and verify a complete `AppIcon.appiconset`.
- Confirm launch behavior, notifications, and image picking on a physical device.
- Create at least one test target and add coverage for warranty date calculations and reminder scheduling behavior.
- Prepare App Store Connect metadata: subtitle, keywords, description, support URL, and privacy policy URL.
- Prepare screenshots for required iPhone sizes.
- Review notification copy and privacy copy for production wording.

## Current Code Status

- Core data model is defined in code and the app builds successfully.
- Warranty items can be added, edited, deleted, filtered, and sorted.
- Reminder permissions are checked before enabling notifications.
- The app can resync reminders on launch and when returning to foreground.
- A `PrivacyInfo.xcprivacy` file exists in the repo.
- A `WarrantyBoxTests` target exists and basic model tests are passing.

## Known Gaps

- Asset catalog contents are not visible from the current project structure snapshot, so icon completeness still needs manual confirmation in Xcode.
- App Store Connect metadata still needs manual preparation.
- Physical-device verification is still required for camera, photo library, and notification flows.
