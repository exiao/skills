# 2026-05-10 CTWA BloomBot implementation notes

Use this when turning the Click-to-WhatsApp plan into code, bot routing, or reviewable ad assets.

## Repo split

CTWA support spans two repos:

1. `Bloom-Invest/bloom` backend
   - Capture CTWA/referral metadata in `/api/bloombot/v2/check-access/` context.
   - Infer bot flow from prefill/referral/message text: `portfolio_screenshot`, `ticker_gut_check`, `market_brief`.
   - Return `ad_context` with `first_response`, `ad_angle`, `expected_user_job`, and attribution.
   - Log funnel events in `InteractionLog`: `whatsapp_conversation_started`, `paywall_viewed`, `subscription_started`, `purchase`.

2. `Bloom-Invest/bloombot` runtime plugin
   - `hermes/plugins/bloom-access` must forward visible WhatsApp text plus CTWA/referral keys into Bloom `check-access`.
   - It should inject backend `ad_context` into system context so the first reply exactly matches the ad promise.

Keep these as separate PRs unless the user explicitly wants one repo only.

## Context payload keys to preserve

Forward and store these when available:

- `wa_message_id`, `message_id`
- `message_text`, `message_preview`, `prefill_text`
- `ctwa_clid`, `source_id`, `ad_id`, `adset_id`, `campaign_id`
- `referral_source_url`, `referral_headline`, `referral_body`, `referral_media_type`
- nested `referral` and `ad` dicts if the gateway exposes them

Use visible prefill/message text as fallback when Meta referral fields are missing.

## First-response mapping

- Portfolio: `Send a screenshot of your holdings. I’ll look for concentration, risk, recent news, and anything worth researching more. This is research context, not financial advice.`
- Ticker: `Send one ticker. I’ll give you the bull case, bear case, recent catalysts, and key risks. Research context only, not financial advice.`
- Brief: `Here’s the quick brief: indexes, biggest movers, one macro thing, and what to watch tomorrow. Want this every morning?`

## Local test pitfalls

Bloom view tests can be blocked locally by a pre-existing import chain: `bloom_backend.views.__init__ -> backtest -> bt/ffn -> matplotlib`, with error `generic_type: type "_InterpolationType" is already registered!`. If that happens:

- Still run targeted helper tests that avoid URL imports, e.g. `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 uv run python -m pytest -o addopts='' bloom_backend/tests/services/test_bloombot_ctwa.py -q`.
- Run `uv run python -m py_compile` on changed Python modules.
- Report the environment blocker in the PR body instead of pretending full view tests passed.

## Creative QA pitfalls

- Avoid explicit platform/trademark names where unnecessary. Use `Generic AI answer` instead of `ChatGPT answer`; use `investing forum` instead of Reddit UI/`r/investing` if the asset is likely to run as a paid ad.
- A deterministic PIL/SVG renderer is acceptable for first-pass reviewable drafts when final text must be perfectly spelled, but reject anything that looks like programmer art. Use it for native mockups/checklists, then vision-QA every asset.
- Always create a contact sheet and run vision QA before sending assets or uploading.
- For Signal delivery, final reply must include `MEDIA:/absolute/path` lines for the zip/contact sheet, otherwise attachments will not send.
