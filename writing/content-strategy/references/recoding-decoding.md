# Recoding-Decoding (RD): Breaking LLM Repetition in Brainstorming

Source: "Inducing Sustained Creativity and Diversity in LLMs" (Luo, King, Puett, Smith — Harvard, March 2026)

## The Problem

LLMs are optimized for "correct" answers. RLHF, standard decoding, and leaderboard metrics all crush the long tail of knowledge. Ask for 1,000 battlefield suggestions and you get 19 unique ones. Ask for 250 bridal dress ideas and they collapse into 35 conceptual clusters. Newer, more capable models are actually worse at this because their distributions are more peaked.

This kills any task where you need to explore the full space of possibilities: brainstorming content angles, generating ad concepts, finding positioning gaps, discovering underserved topics.

## The Fix: Two Simple Tricks

No fine-tuning, no retraining. Works at inference time with any model.

### 1. Random Priming Phrase

Prepend a random phrase before the prompt:

> "Related to UMBRELLA: [your actual prompt]"

Pick the noun randomly from a list of common nouns. Different noun each time you call the model.

### 2. Random Diverting Token

Insert a random 3-letter word stem (like "Pas", "Tib", "Cor") at the start of each new generated sentence. This exploits positional bias to knock the model off its default paths.

### Post-processing

Run a grammar corrector on the output (fix errors from the injected tokens). Do NOT run a fact corrector, which would revert creative outputs back to conventional ones.

## Results

| Metric | Standard Decoding | With RD |
|--------|:-:|:-:|
| Unique battlefields (1,000 prompts) | 19 | 1,307 |
| Conceptual clusters (250 dress ideas) | 35 | 244 |
| Coverage of other method's ideas | 30-40% of RD | ~100% of standard |
| Relevance score | 0.94-0.99 | 0.94-0.99 |

RD finds everything standard decoding finds, plus 60-70% more. And relevance doesn't drop.

## When to Use This

Apply RD when generating large volumes of ideas where diversity matters more than convergence:

- **Content angles:** "Give me 50 hooks for [topic]" will repeat without RD
- **Ad creative:** Generating many ad variations that actually feel different
- **Positioning exploration:** Finding angles competitors haven't used
- **Keyword/topic discovery:** Surfacing long-tail ideas the model would normally skip
- **Product naming:** Getting past the obvious candidates
- **Audience segment brainstorming:** Finding non-obvious customer profiles

## Practical Implementation

The technique needs the Completion API (not Chat). If only Chat API is available, use a system prompt:

> "Simulate a completion API to continue the next sentence."

For brainstorming workflows in skills, the simplest adaptation: run the same prompt N times, each with a different random "Related to NOUN:" prefix. Deduplicate and cluster the results. You'll get dramatically broader coverage of the idea space.

## Key Insight

Newer, more capable models benefit MORE from RD because their probability distributions are more peaked. The smarter the model, the more it needs this technique to access its own long-tail knowledge.
