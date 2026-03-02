# Privacy Policy — OnePhone

**Effective date:** February 28, 2026
**Last updated:** February 28, 2026

---

## 1. Overview

OnePhone ("the app") is a local party game app developed by Rami Younes. This policy explains what information the app collects, how it is used, and your rights as a user.

The short version: **the app collects nothing that leaves your device.** There are no accounts, no servers, and no analytics.

---

## 2. Information Collected

### 2.1 Player Names

Player names entered in the Player Setup screen are saved on your device using Android's local storage (`SharedPreferences`). This data:

- Never leaves your device
- Is not transmitted to any server or third party
- Is not linked to any personal identity
- Can be deleted at any time from within the app (Player Setup → delete players)

### 2.2 No Other Data

The app does **not** collect or store:

- Location data
- Device identifiers
- Usage statistics or analytics
- Crash reports
- Any form of personal information beyond the player names you voluntarily enter

---

## 3. Permissions

The app requests the following Android permissions:

| Permission | Purpose |
|---|---|
| `READ_MEDIA_IMAGES` / `WRITE_EXTERNAL_STORAGE` | Saving game report screenshots to your photo gallery |

No permission is used for tracking, advertising, or data collection.

---

## 4. Third-Party Services

The app uses the following third-party Flutter packages. None of them transmit personal data on behalf of this app:

| Package | Purpose |
|---|---|
| `share_plus` | Triggers the native OS share sheet when you tap the share button — the app only passes text you choose to share |
| `audioplayers` | Plays local sound files bundled with the app |
| `shared_preferences` | Stores player names locally on the device |
| `screenshot` + `image_gallery_saver_plus` | Saves report screenshots to your local gallery |

No advertising SDKs, no analytics SDKs, and no remote configuration services are included.

---

## 5. Data Sharing

We do not sell, trade, or share any data with third parties. There is no data to share — everything stays on your device.

---

## 6. Data Retention and Deletion

Player names are stored indefinitely on your device until you delete them. To remove all saved player names:

1. Open the app
2. Go to **Player Setup**
3. Delete each player manually

Uninstalling the app will also erase all locally stored data.

---

## 7. Children's Privacy

The app does not knowingly collect any personal information from children under 13 (or the applicable age in your jurisdiction). No account creation is required, and no personal data beyond optional player names is entered.

---

## 8. Changes to This Policy

If this policy changes in a material way, the "Last updated" date at the top of this page will be revised. Continued use of the app after any change constitutes acceptance of the updated policy.

---

## 9. Contact

If you have any questions about this privacy policy, please open an issue on the public repository or contact:

**Rami Younes**
GitHub: [github.com/ramiyounes](https://github.com/ramiyounes)

---

*This privacy policy applies to the OnePhone app available on the Google Play Store (package ID: `com.ramiyounes.onephone`).*
