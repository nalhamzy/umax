# UMAX — Store Setup Guide

Everything you (or an AI assistant) need to register the app on App Store + Play Store. Paste these exact strings into the corresponding fields.

---

## §1. Identity

- **App name**: UMAX
- **Subtitle / Short desc**: AI Looksmax & Face Rating
- **Bundle ID (iOS)**: `com.idealai.umax`
- **Application ID (Android)**: `com.idealai.umax`
- **Support email**: `nalhamzy@gmail.com`
- **Marketing / support URL**: `https://github.com/nalhamzy/umax` (update after first release)

## §2. Store listing copy

### Short description (80 chars max, Play Store)

> AI face rating, symmetry analysis & a 30-day glow-up plan — private, on-device.

### iOS subtitle (30 chars)

> AI Looksmax & Face Rating

### Promotional text (170 chars, iOS)

> The honest looksmax app. 3 free scans, transparent pricing, private on-device analysis, and a 30-day glow-up plan that actually targets your weakest traits.

### Full description (up to 4000 chars)

> Discover your looksmax potential with UMAX — the private, honest AI face-rating app that actually helps you level up.
>
> Upload a selfie and UMAX scores your face across 6 traits: **jawline**, **symmetry**, **eye area**, **skin quality**, **facial proportions**, and **facial thirds**. You get an overall score, a tier (Average → Chad/Godlike), a detected face shape, and — most importantly — a personalized **30-day glow-up routine** that targets your weakest traits first.
>
> WHY UMAX IS DIFFERENT
> ✓ 3 free scans, not 1. No card required.
> ✓ Transparent pricing — weekly, monthly, yearly, lifetime, shown upfront.
> ✓ Actionable routines: skincare, grooming, training, habits — not just a number.
> ✓ Progress tracking: every scan saved locally with before/after timeline.
> ✓ Private by design: face analysis runs on-device with Google ML Kit. Photos never leave your phone.
> ✓ Rewarded ads unlock extra scans — you're never forced into an immediate subscription.
>
> WHAT YOU GET
> • 6-trait AI face analysis (jawline, symmetry, eyes, skin, proportions, thirds)
> • Overall score + tier (Average / Above Average / Chad / Godlike)
> • Detected face shape + potential score
> • Personalized 30-day routine generated from your weakest traits
> • Glow-up progress over time — compare scans week-over-week
> • Face shape-aware grooming advice (haircut, brows, jaw training)
> • Skincare stack recommendations with impact ratings
>
> UPGRADE TO PRO
> • Unlimited scans (vs 3/cycle on free)
> • Full trait breakdown (vs first 3 visible)
> • Complete 30-day action plan (vs first 4 actions)
> • Ad-free experience
> • Priority analysis
> Plans: $4.99/wk · $9.99/mo · $39.99/yr (best value) · $59.99 lifetime
>
> PRIVACY
> All face analysis runs locally on your device. We never upload your photos. Read the full policy at [privacy URL].
>
> Ready to see your potential? Download UMAX and start your first scan — it's free.

### Keywords (iOS, 100 chars, comma-separated, no space)

```
looksmax,face,rating,glow,up,jawline,symmetry,skin,potential,chad,analysis,beauty,glowup,looks
```

### Feature graphic text suggestions (Play Store, 1024×500)

- Background: dark purple-to-coral gradient
- Headline: **"See your looks potential"**
- Subhead: AI face rating · 30-day glow-up plan · private

---

## §3. Screenshots (required sizes)

| Store | Size | Min count |
|---|---|---|
| iPhone 6.9" | 1290×2796 | 3 |
| iPhone 6.5" | 1242×2688 | 3 (optional if 6.9 provided) |
| iPad Pro 13" | 2064×2752 | 3 |
| Android phone | 1080×1920 or larger | 2 |
| Android 7-inch tablet | 1200×1920 | 1 (optional) |

Suggested screens to capture (in order):
1. Home with latest scan card (score ring front and center)
2. Scan screen with camera preview + tips
3. Full trait breakdown (result screen)
4. 30-day routine screen
5. Progress history
6. Paywall (shows transparent pricing)

---

## §4. Content ratings

| Field | Answer |
|---|---|
| Violence | None |
| Sexual content | None |
| Profanity | None |
| Drugs/alcohol | None |
| Gambling | No |
| User-generated content | No |
| User photos | Yes (local only, not shared) |
| Location | No |
| iOS age | 12+ |
| Google Play age | 13+ (PEGI 3) |
| Designed for families | No |

---

## §5. Data safety (Play Store)

- **Collected data**: none (face analysis on-device; photos local).
- **Shared data**: advertising ID (AdMob, for ad personalization).
- **Security practices**: data encrypted in transit (HTTPS), users can request deletion via settings → support email.

## §6. Privacy policy (template — host at a public URL before submission)

> **UMAX Privacy Policy** (last updated YYYY-MM-DD)
>
> UMAX performs all face analysis locally on your device. We do not upload, store, or transmit your photos.
>
> **What we collect**: None of your personal data is collected by us. Your scan history, profile and routine are stored **only on your device**.
>
> **Third-party services**:
> - Google AdMob (advertising): may collect advertising identifiers to serve ads. See [Google's policy](https://policies.google.com/privacy).
> - Google Mobile Ads SDK for frequency capping & SKAdNetwork attribution (iOS).
>
> **In-app purchases**: handled by Apple App Store / Google Play; we do not process payment information.
>
> **Your rights**: you can clear all local data by uninstalling the app or via Settings → Clear Data.
>
> **Contact**: nalhamzy@gmail.com

---

## §7. Suggested assistant instructions

If you're using a browser-based AI agent to fill in the stores:

> 1. Go to appstoreconnect.apple.com, create app record with the bundle ID `com.idealai.umax`.
> 2. Fill "App Information" with Health & Fitness primary category, Lifestyle secondary, age rating 12+.
> 3. Fill "Pricing and Availability": Free, all territories.
> 4. Create 4 IAPs: `umax_pro_weekly` (auto-renew sub $4.99/wk), `umax_pro_monthly` ($9.99/mo), `umax_pro_yearly` ($39.99/yr), `umax_lifetime` (non-consumable $59.99).
> 5. Paste short description, full description, keywords from this doc.
> 6. Upload 6 screenshots per device size and the app icon.
> 7. Set privacy policy URL from §6.

Do the same for Play Console with the application ID `com.idealai.umax`.
