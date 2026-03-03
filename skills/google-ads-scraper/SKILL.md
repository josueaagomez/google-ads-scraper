---
name: google-ads-scraper
description: Scrape any company's Google Ads from the Transparency Center and compile competitive intelligence. Use when asked to "pull competitor ads", "scrape Google Ads", "what ads is [company] running", "competitor ad research", or "Google Ads Transparency".
license: MIT
metadata:
  author: josueaagomez
  version: "2.0"
---

# Google Ads Scraper

You are an expert at competitive ad research. Your goal is to scrape real ad creatives from Google's Ads Transparency Center and extract actionable intelligence.

## Dependencies

This skill requires only:
- `playwright` (Python): `pip install playwright && python -m playwright install chromium`

No other libraries or API keys needed.

## Workflow

### Step 1: Find the advertiser

The user may provide a company name, a domain, or multiple competitors. Handle each one.

**Search by name or domain:**

```python
from playwright.sync_api import sync_playwright
import re

query = "Company Name"  # or "example.com"

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto("https://adstransparency.google.com/?region=US", wait_until="domcontentloaded")
    page.wait_for_timeout(3000)

    # Type the query into the search box
    search_input = page.locator('input[type="text"]').first
    search_input.fill(query)
    page.wait_for_timeout(3000)

    # Read the dropdown suggestions
    options = page.locator('[role="option"]').all()
    suggestions = []
    for opt in options:
        text = opt.inner_text().strip()
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        name = lines[0] if lines else text
        suggestions.append(name)
    print(f"Suggestions: {suggestions}")

    # Click the first (best) match
    if options:
        options[0].click()
        page.wait_for_timeout(5000)

        url = page.url

        # Case 1: Direct advertiser page (AR ID in URL)
        ar_match = re.findall(r'/advertiser/(AR\d+)', url)
        if ar_match:
            advertiser_id = ar_match[0]
            name = page.title().split(' - ')[0]
            print(f"Found: {name} ({advertiser_id})")

        # Case 2: Search results page (multiple advertisers or domain search)
        else:
            content = page.content()
            ar_ids = set(re.findall(r'/advertiser/(AR\d+)', content))
            print(f"Advertiser IDs found: {ar_ids}")
            # Navigate to the first advertiser to get their name
            if ar_ids:
                advertiser_id = list(ar_ids)[0]
                page.goto(f"https://adstransparency.google.com/advertiser/{advertiser_id}?region=US", wait_until="domcontentloaded")
                page.wait_for_timeout(3000)
                name = page.title().split(' - ')[0]
                print(f"Found: {name} ({advertiser_id})")

    browser.close()
```

**Important:** Companies often register under different legal names than their brand. The search handles both company names and domains. If a name search returns unexpected results, try the domain instead.

**Multiple competitors:** If the user provides multiple companies, run Steps 1-3 for each one, then combine results in Step 4 with a side-by-side comparison.

### Step 2: Pull ad creatives

Use Playwright to download ad preview images from the Transparency Center.

**Region targeting:** Change the `region=` parameter to pull ads running in specific countries. Default is `US`. Common values: `US`, `CA`, `GB`, `AU`, `DE`, `FR`, `MX`, `BR`.

```python
from playwright.sync_api import sync_playwright
import urllib.request
import os

region = "US"  # Change for different regions

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto(f"https://adstransparency.google.com/advertiser/{advertiser_id}?region={region}&format=TEXT", wait_until="domcontentloaded")
    page.wait_for_timeout(8000)

    # Smart scroll: stop when no new ads load
    prev_count = 0
    no_change_rounds = 0
    for i in range(20):
        page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
        page.wait_for_timeout(2000)
        current_count = page.evaluate("document.querySelectorAll('img[src*=\"simgad\"]').length")
        if current_count == prev_count:
            no_change_rounds += 1
            if no_change_rounds >= 3:
                break  # No new ads loading, stop scrolling
        else:
            no_change_rounds = 0
        prev_count = current_count

    # Extract and deduplicate ad image URLs
    images = page.evaluate("""
        () => Array.from(document.querySelectorAll('img'))
            .map(img => img.src)
            .filter(src => src.includes('simgad'))
    """)
    unique_images = list(set(images))
    browser.close()

# Download images into a company subfolder
safe_name = company_name.replace(" ", "_").replace("/", "_")
output_dir = os.path.expanduser(f"~/Downloads/google_ads_library/{safe_name}")
os.makedirs(output_dir, exist_ok=True)
for i, url in enumerate(unique_images):
    urllib.request.urlretrieve(url, os.path.join(output_dir, f"ad_{i}.png"))
```

**Important notes:**
- Always deduplicate image URLs before downloading. Many ads reuse the same creative.
- Use `wait_until="domcontentloaded"` not `"networkidle"`. The Transparency Center often times out on networkidle.
- Smart scroll stops after 3 consecutive rounds with no new ads. For very large advertisers, increase the max iterations.

### Step 3: Read ad images visually

Read the downloaded images using your visual/multimodal capability.

**Batch reading (faster):** Read 3-5 images at a time in a single pass instead of one by one. This significantly speeds up large pulls. Group them and read each batch together.

**Skip non-text ads:** Some images will be display/video ad formats that show "null" or just a "Visit site" button with no ad copy. Skip these and note them as non-text formats in the count.

For each text ad, extract:
- **Headlines** (blue text at top)
- **Descriptions** (gray text below headline)
- **Display URL** (green/black URL shown in the ad, e.g. "www.example.com/page")
- **Sitelinks** (blue pill-shaped buttons at bottom, if present)
- **Offers/pricing** (any dollar amounts, percentages, or promotions)
- **Phone numbers** (if call extensions are visible)

For large advertisers, read a strategic sample of 20-30 ads rather than all of them. Look for patterns and themes.

### Step 4: Compile intelligence and export

After extracting all ads, organize findings.

**Single competitor output:**

```
## [Company Name]
**Advertiser:** [Legal name] ([Advertiser ID])
**Domain:** [domain]
**Region:** [region scraped]
**Active text ads:** [count] ([X] non-text ads skipped)

### Ad copy themes
- [Theme 1]: [X] of [total] ads use this angle
- [Theme 2]: [X] of [total] ads

### Pricing/offers in ads
- [List all prices and promotions]

### Sitelinks
- [List sitelinks found]

### Display URLs used
- [List unique display URLs found in ads]

### Phone numbers
- [List phone numbers found]

### Gaps to exploit
- [Weakness 1]
- [Weakness 2]
```

**Multi-competitor comparison:** When scraping multiple competitors, add a comparison section at the end:

```
## Side-by-side comparison

| | [Company A] | [Company B] | [Company C] |
|---|---|---|---|
| Active text ads | [count] | [count] | [count] |
| Main angle | [theme] | [theme] | [theme] |
| Pricing mentioned | [yes/no] | [yes/no] | [yes/no] |
| Phone in ads | [yes/no] | [yes/no] | [yes/no] |
| Sitelinks used | [count] | [count] | [count] |
| Trust signals (reviews, license, etc.) | [list] | [list] | [list] |
| Financing/offers | [list] | [list] | [list] |

### Key takeaways
- [Insight about competitive landscape]
- [Gaps no competitor is covering]
- [Opportunity to differentiate]
```

### Step 5: Save results

After compiling the intelligence, **always save the full report as a markdown file.** Don't just print it inline and lose it.

**Default save location:** `~/Downloads/google_ads_library/[Company Name]/report.md`

Each company gets its own subfolder containing the report and ad images.

```python
import os, glob

# Build the markdown report (the compiled output from Step 4)
report = f"""# {company_name} - Competitor Ad Intel

**Advertiser:** {legal_name} ({advertiser_id})
**Domain:** {domain}
**Region:** {region}
**Active text ads:** {ad_count}
**Scraped:** {date}

## Ad copy themes
...

## Gaps to exploit
...
"""

# Save report to the company subfolder (same folder as the ad images)
safe_name = company_name.replace(" ", "_").replace("/", "_")
output_dir = os.path.expanduser(f"~/Downloads/google_ads_library/{safe_name}")
os.makedirs(output_dir, exist_ok=True)
output_path = os.path.join(output_dir, "report.md")
with open(output_path, "w") as f:
    f.write(report)

# Move ad images into an images subfolder to keep things organized
img_dir = os.path.join(output_dir, "images")
os.makedirs(img_dir, exist_ok=True)
for img in glob.glob(os.path.join(output_dir, "ad_*.png")):
    os.rename(img, os.path.join(img_dir, os.path.basename(img)))
```

After saving, tell the user the file path so they can open it or move it wherever they need.

If the user specifies a custom path (like an Obsidian vault or client folder), save there instead:

```python
# Example: user says "save it to my client folder"
output_path = "/path/to/vault/Clients/[Client Name]/Competitor Ads/[Company Name].md"
with open(output_path, "w") as f:
    f.write(report)
```

For multi-competitor runs, save one file per competitor plus a combined comparison file.

## Tips

- Some advertisers use city subdomains (e.g., losangeles.example.com). This reveals their geo targeting strategy.
- Compare the messaging across their ads to find their main selling points and what they repeat most.
- Check if competitors use tracking phone numbers (different number across ads). This tells you how sophisticated their tracking is.
- Note which sitelinks they use. Missing sitelinks = wasted real estate you can take advantage of.
- When reading ad images, pay attention to geographic targeting clues (city names in headlines, local phone numbers).
- For multi-competitor runs, look for angles that NO competitor is using. That's your opportunity.
- Display URLs reveal what landing page paths competitors are advertising, even though they may be cosmetic. Patterns like "/free-estimate" or "/emergency" tell you their conversion strategy.
