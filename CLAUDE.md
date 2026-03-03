# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project summary

Google Ads Scraper is an agent skill that scrapes ad creatives from Google's Ads Transparency Center and compiles competitive intelligence. Only dependency is Playwright. No API keys needed.

## Quick reference

| Skill | Location | Triggers |
|-------|----------|----------|
| google-ads-scraper | `skills/google-ads-scraper/` | "pull ads", "scrape Google Ads", "competitor ads", "what ads is [company] running" |

## Dependencies

- `playwright` (Python) + Chromium. That's it.

## Common gotchas

- Use `wait_until="domcontentloaded"`, not `"networkidle"`.
- Companies register under legal names. The search handles both names and domains through the same search box.
- Deduplicate `simgad` image URLs before downloading.
- Smart scroll stops after 3 rounds with no new ads. Increase max iterations for very large advertisers.
