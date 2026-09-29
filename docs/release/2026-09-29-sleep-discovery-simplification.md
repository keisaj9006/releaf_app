# Sleep discovery simplification — 29 September 2026

The Sleep landing screen now presents one primary action: Continue Listening for the latest valid unfinished local item, otherwise Tonight. Four category gateways (Stories, Nature, Meditations and Sleep Music) replace the All filter and duplicated Popular/category rails. Selecting a gateway shows only that family. The five Story collection rows and See all sheets remain inside Stories. The Sound library link, current playback routes, Premium preview and access checks are unchanged.

Unknown/corrupt progress falls back to Tonight. Pending Story audio and unrecorded Sleep Meditation guidance remain visibly unavailable without a play action. No media or approval state changed. At 320 dp and 200% text scale, tests reached and tapped all four gateways without overflow.

Verification: 104/104 focused Sleep, Story, Sound and primary-navigation tests passed; `flutter analyze --no-pub` reported no issues; `flutter test --no-pub --reporter compact` passed 660/660. `flutter build apk --debug --dart-define-from-file=tool/local/revenuecat-test-store.json` succeeded (assembleDebug 119.1 s), producing `build/app/outputs/flutter-apk/app-debug.apk`. Flutter printed future Gradle/AGP/Kotlin compatibility and SDK XML warnings; none failed this build. The APK has not been installed or physically reviewed in this batch.

Open: owner-approved Story audio/artwork and rights, recorded guidance as applicable, and physical long-duration/background/interruption playback QA. This build is not a production-equivalent release artifact.
