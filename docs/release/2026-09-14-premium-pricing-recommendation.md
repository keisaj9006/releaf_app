# Releaf 1.0 Premium pricing recommendation — 14 September 2026

Status: **COMMERCIAL RECOMMENDATION / OWNER APPROVAL REQUIRED**

This note is not evidence that Google Play or RevenueCat pricing has been configured. It records a launch recommendation only. Engineering must not activate production prices until the owner approves or changes them.

## Recommended launch price

- Monthly: **£5.99**
- Annual: **£39.99**

Do not add a free trial, introductory offer or lifetime plan to the Releaf 1.0 production contract unless it is intentionally approved and separately QA-tested.

## Why this position

The active Releaf 1.0 proposition is deliberately narrower than the largest established wellness subscriptions:

- active pillars: Reset, Brain and Sleep, with Emergency Calm supporting the release;
- Meditate remains parked outside the active 1.0 discovery/marketing surface while its content production is incomplete;
- Releaf has meaningful differentiated value in short Reset interventions plus cognitive training, but it does not yet have the breadth of a mature Calm/Headspace/BetterSleep content library;
- BetterSleep describes a very large premium sleep catalogue (including hundreds of sounds and extensive sleep content) and states that pricing varies by region/platform;
- current official Calm and Headspace web offers are positioned around roughly USD 69.99 per year, although regional/store prices and promotions vary.

The recommended Releaf launch price therefore deliberately sits below the broad-library incumbents while preserving enough perceived value and revenue headroom to fund content expansion.

## Release rule

Before creating/activating the Google Play base-plan prices:

1. owner explicitly approves the monthly and annual GBP values or supplies replacements;
2. configure matching country/region pricing in Google Play rather than hardcoding price strings in the app;
3. import the active base plans into RevenueCat and keep the app reading localized store metadata;
4. verify both packages with Play license-tester transactions on the production-equivalent candidate;
5. if a trial/intro offer is added later, reopen billing QA because offer eligibility and purchase presentation change.

## Current market references checked

Checked 14 September 2026:

- BetterSleep official FAQ: subscription prices vary by time, offer, region and platform; monthly/yearly/lifetime plans are available.
- BetterSleep official product FAQ: premium catalogue includes more than 500 sounds/melodies plus SleepTales, guided content and additional sleep tooling.
- Calm official plans page: current web plan shown at USD 69.99/year after trial (regional/store pricing can differ).
- Headspace official current web/share offer: annual renewal shown at 69.99/year (currency/region/store context can differ).

These references are positioning evidence, not a promise that every UK Google Play user sees the same competitor price.

## Decision

Owner approval: **OPEN**

- Approved monthly GBP price: `OPEN`
- Approved annual GBP price: `OPEN`
- Trial/intro offer for 1.0: `NO by default; OPEN only if owner intentionally changes scope`
