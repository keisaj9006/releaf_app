# Releaf 1.0 Privacy Policy deployment evidence — 14 September 2026

Status: **PUBLIC HTTPS RESOURCE LIVE / FINAL PLAY + DEVICE ENTRY STILL REQUIRED**

## Public resource

Privacy Policy URL:

`https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`

Account deletion URL:

`https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`

AppDeploy app: `releaf-account-deletion-89juqm`

Applied AppDeploy source snapshot containing the Privacy Policy: `1789387063562`.

After deployment AppDeploy reported:

- deployment status: `ready`;
- frontend errors: none;
- network errors: none;
- backend errors: none;
- fresh desktop and mobile QA screenshots generated.

## Owner-supplied production metadata

The owner supplied and approved the following release metadata on 14 September 2026:

- data controller name: `Relief`;
- public privacy contact email: `canius.uk@gmail.com`;
- privacy last updated date: `2026-09-14`;
- account deletion URL: `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`;
- privacy URL: `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`.

The public page displays those values and includes the current Releaf 1.0 disclosures for account/authentication data, RevenueCat/Google Play subscription data, local-first progress, local/transient Labyrinth accelerometer input, service providers, lawful basis, international processing, retention criteria, account deletion, data-protection rights and complaint route to the UK Information Commissioner's Office.

The existing account-control page now exposes a visible relative `Privacy Policy` link to the public policy without changing the authenticated deletion implementation.

## Legal-identity guard

Engineering records `Relief` exactly as supplied by the owner. Current ICO guidance requires the identity and contact details of the controller to be provided in privacy information. If `Relief` is only a product/trading label rather than the true legal controller identity, the owner/legal review must replace it with the correct controller identity before public release. Engineering must not silently guess that identity.

## Release interpretation

This closes the previous **public Privacy Policy deployment** blocker and supplies the five values required by Releaf's production legal-metadata validator.

It does not by itself close:

- production Android signing;
- GitHub Actions variable entry if the current workflow still reads legal metadata from repository variables;
- Play Console Privacy Policy field entry;
- RevenueCat / Google Play production configuration;
- Data Safety / Health declarations;
- final production-equivalent physical-device QA.

Canonical release authority remains `docs/release/releaf_1_0_release_gate.md`.