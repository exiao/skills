# Bloom CLI

Financial data CLI for coding agents. Downloads data to files so you can use bash (jq, grep, awk) to extract what you need instead of loading everything into context.

## Setup

```bash
export BLOOM_API_KEY=<your-key>
# Or: bloom auth login
```

## Quick Research Workflow

```bash
# 1. Find what you need
bloom info AAPL                              # fundamentals, ratings, peers
bloom info AAPL --fields basic_metadata,bottom_line_ratings  # specific sections only

# 2. Download to files for analysis
bloom info AAPL -o /tmp/bloom/aapl-info.json
bloom news AAPL --limit 10 -o /tmp/bloom/aapl-news.json
bloom price AAPL --timeframes 1m,1y -o /tmp/bloom/aapl-price.json
bloom financials AAPL --type revenue -o /tmp/bloom/aapl-revenue.json

# 3. Use bash to extract what matters
jq '.symbols[0].basic_metadata | {name, latest_price, sector, pe_ratio}' /tmp/bloom/aapl-info.json
jq '.articles[] | .headline' /tmp/bloom/aapl-news.json
jq '.data[] | select(.revenue_growth > 0.1)' /tmp/bloom/aapl-revenue.json
```

## Commands

| Command | What it does | Example |
|---------|-------------|---------|
| `info` | Company fundamentals, ratings, peers | `bloom info AAPL MSFT` |
| `news` | Recent news headlines | `bloom news AAPL --limit 5` |
| `price` | Historical price data | `bloom price AAPL --timeframes 1d,1m,1y` |
| `financials` | Revenue, margins, cash flow | `bloom financials AAPL --type revenue` |
| `sentiment` | Market mood (AAII, Fear&Greed, VIX) | `bloom sentiment` |
| `market` | Market map, sectors, movers | `bloom market --type top_movers` |
| `collections` | Curated stock lists by theme | `bloom collections --section VALUE` |
| `screen` | Filter stocks by metrics | `bloom screen "market_cap > 100B" "pe_ratio < 25"` |
| `earnings` | Earnings history & estimates | `bloom earnings AAPL` |
| `technicals` | RSI, MAs, patterns, options flow | `bloom technicals AAPL` |
| `options-history` | Options sentiment over time | `bloom options-history AAPL --days 30` |
| `portfolio` | Portfolio risk analysis | `bloom portfolio '{"AAPL":0.5,"MSFT":0.5}'` |
| `trades` | AI trade evaluation | `bloom trades "Buy AAPL: strong AI catalysts"` |
| `catalysts` | Forward-looking value drivers | `bloom catalysts AAPL MSFT` |
| `position-size` | Kelly criterion sizing | `bloom position-size --bull 0.6 --bear -0.15 --conviction 8 --value 100000` |
| `transcript` | Search earnings call transcripts | `bloom transcript AAPL "AI" "services"` |
| `ai-trades` | Recent AI model trade decisions (InvestingArena) | `bloom ai-trades --model claude --limit 5` |
| `ai-portfolio` | AI model portfolio positions & performance | `bloom ai-portfolio --model openai` |

## Global Flags

Every command supports:
- `-o, --output <file>` — write to file instead of stdout
- `-f, --format json|csv|table` — output format (default: json)
- `-q, --quiet` — suppress headers, data only
- `--raw` — raw API response

## Common Patterns

### Compare Multiple Stocks
```bash
mkdir -p /tmp/bloom/compare
for ticker in AAPL MSFT GOOG AMZN; do
  bloom info $ticker -o /tmp/bloom/compare/$ticker.json
done
# Extract key metrics
for f in /tmp/bloom/compare/*.json; do
  ticker=$(basename $f .json)
  pe=$(jq -r '.symbols[0].basic_metadata.pe_ratio // "N/A"' $f)
  price=$(jq -r '.symbols[0].basic_metadata.latest_price' $f)
  echo "$ticker: \$$price (P/E: $pe)"
done
```

### Screen → Deep Dive
```bash
# Find cheap large-caps
bloom screen "market_cap > 50B" "pe_ratio < 20" "dividend_yield > 2" -o /tmp/bloom/screened.json

# Get the tickers
tickers=$(jq -r '.results[].symbol' /tmp/bloom/screened.json | head -5 | tr '\n' ' ')

# Deep dive on each
for t in $tickers; do
  bloom earnings $t -o /tmp/bloom/earnings-$t.json
  bloom catalysts $t -o /tmp/bloom/catalysts-$t.json
done
```

### Market Check
```bash
bloom sentiment -o /tmp/bloom/sentiment.json
bloom market --type major_indexes -o /tmp/bloom/indexes.json
bloom market --type top_movers --limit 10 -o /tmp/bloom/movers.json

# Quick summary
jq '{fear_greed: .cnn_fear_greed.index_value, level: .cnn_fear_greed.level, vix: .volatility_analysis.assessment}' /tmp/bloom/sentiment.json
```

### Portfolio Review
```bash
bloom portfolio '{"AAPL":0.3,"MSFT":0.25,"GOOG":0.25,"AMZN":0.2}' --strategy "tech growth" -o /tmp/bloom/portfolio.json
jq '.risk_metrics' /tmp/bloom/portfolio.json
```

### Earnings Research
```bash
bloom transcript AAPL "AI" "services" "margins" --max 20 -o /tmp/bloom/transcript.json
jq '.matches[] | {speaker, text}' /tmp/bloom/transcript.json
```

### AI Arena (InvestingArena — 3 AIs with real money)
```bash
# All AI models' recent trades
bloom ai-trades -o /tmp/bloom/ai-trades.json

# Claude's last 5 trades
bloom ai-trades --model claude --limit 5

# All trades on NVDA across all models
bloom ai-trades --symbol NVDA -o /tmp/bloom/nvda-ai-trades.json

# Full portfolio snapshot for all 3 models
bloom ai-portfolio -o /tmp/bloom/ai-portfolio.json

# Just Gemini's portfolio
bloom ai-portfolio --model gemini

# Extract model returns
jq '[.[] | {model: .ai_model, return_pct, account_value}]' /tmp/bloom/ai-portfolio.json
```

## Tips

- Use `-o` to download data to files, then `jq` to extract. Saves context tokens.
- Batch multiple tickers: `bloom info AAPL MSFT GOOG` (up to 10).
- Use `bloom screen` first to narrow your universe, then deep-dive with other commands.
- `--fields` on `bloom info` reduces response size when you only need specific sections.
- Pipe to `jq -r '.field'` for clean values usable in scripts.
