# Release preparation — draft, not submission ready

Policy review date: 2026-11-07. Recheck in the actual Play Console before submission.

## Current external requirements
- Google Play currently requires new phone apps and updates to target Android 16 / API 36 or higher: https://support.google.com/googleplay/android-developer/answer/11926878 . Development export uses Godot's template SDK defaults; inspect the actual APK/AAB manifest. SDK overrides require the Gradle build mode.
- Apps with native code targeting Android 15+ must support 16 KB page sizes. Verify all engine and advertising native libraries and test a 16 KB environment: https://developer.android.com/guide/practices/page-sizes . No verification is claimed yet.
- New personal developer accounts covered by the policy need at least 12 opted-in testers continuously for 14 days before applying for production access: https://support.google.com/googleplay/android-developer/answer/14151465 . Owner must check account applicability.
- AdMob consent obligations include EEA, UK and Switzerland; integrate a suitable certified consent solution and UMP workflow before ad requests where required: https://support.google.com/admob/answer/13554116 . Current build has no ad SDK and makes no ad requests.
- Godot Android AAB exports require Gradle builds: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html . A development APK is not an AAB or a signed production release.

## Android build procedure
1. Install the exact Godot 4.7.2 stable export templates. Configure Java and Android SDK paths in Editor Settings. Use a compatible JDK per that Godot release; the host's Android Studio JBR is 25.0.4, which must not be assumed compatible with every Gradle version.
2. Open Export, choose Android Development, export debug APK. Only debug signing is used. Keystore files stay outside Git.
3. Install on emulator/device using `adb install -r island-survivor-dev.apk`. Launch the installed application, not the editor preview. Capture logs and verify touch, audio and lifecycle.
4. For AAB, install Android Gradle build template, enable Gradle build, select AAB, verify plugin/SDK/NDK/JDK compatibility, set a final owner-approved application ID, and use an owner-controlled upload key with Play App Signing. The current `org.islandsurvivor.lostworld` is a provisional ID.
5. Validate the signed bundle with bundletool, verify target/min SDK, native ABIs, 16 KB alignment and no unintended permissions. Run Play internal testing before closed testing.

## AdMob implementation checklist (not integrated)
Candidate maintained integration: https://github.com/poingstudios/godot-admob-plugin . Alternative with documented UMP/reward signals: https://github.com/godot-sdk-integrations/godot-admob . Pin one audited release compatible with Godot 4.7.2, preserve its licence, and test its native Android binary. Do not install two competing plugins.

Use Google's official Android test rewarded unit ID and sample app ID from https://developers.google.com/admob/android/test-ads . Retrieve exact current IDs during integration. Never use live ads to test. Request updated consent information, show forms as needed, expose privacy choices, and check whether ads can be requested before loading. Unavailable ads leave ordinary offline respawn usable.

Ad reward ledger must be persisted and atomic: request nonce → verified reward callback → consume nonce → grant once → save. A close event must never grant a reward. Cancel/fail/no fill resets loading safely. Bind revive nonce to the current death; grant at most once. Persist two supply crates and three bonus quest rewards per day with explicit day-boundary/clock rollback handling. All these cases remain unimplemented and unverified. Production IDs require explicit owner approval.

## Store listing draft
Title: Island Survivor: Lost World

Short description: Survive a tropical island, uncover a lost expedition, and find your way home.

Full description draft (publish only after features pass release tests):
Shipwrecked on a mysterious shore, build a life from what the island provides. Gather food and materials, craft tools, establish a shelter and explore six regions, from bright beaches to ancient ruins. Follow the trail of a missing expedition, recover a forgotten transmitter and choose your next horizon. A single-player survival adventure designed for landscape touch controls and offline exploration.

Do not advertise implemented-in-code features as release ready until tested. Do not claim ads exist in the current build. Final store copy must disclose optional rewarded advertising if activated later.

## Privacy policy draft — current offline development build
Island Survivor: Lost World stores game progress and settings locally on the device. This development version has no account, advertising SDK, analytics or developer-operated server, and its Android export preset requests no Internet permission. Local progress can be reset in the game or deleted through the operating system's app-data controls. The developer does not receive local save files automatically.

Before publication, insert the actual developer/controller identity, support contact, effective date and hosted policy URL. Reassess backups and all dependencies in the final binary. If AdMob is added, replace this draft with accurate SDK data categories, purposes, sharing, consent/withdrawal, retention and deletion details; link Google's current privacy documentation. This draft is not a completed legal review.

## Data Safety and content rating preparation
For the current offline build, the intended answer is no developer collection or sharing, but verify the final binary and platform backup configuration. With advertising, audit the exact SDK disclosures; do not reuse the offline answer. Obtain current Google Mobile Ads SDK guidance at submission time.

Content questionnaire facts: stylised non-graphic animal combat, survival health loss, poison, no blood/gore, no chat/user content, no gambling, no purchases in current build. The rating is assigned by the questionnaire authorities; no age rating is claimed here. Target audience and child-directed treatment require an owner decision before ads or store submission.

## Closed testing instructions
Create an internal track after signing and complete pre-launch reports. Recruit eligible testers with diverse phones and Android versions. For applicable new personal accounts, maintain the minimum tester period above. Test fresh install, all chapters, save recovery, death, low storage, interrupted sessions, airplane mode, long play, 16 KB mode, consent and rewarded ads once present. Collect device model, OS, reproducible steps and redacted crash logs. Owner must approve uploads and production rollout.

## Production gate
- [ ] Every requested feature implemented and verified; no release-blocking bugs.
- [ ] Unassisted full story completion and continued play.
- [ ] Physical mid-range phone performance, thermal and accessibility checks.
- [ ] Final art, audio, icon (512×512), feature graphic (1024×500) and actual Android screenshots.
- [ ] Engine and third-party licences bundled.
- [ ] Tested AdMob and UMP, production activation approved separately.
- [ ] Owner identity, support and privacy hosting configured.
- [ ] Data Safety, content rating and audience declarations match final build.
- [ ] Signed AAB, SDK/ABI/page-size validation, internal and closed tests passed.
- [ ] Owner explicitly approves publishing. No publishing has occurred.
