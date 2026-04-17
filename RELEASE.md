# UMAX — Release Runbook

End-to-end walkthrough from a fresh repo to live on App Store + Play Store. The full pipeline is already wired in `codemagic.yaml`. You're mostly doing account setup + first-time signing.

---

## §0. Accounts you need

| Service | Purpose |
|---|---|
| Apple Developer Program | App Store distribution ($99/yr) |
| Google Play Console | Play Store distribution ($25 one-time) |
| Google AdMob | Ad network |
| Codemagic | CI/CD |
| GitHub | Git remote |

---

## §1. App Store Connect (iOS)

1. **Register bundle ID** at developer.apple.com → Identifiers → `com.idealai.umax` with capability: **In-App Purchase**.
2. **Create app record** at appstoreconnect.apple.com:
   - Name: `UMAX` or `UMAX: AI Face Rating`
   - Primary language: English
   - Bundle ID: `com.idealai.umax`
   - SKU: `umax-ios-001`
   - User Access: Full Access
3. **App Information**:
   - Category: **Health & Fitness** (primary), Lifestyle (secondary)
   - Age rating: 12+ (general guidance / infrequent body imagery)
   - Content Rights: all rights owned
4. **Pricing and Availability**: Free tier, all territories.
5. **In-App Purchases** (create all four):
   - `umax_pro_weekly` — Auto-Renewable Subscription — $4.99/wk — 3-day trial
   - `umax_pro_monthly` — Auto-Renewable Subscription — $9.99/mo — 7-day trial
   - `umax_pro_yearly` — Auto-Renewable Subscription — $39.99/yr — no trial
   - `umax_lifetime` — Non-Consumable — $59.99 one-time
   Group them in a single subscription group ("UMAX Pro") for the 3 subs.
6. **App Privacy**: declare collected data categories (photos: not collected since on-device; identifiers: for ads via AdMob).
7. **App Store Connect API Key**:
   - Users and Access → Keys → Generate API Key (Admin role)
   - Download `.p8`, record **Issuer ID** and **Key ID** for Codemagic integration.

---

## §2. Google Play Console (Android)

1. **Create app**: Apps → Create app
   - Name: `UMAX`
   - Default language: English
   - App / Game: App
   - Free or paid: Free
2. **App content declarations**:
   - Privacy policy URL (see §5)
   - Ads: yes (AdMob)
   - App access: all functions available without login
   - Target audience: 13+
   - Data safety: photos processed locally (not shared), advertising ID used
   - Content rating: complete questionnaire → expect PEGI 3 / ESRB Everyone
3. **Main store listing**: see `STORE_SETUP_GUIDE.md` for copy.
4. **App bundle signing**: opt in to **Play App Signing** (default). Your upload-keystore is NOT the app-signing key; safe to commit.
5. **In-app products**:
   - Create subscriptions `umax_pro_weekly`, `umax_pro_monthly`, `umax_pro_yearly` (same group).
   - Create managed product `umax_lifetime` as non-consumable.
6. **Service account for Codemagic**:
   - Create in Google Cloud Console → IAM → Service Accounts.
   - Download JSON key.
   - Invite the service account email in Play Console → Users and permissions with "Release manager" role.

---

## §3. Android signing

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
# Remember the passwords.
cp key.properties.template key.properties
# Fill passwords into key.properties
```

The keystore IS committed so Codemagic can sign — Google re-signs with their own App Signing Key.

---

## §4. AdMob

1. Create iOS + Android apps in AdMob console.
2. Create ad units: Banner, Interstitial, Rewarded (both platforms).
3. Replace IDs in:
   - `lib/core/constants/ad_ids.dart` — set `_prodBanner*`, `_prodInterstitial*`, `_prodRewarded*`.
   - `android/app/src/main/AndroidManifest.xml` — `com.google.android.gms.ads.APPLICATION_ID`.
   - `ios/Runner/Info.plist` — `GADApplicationIdentifier`.
4. Link AdMob app to App Store / Play Store listing once apps are live.
5. Host `app-ads.txt` at your root domain with: `google.com, pub-XXXXXXXXXX, DIRECT, f08c47fec0942fa0`.

---

## §5. Codemagic

1. Sign in at codemagic.io, add repo.
2. **Team settings** → Integrations:
   - Add **App Store Connect API key** (name it `admin` — matches `codemagic.yaml`).
3. **Environment variable groups** → create `google_play`:
   - `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (secure) = paste JSON content of Google Cloud service account key.

---

## §6. Release

```bash
git commit -am "Release v1.0.0"
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

Codemagic detects the tag, runs `release-both`:
- iOS IPA → TestFlight (auto-processing ~30 min)
- Android AAB → Play Production as DRAFT

Once processing completes:
- **iOS**: add screenshots in App Store Connect, attach IAPs, select build, submit for review.
- **Android**: Promote the DRAFT release to full production in Play Console.

---

## §7. Version bumps

Update `pubspec.yaml`:

```yaml
version: 1.0.1+2   # name+buildNumber — buildNumber must monotonically increase
```

Then commit, tag `v1.0.1`, push.

---

## §8. Troubleshooting

- **"No matching provisioning profile"**: in App Store Connect, make sure the bundle ID matches; Codemagic's `use-profiles` step will fetch/generate if missing.
- **"Version code already exists"**: bump the `+N` build number in `pubspec.yaml`.
- **IAP purchases fail in sandbox**: confirm products are in "Ready to Submit" state in App Store Connect, and use a sandbox test account signed in on-device under Settings → App Store.
- **AdMob shows test ads only**: expected in debug mode; prod IDs load real ads in release builds.
