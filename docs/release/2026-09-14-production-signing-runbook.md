# Releaf 1.0 Android production signing runbook — 14 September 2026

Status: **PROCEDURE READY / OWNER PLAY-CONSOLE + PRIVATE KEY ACTION REQUIRED**

This runbook prepares the private Android **upload key** used to sign the Releaf AAB before Google Play accepts it. It does not change the frozen app build candidate and it must never cause a private key, password or base64-encoded keystore to be committed to Git.

## Signing model

Use **Google Play App Signing** for Releaf.

Keep the two key roles separate:

- **App signing key** — managed/protected by Google Play and used by Google to sign APKs delivered to users.
- **Upload key** — privately controlled by the Releaf owner/release operator and used only to sign the AAB uploaded to Play.

Current Google guidance requires an RSA upload key of at least 2048 bits and recommends keeping the upload key separate from the app-signing key. With Play App Signing enabled, a lost or compromised upload key can be reset through Play Console.

## Critical rule: verify before generating

Before creating any new keystore:

1. Open the Releaf app in Play Console.
2. Open **Protected with Play > Play Store distribution > Play app signing** (follow the current Console wording if navigation differs).
3. Determine whether Play App Signing is already enabled.
4. Inspect the **Upload key certificate** section.
5. If an upload certificate already exists and the matching private keystore is available, use that existing key.
6. If an upload certificate exists but its private key is lost/compromised, do **not** invent a replacement silently; use Play's **Request upload key reset** process.
7. Only generate a fresh upload key when this is genuinely a new setup or the reset flow explicitly requires one.

For a new Play app, Google currently enrols new apps in Play App Signing when the first app bundle is uploaded, with Google-generated app-signing keys by default.

## Generate a new upload key only when appropriate

Run this locally on the owner's trusted Windows machine, not in ChatGPT and not in CI:

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\Releaf-Secrets" | Out-Null

keytool -genkeypair -v `
  -keystore "$env:USERPROFILE\Releaf-Secrets\releaf-upload.jks" `
  -alias releaf-upload `
  -keyalg RSA `
  -keysize 3072 `
  -validity 10000
```

`keytool` will ask for the keystore/key password and certificate identity. Use strong unique passwords. Do not paste those passwords into chat, issue trackers, Discord, Notion or source files.

The alias expected by GitHub can be any intentional value; if the command above is used, record it securely as:

`releaf-upload`

## Verify the private keystore

```powershell
keytool -list -v `
  -keystore "$env:USERPROFILE\Releaf-Secrets\releaf-upload.jks" `
  -alias releaf-upload
```

Confirm:

- the alias exists;
- entry type is a private-key entry;
- the certificate is RSA;
- the SHA-256 fingerprint is recorded in the private release record;
- the file is not inside the Git repository.

## Export the public upload certificate

The public certificate is safe to provide to Google Play when required:

```powershell
keytool -export -rfc `
  -keystore "$env:USERPROFILE\Releaf-Secrets\releaf-upload.jks" `
  -alias releaf-upload `
  -file "$env:USERPROFILE\Releaf-Secrets\releaf-upload-certificate.pem"
```

The `.pem` contains the public certificate, not the private signing key.

For an upload-key reset, use this certificate in the official Play Console reset flow. Do not upload the `.jks` private keystore to Play Console.

## Back up the private upload key before using it

Before the first production-equivalent signed release:

1. Keep the primary `releaf-upload.jks` outside the repo in the owner's protected secrets location.
2. Create at least one encrypted offline backup under the owner's control.
3. Store the passwords in a password manager separately from the keystore backup.
4. Record the alias and certificate SHA-256 fingerprint in the private release record.
5. Test that the backup can be opened with `keytool -list` before relying on it.
6. Never email the keystore to yourself or store it in a public/shared project folder.

The private keystore is replaceable through Play's upload-key reset when Play App Signing is active, but losing it during release still causes avoidable operational delay.

## Configure GitHub Actions secrets

The production workflow expects:

- `ANDROID_UPLOAD_KEYSTORE_BASE64`
- `ANDROID_UPLOAD_STORE_PASSWORD`
- `ANDROID_UPLOAD_KEY_PASSWORD`
- `ANDROID_UPLOAD_KEY_ALIAS`
- `REVENUECAT_ANDROID_API_KEY`

The first four are private signing inputs. `REVENUECAT_ANDROID_API_KEY` is the RevenueCat public Android `goog_...` SDK key, but it is still kept out of source control by the workflow.

Do not put the keystore in the repository merely because GitHub needs it. Encode it locally and store only the encoded value as a GitHub Actions secret.

Example PowerShell procedure when GitHub CLI is installed and authenticated to the correct repository:

```powershell
$repo = 'keisaj9006/releaf_app'
$keystore = "$env:USERPROFILE\Releaf-Secrets\releaf-upload.jks"
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($keystore))

gh secret set ANDROID_UPLOAD_KEYSTORE_BASE64 --repo $repo --body $b64
Remove-Variable b64

gh secret set ANDROID_UPLOAD_STORE_PASSWORD --repo $repo
gh secret set ANDROID_UPLOAD_KEY_PASSWORD --repo $repo
gh secret set ANDROID_UPLOAD_KEY_ALIAS --repo $repo
```

For the interactive `gh secret set` calls, enter each value directly at the prompt. Do not save the passwords in a `.ps1`, `.txt`, clipboard-history note or committed env file.

Configure `REVENUECAT_ANDROID_API_KEY` only after RevenueCat's real Google app is correctly configured and the intended public SDK key has been verified:

```powershell
gh secret set REVENUECAT_ANDROID_API_KEY --repo $repo
```

Do not put RevenueCat service-account JSON or secret/server API keys into this mobile-build secret.

## GitHub production legal variables

The production workflow also reads these GitHub Actions **variables**:

- `RELEAF_DATA_CONTROLLER_NAME`
- `RELEAF_PRIVACY_CONTACT_EMAIL`
- `RELEAF_PRIVACY_POLICY_URL`
- `RELEAF_ACCOUNT_DELETION_URL`
- `RELEAF_PRIVACY_LAST_UPDATED`

Known Releaf value:

- `RELEAF_ACCOUNT_DELETION_URL=https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`

Do not configure placeholders for the remaining values. The real controller identity and privacy contact email are still owner inputs; the Privacy URL and last-updated date should be the actual deployed policy route/date.

## Run the production workflow

Only after signing, RevenueCat and legal inputs are complete:

1. verify the workflow is being dispatched from `releaf-development`;
2. verify `pubspec.yaml` remains `1.0.0+20260913` for the current candidate family;
3. run `.github/workflows/android_production_release.yml` manually;
4. require full tests/analyzer/legal validation to pass;
5. require `jarsigner -verify -strict` to pass;
6. retain the uploaded production AAB and its generated SHA-256 checksum;
7. record the AAB artifact ID/hash in release evidence;
8. never use the CI smoke-signing key as the Play upload key.

The resulting production-signed AAB is still not enough to declare Releaf release-ready. It must be distributed through the authorized Play testing path and complete the mandatory device/billing/deletion QA matrix.

## Upload-key recovery

If the upload key is lost or suspected compromised **and Play App Signing is enabled**:

1. generate a new upload key locally;
2. export its public certificate to PEM;
3. in Play Console open the current Play app-signing management surface;
4. request an upload-key reset;
5. submit the new public certificate;
6. wait for Play to complete/activate the reset before signing future uploads with the replacement key;
7. replace the GitHub signing secrets only after the reset is confirmed.

If Play App Signing is not enabled, key loss has much more serious consequences; stop and resolve the Play signing state before continuing release work.

## Official reference verified 14 September 2026

Google Play Console Help — **Use Play app signing**:
https://support.google.com/googleplay/android-developer/answer/9842756?hl=en-GB

The current guidance confirms the app-signing/upload-key split, minimum RSA key size, separate-key recommendation, new-app Play App Signing flow and upload-key reset procedure.
