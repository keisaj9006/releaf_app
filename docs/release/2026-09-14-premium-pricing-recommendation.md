# Releaf 1.0 Premium pricing decision — 14 September 2026

Status: **OWNER APPROVED / PLAY + REVENUECAT CONFIGURATION REQUIRED**

This note records the owner-approved Releaf 1.0 launch pricing decision. It is not evidence that Google Play or RevenueCat pricing has already been configured.

## Approved launch price

- Monthly: **£5.99**
- Annual: **£39.99**
- Free trial / introductory offer: **none for 1.0 by default**

Do not add a free trial, introductory offer or lifetime plan to the Releaf 1.0 production contract unless it is intentionally approved and separately QA-tested.

## Why this position

The active Releaf 1.0 proposition is deliberately narrower than the largest established wellness subscriptions:

- active pillars: Reset, Brain and Sleep, with Emergency Calm supporting the release;
- Meditate remains parked outside the active 1.0 discovery/marketing surface while its content production is incomplete;
- Releaf has meaningful differentiated value in short Reset interventions plus cognitive training, but it does not yet have the breadth of a mature Calm/Headspace/BetterSleep content library;
- BetterSleep describes a very large premium sleep catalogue and states that pricing varies by region/platform;
- current official Calm and Headspace web offers are positioned around roughly USD 69.99 per year, although regional/store prices and promotions vary.

The approved Releaf launch price therefore sits below the broad-library incumbents while preserving enough perceived value and revenue headroom to fund content expansion.

## Production rule

When configuring Google Play:

1. configure the monthly base plan with a UK target price of **£5.99**;
2. configure the annual base plan with a UK target price of **£39.99**;
3. do not add a trial/intro offer for 1.0 unless the owner deliberately reopens that decision;
4. configure country/region pricing in Google Play rather than hardcoding price strings in the app;
5. import the active base plans into RevenueCat and keep the app reading localized store metadata;
6. verify both packages with Play license-tester transactions on the production-equivalent candidate;
7. if a trial/intro offer is added later, reopen billing QA because offer eligibility and purchase presentation change.

## Current market references checked

Checked 14 September 2026:

- BetterSleep official FAQ: subscription prices vary by time, offer, region and platform; monthly/yearly/lifetime plans are available.
- BetterSleep official product FAQ: premium catalogue includes more than 500 sounds/melodies plus SleepTales, guided content and additional sleep tooling.
- Calm official plans page: current web plan shown at USD 69.99/year after trial (regional/store pricing can differ).
- Headspace official current web/share offer: annual renewal shown at 69.99/year (currency/region/store context can differ).

These references are positioning evidence, not a promise that every UK Google Play user sees the same competitor price.

## Decision

Owner approval: **APPROVED 14 September 2026**

- Approved monthly GBP price: `£5.99`
- Approved annual GBP price: `£39.99`
- Trial/intro offer for 1.0: `NO`