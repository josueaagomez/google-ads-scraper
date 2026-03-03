# AGENTS.md

This file provides guidance to AI coding agents when working with this repository.

## Project overview

Google Ads Scraper is an agent skill that pulls any company's Google Ads from the Transparency Center, reads them visually, and compiles structured competitive intelligence.

## Directory structure

```
google-ads-scraper/
├── README.md
├── AGENTS.md
├── CLAUDE.md
├── LICENSE
├── install.sh
├── requirements.txt
└── skills/
    └── google-ads-scraper/
        └── SKILL.md
```

## Skill format

The skill follows the [Agent Skills specification](https://agentskills.io/specification). The main instruction file is `skills/google-ads-scraper/SKILL.md` with YAML frontmatter.

## Dependencies

- Python 3.8+
- `playwright` (pip package + Chromium browser)

Install via `./install.sh` or `pip install playwright && python -m playwright install chromium`.

## Key implementation notes

- The entire skill runs on Playwright only. No third-party scraping libraries needed.
- Use `wait_until="domcontentloaded"` for Playwright, not `"networkidle"`.
- Companies often register ads under legal names different from their brand. The search handles both name and domain queries through the same Transparency Center search box.
- Ad images use the `simgad` URL pattern on the Transparency Center.
- Smart scrolling stops after 3 consecutive rounds with no new ad images loading.
