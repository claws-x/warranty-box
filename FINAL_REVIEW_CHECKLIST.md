# WarrantyBox Final Review Checklist

## Before Submission

- Confirm the app launches without crashing on a real iPhone.
- Confirm adding, editing, deleting, and viewing warranty items all work.
- Confirm photo-library selection works on device.
- Confirm camera capture works on device.
- Confirm notification permission is only requested when the user enables reminders.
- Confirm local reminders can be scheduled after permission is granted.
- Confirm `AppIcon` has no missing required sizes in Xcode.
- Confirm support URL and privacy policy URL are real, public, and reachable.
- Confirm App Store screenshots match the current shipped UI.
- Confirm all placeholder contact info has been replaced.

## During Submission

- Use the copy from `APP_STORE_CONNECT_FINAL_COPY.md`.
- Use the support-page content from `SUPPORT_PAGE_ZH.md`.
- Use the privacy-policy content from `PRIVACY_POLICY_ZH.md`.
- Fill App Privacy based on the current behavior: local storage, local notifications, optional camera/photo-library access.
- In Review Notes, explain notification, camera, and photo-library usage clearly.

## If Review Team Asks Questions

- State that the app stores warranty records locally on device.
- State that notifications are used only for local warranty expiration reminders.
- State that camera and photo-library access are used only to attach receipt or product images.
- State that the app does not require account registration.
- State that the app does not automatically upload warranty data to a remote server in the current version.

## Last Manual Pass

- Archive the app.
- Validate the archive.
- Upload to App Store Connect.
- Submit the build after metadata, screenshots, privacy links, and review notes are complete.
