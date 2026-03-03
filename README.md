# Google Ads Scraper

An [Agent Skill](https://agentskills.io/) for pulling ad creatives from [Google's Ads Transparency Center](https://adstransparency.google.com/) and compiling structured competitive intelligence.

**Agent-agnostic.** Whether you're using Claude Code, Codex, Cursor, or Copilot, Google Ads Scraper works the same way.

## Why Google Ads Scraper?

The Ads Transparency Center shows every ad a company is running on Google, but there's no way to extract that data at scale. Google Ads Scraper turns it into a research tool. It handles:

- **Advertiser discovery** across legal names and domains
- **Ad image extraction** with smart scrolling that stops when all ads are loaded
- **Visual ad reading** in batches using multimodal capability
- **Competitive reports** with ad copy themes, pricing, sitelinks, and gaps to exploit
- **Multi-competitor comparison** with side-by-side analysis

## Quick start

### Installation

Google Ads Scraper is an agent skill that gives your AI coding agent the ability to research any company's Google Ads. It scrapes the Ads Transparency Center, reads each ad visually, and compiles a full competitive intelligence report. Whether you're using Claude Code, Codex, Cursor, or Copilot, Google Ads Scraper makes competitive ad research as simple as asking a question. Simply run `npx skills add` to get started.

```bash
npx skills add josueaagomez/google-ads-scraper
```

Or manually:

```bash
git clone https://github.com/josueaagomez/google-ads-scraper.git
cd google-ads-scraper
chmod +x install.sh && ./install.sh
cp skills/google-ads-scraper/SKILL.md ~/.claude/skills/google-ads-scraper.md
```

Requires Python 3.8+ and pip.

### Usage

Skills activate automatically when your request matches the description. Examples:

```
Pull all Google Ads for example.com
```

```
What ads is [company name] running on Google?
```

```
Compare ads from [company A], [company B], and [company C]
```

## How it works

| Step | What happens |
|------|-------------|
| **Advertiser discovery** | Searches by company name, falls back to domain search when companies register under different legal names |
| **Ad download** | Loads the Transparency Center with Playwright, smart scrolls until all ads are loaded, extracts and deduplicates ad images |
| **Visual reading** | Reads ad images in batches of 3-5, extracts headlines, descriptions, display URLs, sitelinks, offers, and phone numbers. Skips non-text formats |
| **Report compilation** | Organizes findings into ad copy themes, pricing patterns, sitelink usage, and competitive gaps |
| **Export** | Saves reports and images to `~/Downloads/google_ads_library/[Company Name]/` |

## What you get

For each company scraped, the report includes:

- **Ad copy themes** with frequency counts across all ads
- **Pricing and offers** mentioned in ad copy
- **Sitelinks** and display URLs used
- **Phone numbers** and call extensions
- **Gaps to exploit** against the competitor

For multi-competitor runs, a side-by-side comparison table is generated automatically.

## Sample output

```
# Acme Roofing - Competitor Ad Intel

**Advertiser:** Acme Roofing Co. (AR12345678901234567890)
**Domain:** acmeroofing.com
**Region:** US
**Active text ads:** 12 (2 non-text ads skipped)

## Ad copy themes
- "Free Estimate": 8 of 12 ads use this in the headline
- "Licensed & Insured": 6 of 12 ads lead with trust signals
- "Same-Day Service": 5 of 12 ads push urgency

## Sitelinks
- Roof Repair
- Free Inspection
- Financing Available
- See Our Reviews

## Gaps to exploit
- No pricing in ads: not a single dollar amount
- No phone number: zero call extensions visible
- Repetitive headlines: almost every ad uses the same formula
- No emergency service messaging
```

## Known limitations

- Google may rate-limit aggressive scraping. Space out large pulls.
- Video and display ad formats won't have extractable text. The skill focuses on search ads.
- Google's Ads Transparency Center could change its page structure at any time.
- Image reading accuracy depends on ad image quality and resolution.

## Resources

- [Google Ads Transparency Center](https://adstransparency.google.com/)
- [Agent Skills Specification](https://agentskills.io/specification)

## License

MIT License - see [LICENSE](LICENSE) for details.

---

Built for competitive ad research, client onboarding, and PPC strategy.
