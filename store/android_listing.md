# UMAX — Google Play Console Ready-to-Paste Listing

---

## Dashboard → Create app

| Field | Value |
|---|---|
| **App name** | `UMAX: AI Looksmax Rating` |
| **Default language** | English (United States) |
| **App or game** | App |
| **Free or paid** | Free |
| **Declarations** | Developer Program Policies ✓ · US Export Laws ✓ |

## Set up your app → App details

### Main store listing

| Field | Value |
|---|---|
| **App name** | `UMAX: AI Looksmax Rating` |
| **Short description** (80 chars) | `AI face rating, symmetry & a 30-day glow-up plan — private, on-device.` |

### Full description (≤ 4000 chars)

```
Discover your looksmax potential with UMAX — the private, honest AI face-rating app that actually helps you level up.

Upload a selfie and UMAX scores your face across 6 traits: jawline, symmetry, eye area, skin quality, facial proportions, and facial thirds. You get an overall score, a tier (Average → Chad → Godlike), your detected face shape, and a personalized 30-day glow-up routine that targets your weakest traits first.

WHY UMAX IS DIFFERENT
✓ 3 free scans — no card, no hidden pricing
✓ Transparent subscriptions: weekly, monthly, yearly, lifetime — all shown upfront
✓ Actionable routines (skincare, grooming, training, habits) — not just a number
✓ Progress tracking: every scan saved locally with before/after timeline
✓ Private by design: face analysis runs on-device with Google ML Kit. Photos never leave your phone.
✓ Rewarded ads unlock extra scans — no paywall ambush

WHAT'S INCLUDED
• 6-trait AI face analysis (jawline, symmetry, eyes, skin, proportions, thirds)
• Overall score + tier (Average / Above Average / Chad / Godlike)
• Detected face shape + potential score showing your realistic ceiling
• Personalized 30-day routine generated from your weakest traits
• Glow-up progress tracking — compare scans week-over-week
• Face shape-aware grooming advice (haircut, brows, jaw training)
• Skincare recommendations with impact ratings

UMAX PRO UNLOCKS
• Unlimited scans (vs 3/cycle on free)
• Full trait breakdown (vs first 3 visible)
• Complete 30-day action plan (vs first 4 actions)
• Ad-free experience
• Priority analysis
Plans: $4.99/wk · $9.99/mo · $39.99/yr (best value) · $59.99 lifetime

PRIVACY
All face analysis runs locally on your device. We never upload your photos.

Ready to see your potential? Download UMAX and take your first free scan.
```

### Graphics

| Asset | Spec | File |
|---|---|---|
| App icon | 512×512 PNG, 32-bit | `store_assets/play/icon_512.png` *(generate from `assets/icon/icon_source.png` after app icon is designed)* |
| Feature graphic | 1024×500 PNG/JPG | `store_assets/play/feature.png` *(create with background gradient + headline)* |
| Phone screenshots | 16:9 or 9:16, min 320px, max 3840px, PNG/JPG | `store_assets/android/01_home.png` … `05_paywall.png` |
| 7-inch tablet | optional for v1 | skip |
| 10-inch tablet | optional for v1 | skip |

**Minimum 2 phone screenshots required; we ship 5.**

### Video (optional)

YouTube URL, leave blank for v1.

### Categorization

| Field | Value |
|---|---|
| **App category** | Health & Fitness |
| **Tags** | lifestyle, personal growth |
| **Contact email** | `nalhamzy@gmail.com` |
| **Website (optional)** | `https://github.com/nalhamzy/umax` |

---

## Set up your app → Store listing declarations

### App content

| Topic | Answer |
|---|---|
| **Privacy policy URL** | `https://github.com/nalhamzy/umax/blob/main/PRIVACY.md` *(replace after deployment)* |
| **Ads** | Yes, contains ads (Google AdMob) |
| **App access** | All functionality available without restrictions (no login required) |
| **Content rating** | run questionnaire → expect **PEGI 3 / ESRB Everyone** |
| **Target audience** | 13+ |
| **News** | No |
| **Health apps** | No (not medical — UMAX scoring is entertainment/lifestyle, not diagnostic) |
| **COVID-19 contact tracing & status** | No |
| **Data safety** | See below |
| **Government apps** | No |
| **Financial features** | No |

### Data safety (paste into the form)

**Does your app collect or share any of the required user data types?**

- **Personal info** → No
- **Photos and videos** → Collected? No (processed on-device, not sent off-device)
- **Files and docs** → No
- **App activity** → App interactions → **Collected? No** · Shared? No
- **App info and performance** → Crash logs → **Collected? Yes** (Google Play Console default), **Shared? No**, **Processed ephemerally? Yes**
- **Device or other IDs** → Advertising ID → **Collected? Yes** · **Shared? Yes** (Google AdMob) · Purpose: Advertising or marketing · Required? No

**Data encrypted in transit?** Yes (HTTPS for AdMob requests)
**Users can request data to be deleted?** Yes (uninstall the app or clear data in Settings)

### Content rating questionnaire answers

| Question | Answer |
|---|---|
| Violence / sexual content / profanity / drugs | None |
| Gambling / social features / user-generated content | No |
| Users can share their location | No |
| Users share personal info with other users | No |
| Digital purchases | Yes (subscriptions + lifetime unlock) |

→ Rating: **PEGI 3 · ESRB Everyone · USK 0**

### App access

> Select: "All functionality is available without any restrictions"

### Target audience

- **Age group**: 13-17, 18-24, 25-34, 35-44, 45-54, 55-64, 65+ (uncheck anything under 13)
- **Appeal to children**: No
- **Designed for Families program**: No

---

## Monetization → Subscriptions

Create these in Monetization → Subscriptions.

| Product ID | Name | Base plan | Price | Free trial |
|---|---|---|---|---|
| `umax_pro_weekly` | UMAX Pro · Weekly | weekly-auto | $4.99 / week | 3 days |
| `umax_pro_monthly` | UMAX Pro · Monthly | monthly-auto | $9.99 / month | 7 days |
| `umax_pro_yearly` | UMAX Pro · Yearly | yearly-auto | $39.99 / year | none |

## Monetization → In-app products

| Product ID | Type | Name | Price |
|---|---|---|---|
| `umax_lifetime` | Managed (non-consumable) | UMAX Lifetime | $59.99 |

**Description for each** (example):

```
UMAX Pro unlocks:
• Unlimited AI face scans
• Full 6-trait breakdown
• Complete 30-day glow-up routine
• No ads
• Priority analysis
```

---

## Release → Production → Create new release

1. Enroll in **Play App Signing** if not done (default option).
2. Upload AAB from Codemagic artifact OR let Codemagic publish as DRAFT automatically on tag push.
3. Release name: `1.0.0 (1)`
4. Release notes (English):

```
• First release of UMAX
• AI face rating across 6 traits
• Personalized 30-day glow-up routine
• Progress tracking over time
• Transparent pricing · no hidden fees
```

## Submission checklist

- [ ] All policy declarations (Ads, Data safety, Content rating, Target audience) completed
- [ ] ≥ 2 phone screenshots + feature graphic uploaded
- [ ] Privacy policy URL live
- [ ] Subscriptions and managed product created and active
- [ ] Service account invited (Release Manager role)
- [ ] First AAB uploaded via Codemagic to Production as DRAFT
- [ ] Review DRAFT → **Start rollout to Production**
