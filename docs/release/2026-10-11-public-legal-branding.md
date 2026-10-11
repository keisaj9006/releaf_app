# Relief public legal branding checkpoint — 11 October 2026

## Scope

The existing public legal host was updated in place. Its URL and Supabase/deletion
integration were deliberately preserved:

- account deletion: `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/`
- Privacy Policy: `https://releaf-account-deletion-89juqm.v2.appdeploy.ai/privacy-policy.html`
- AppDeploy app id: `releaf-account-deletion-89juqm`

The legacy technical hostname is retained so existing Google Play/legal links do
not break. User-visible product naming is now **Relief**.

## Changes

Visible `Releaf` / `RELEAF` wording was replaced with `Relief` in:

- account-deletion page title and body copy;
- identity-verification copy;
- Google Play subscription disclosure;
- deletion success and local-data copy;
- Privacy Policy title, brand line, descriptions and body copy;
- AppDeploy QA expectations.

No authentication, Supabase project, RevenueCat erasure, deletion function,
subscription-management URL or public legal URL was changed.

## Deployment evidence

AppDeploy snapshot: `1791731459380`

Post-deploy status: **ready**

Post-deploy QA:

- frontend errors: 0
- network errors: 0
- backend errors: 0
- fresh web screenshot: present
- fresh mobile screenshot: present

A source audit of the published snapshot using the pattern
`Releaf|RELEAF` returned **0 matches** across the deployed source tree.

The existing policy publication date `2026-09-14` remains unchanged because this
deployment corrected product branding and did not change the described processing
purposes, data categories, recipients, retention model or user rights.

## Remaining release work

This checkpoint proves public availability and current branding. It does not by
itself close final Play Console entry, legal review, production-equivalent
DQA-18/DQA-19 or Google Play submission.
