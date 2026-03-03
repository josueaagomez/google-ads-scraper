#!/bin/bash

echo "Installing Google Ads Scraper..."
echo ""

echo "Installing Playwright..."
pip3 install playwright

echo ""
echo "Installing Chromium browser..."
python3 -m playwright install chromium

echo ""
echo "Done. Next step:"
echo ""
echo "  cp skills/google-ads-scraper/SKILL.md ~/.claude/skills/google-ads-scraper.md"
echo ""
echo "Then start your agent and tell it to scrape some ads."
