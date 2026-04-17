class IapProductIds {
  // Subscription product IDs — create these in App Store Connect & Google Play.
  // Suggested pricing (chosen to undercut competitor weekly-only paywalls):
  //   proWeekly  — $4.99 / week   (free 3-day trial)
  //   proMonthly — $9.99 / month  (7-day trial)
  //   proYearly  — $39.99 / year  (no trial, 67% off weekly equivalent)
  //   lifetime   — $59.99 one-time non-consumable
  static const proWeekly = 'umax_pro_weekly';
  static const proMonthly = 'umax_pro_monthly';
  static const proYearly = 'umax_pro_yearly';
  static const lifetime = 'umax_lifetime';

  static const subscriptions = {proWeekly, proMonthly, proYearly};
  static const nonConsumables = {lifetime};
  static const all = {proWeekly, proMonthly, proYearly, lifetime};
}
