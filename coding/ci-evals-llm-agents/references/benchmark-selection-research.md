# Benchmark Selection Research: Equity Fundamentals Research Agent

Worked example from May 2026. Agent: CPE Research (Opus 4.6, Serper, Firecrawl, Render). Output: one-page investment memo with sourced appendix.

## Benchmark Tiers (by relevance to equity research)

### Tier 1: Must Use
| Benchmark | Tests | Dataset | Access | Relevance |
|-----------|-------|---------|--------|-----------|
| Vals.ai Finance Agent v1.1 | SEC filing research, 9 question types | 537 Q (50 public) | Free harness, github.com/vals-ai/finance-agent | 5/5 |
| FinanceBench (Patronus AI) | Citation traceability to SEC filing passages | 150 Q | Fully open-source, github.com/patronus-ai/financebench | 5/5 |
| Mercor APEX IB | Hard financial modeling (merger models, sensitivity) | 160 tasks (100 scored) | Paper + samples, arxiv.org/abs/2509.25721 | 4/5 |

### Tier 2: Should Use
| Benchmark | Tests | Why |
|-----------|-------|-----|
| METR Time Horizon | Agent endurance (can it complete 30-60min research tasks?) | Apply methodology to your own tasks, don't run their full suite |
| OBLIQ-Bench | Latent pattern retrieval (oblique search queries) | Tests your Serper+Firecrawl pipeline specifically |
| Epoch ECI | Composite general capability (39+ benchmarks) | Model selection thermometer, not agent eval |

### Tier 3: Model Selection Only
LiveBench, SimpleBench, LMArena, IFBench - useful for comparing base models, not for evaluating agent output.

### Tier 4: Skip
Scale AI (paid service), Deeptune (training gyms), Fleet AI (agent product), Contra Creative Arena (wrong domain), Design Arena (UI design).

## Key Benchmarks Not On The Original List
- **FinanceBench** - citation quality gold standard
- **FinTradeBench** - financial reasoning + trading decisions
- **GAIA** - general multi-step agent reasoning (Vals.ai modeled on this)
- **FinQA/FLARE** - numerical reasoning over financial tables

## Opus 4.6 Scorecard (May 2026)
| Benchmark | Score | Rank | Top |
|-----------|-------|------|-----|
| Vals.ai Finance Agent | 60.05% | #5 | Opus 4.7 @ 64.37% |
| APEX IB | 32.8-33.4% | #7-8 | GPT 5.5 @ 41.7% |
| ECI (Epoch) | 155 | #8 | GPT-5.5 Pro @ 160 |
| LiveBench | 76.33 | #5 | GPT-5.5 @ 80.71 |
| LMArena Document | 1514 Elo | #2 tie | Strong doc comprehension |

## Published research site
Full analysis with Anthropic eval harness integration: cpe-eval-research.surge.sh
Source files: ~/projects/cpe-eval-research/
