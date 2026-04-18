# Question Classification & Perspective Routing

## Council Size by Flag

| Flag | Council Size |
|---|---|
| `--quick` | 2 (User Advocate + 1 most relevant) |
| *(default)* | 4 (User Advocate + 3 adaptive) |
| `--full` | 6 (all perspectives) |
| `--council N` | N (2–6) |

## Classification Table

### Architecture / Design
**Signals:** "structure", "design", "build", "system", "architecture", "schema", "API", "database", "microservice", "monolith", "component", "module", "layer"
**Intent:** How should something be structured or organized?
**Relevance order:** Architect > Skeptic > Pragmatist > Temporal Analyst > Innovator

### Strategy / Direction
**Signals:** "should we", "roadmap", "direction", "pivot", "bet on", "invest in", "long-term", "vision", "compete", "differentiate", "market"
**Intent:** Which path to take? What to commit to?
**Relevance order:** Architect > Innovator > Temporal Analyst > Skeptic > Pragmatist

### User Experience
**Signals:** "UX", "users", "onboarding", "adoption", "usability", "interface", "experience", "friction", "flow", "journey", "accessibility"
**Intent:** How will people experience or interact with this?
**Relevance order:** Skeptic > Pragmatist > Innovator > Temporal Analyst > Architect

### Risk Assessment
**Signals:** "risk", "danger", "concern", "worry", "vulnerability", "threat", "downside", "failure", "worst case", "what could go wrong"
**Intent:** What are the dangers and how do we mitigate them?
**Relevance order:** Skeptic > Temporal Analyst > Architect > Pragmatist > Innovator

### Innovation / Ideation
**Signals:** "new idea", "what if", "brainstorm", "explore", "creative", "alternative", "novel", "rethink", "reimagine", "disrupt", "experiment"
**Intent:** Generate new possibilities or challenge existing approaches
**Relevance order:** Innovator > Architect > Skeptic > Temporal Analyst > Pragmatist

### Planning / Execution
**Signals:** "plan", "timeline", "roadmap", "execute", "implement", "phase", "milestone", "sprint", "ship", "deliver", "prioritize", "sequence"
**Intent:** How to order, schedule, or execute work?
**Relevance order:** Temporal Analyst > Pragmatist > Architect > Skeptic > Innovator

### General / Unknown
**Signals:** (no clear category match)
**Intent:** Broad analysis needed
**Relevance order:** Architect > Skeptic > Pragmatist > Innovator > Temporal Analyst

## Selection Algorithm

1. Classify question → get relevance order
2. Start with User Advocate (always included unless `--exclude advocate`)
3. Fill remaining slots from relevance order, top to bottom
4. Apply `--include` overrides (add, up to 6 max)
5. Apply `--exclude` overrides (remove)
6. Final council: 2–6 perspectives minimum

## Examples

`/another-perspective Should we use Redis or Postgres for sessions?`
→ Architecture. Default (4). Council: User Advocate + Architect + Skeptic + Pragmatist

`/another-perspective --quick Should we rewrite the auth system?`
→ Architecture. Quick (2). Council: User Advocate + Architect

`/another-perspective --full What's our mobile strategy?`
→ Strategy. Full (6). All perspectives.

`/another-perspective --deep Should we pivot to enterprise?`
→ Strategy. Default (4) on Opus. Council: User Advocate + Architect + Innovator + Temporal Analyst
