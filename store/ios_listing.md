# UMAX — App Store Connect Ready-to-Paste Listing

Every field the App Store Connect UI asks for, with the exact text to paste. Fields are grouped by the section header in App Store Connect.

---

## App Information → Localizable Information (English)

| Field | Value |
|---|---|
| **Name** | `UMAX: AI Looksmax Rating` |
| **Subtitle** | `Glow-up routine that works` |
| **Privacy Policy URL** | `https://github.com/nalhamzy/umax/blob/main/PRIVACY.md` *(replace after deployment)* |
| **Category — Primary** | Health & Fitness |
| **Category — Secondary** | Lifestyle |
| **Content Rights** | Contains no 3rd-party content |

## App Information → General

| Field | Value |
|---|---|
| **Bundle ID** | `com.idealai.umax` |
| **SKU** | `UMAX-IOS-001` |
| **Access** | Full Access |

## Pricing and Availability

- **Price Tier**: Free (tier 0)
- **Availability**: All territories
- **Pre-orders**: off

## Version (1.0.0) → What's New in This Version

```
The first release of UMAX — your honest AI face rating app.

• 3 free scans, no credit card
• 6-trait breakdown with actionable insights
• Personalized 30-day glow-up routine
• Private: all analysis runs on your device
```

## Version → Promotional Text (170 chars)

```
The honest looksmax app. 3 free scans, transparent pricing, private on-device analysis, and a 30-day glow-up plan that targets your weakest traits first.
```

## Version → Description (≤ 4000 chars — paste exactly)

```
Discover your looksmax potential with UMAX — the private, honest AI face-rating app that actually helps you level up.

Upload a selfie and UMAX scores your face across 6 traits: jawline, symmetry, eye area, skin quality, facial proportions, and facial thirds. You get an overall score, a tier (Average → Chad → Godlike), your detected face shape, and — most importantly — a personalized 30-day glow-up routine that targets your weakest traits first.

WHY UMAX IS DIFFERENT
— 3 free scans, not 1. No card required.
— Transparent pricing shown upfront: weekly, monthly, yearly, lifetime.
— Actionable routines: skincare, grooming, training, habits — not just a number.
— Progress tracking: every scan saved locally with before/after timeline.
— Private by design: face analysis runs on-device with Google ML Kit. Photos never leave your phone.
— Rewarded ads unlock extra scans — you're never forced into a subscription at the first wall.

WHAT YOU GET
• 6-trait AI face analysis (jawline, symmetry, eyes, skin, proportions, thirds)
• Overall score + tier (Average / Above Average / Chad / Godlike)
• Detected face shape + potential score showing your realistic ceiling
• Personalized 30-day routine generated from your weakest traits
• Glow-up progress tracking — compare scans week-over-week
• Face shape-aware grooming advice (haircut, brows, jaw training)
• Skincare stack recommendations with impact ratings

UPGRADE TO PRO
• Unlimited scans (vs 3/cycle on free)
• Full trait breakdown (vs first 3 visible)
• Complete 30-day action plan (vs first 4 actions)
• Ad-free experience
• Priority analysis mode
Plans: $4.99/wk · $9.99/mo · $39.99/yr (best value) · $59.99 lifetime

PRIVACY
All face analysis runs locally on your device. We never upload your photos. Read the full policy linked below.

Ready to see your potential? Download UMAX and take your first free scan.
```

## Version → Keywords (100 chars, comma-separated, NO spaces)

```
looksmax,face,rating,glow,up,jawline,symmetry,skin,potential,chad,analysis,beauty,glowup,looks
```

## Version → Support URL

```
https://github.com/nalhamzy/umax
```

## Version → Marketing URL (optional — leave blank for v1)

*(blank)*

## Version → App Review Information

| Field | Value |
|---|---|
| **Sign-in required** | No |
| **Demo account** | Not applicable |
| **Contact info** | name: `Nassim Al-Hamzy` · phone: *(your number)* · email: `nalhamzy@gmail.com` |
| **Review notes** | `All face analysis runs on-device via Google ML Kit. No server-side photo upload. In-app purchases can be tested via sandbox tester account.` |

## Version → Build / IPA

Uploaded automatically by Codemagic `release-both` workflow on tag push.

## Version → Screenshots (required)

Upload from `store_assets/ios/` after running:
```bash
flutter test --update-goldens --tags=screenshot test/screenshot_test.dart
```

| Slot | File | Caption to add in App Store |
|---|---|---|
| 1 | `store_assets/ios/01_home.png` | `Track your glow-up over time.` |
| 2 | `store_assets/ios/02_result.png` | `6-trait AI face analysis.` |
| 3 | `store_assets/ios/03_routine.png` | `Personalized 30-day glow-up routine.` |
| 4 | `store_assets/ios/04_history.png` | `See your progress week by week.` |
| 5 | `store_assets/ios/05_paywall.png` | `Transparent pricing — no hidden fees.` |

Minimum 3 screenshots per device size required. We ship 5.

**Required device sizes (Apple 2026)**:
- iPhone 6.9" (iPhone 15/16 Pro Max): **1290×2796** — generated
- iPad Pro 13" (2024): **2064×2752** — optional, can reuse 6.9" upscaled or skip at submission

## Version → App Previews (video, optional)

Optional for v1. If added later: 15–30s, 886×1920 (portrait), h.264.

## In-App Purchases (all 4)

Create in App Store Connect → Features → Subscriptions / In-App Purchases.

**Subscription group**: `UMAX Pro` (all 3 auto-renew subs in this group)

| Product ID | Type | Reference Name | Display Name | Price | Intro Offer |
|---|---|---|---|---|---|
| `umax_pro_weekly` | Auto-Renewable | UMAX Pro Weekly | `UMAX Pro · Weekly` | $4.99 / week | 3-day free trial |
| `umax_pro_monthly` | Auto-Renewable | UMAX Pro Monthly | `UMAX Pro · Monthly` | $9.99 / month | 7-day free trial |
| `umax_pro_yearly` | Auto-Renewable | UMAX Pro Yearly | `UMAX Pro · Yearly` | $39.99 / year | no intro offer |
| `umax_lifetime` | Non-Consumable | UMAX Lifetime | `UMAX Lifetime` | $59.99 | n/a |

**IAP display name / description** (for the subscription / product details page, one example, reuse pattern):

```
UMAX Pro unlocks:
• Unlimited AI face scans
• Full 6-trait breakdown
• Complete 30-day glow-up routine
• No ads
• Priority analysis
```

**Review info for each IAP**: upload a 640×920 screenshot of the paywall (`store_assets/ios/05_paywall.png` works).

## App Privacy

Answer the privacy questionnaire with:

- **Data Used to Track You**: Device ID (for Advertising) → *Yes, used for Third-Party Advertising via AdMob*
- **Data Linked to You**: None
- **Data Not Linked to You**: Crash Data (Diagnostics)
- **Photos**: No (processed on-device, not collected)

## Age Rating

Answer "None" to all questions → result: **4+** or **12+** depending on AdMob content rating. Match AdMob's `MaxAdContentRating.pg` setting → **12+**.

## Submission checklist

- [ ] All above fields filled
- [ ] 5 screenshots uploaded for iPhone 6.9"
- [ ] All 4 IAPs in "Ready to Submit" state
- [ ] Build attached to version (uploaded by Codemagic)
- [ ] Paid Apps agreement signed in Agreements, Tax, and Banking
- [ ] Export compliance: **Uses encryption = No** (only HTTPS calls — exempt)
- [ ] Click **Submit for Review**
