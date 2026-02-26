# Technology-Specific Patterns

### Next.js Full Stack

```
specs/
├── authentication.md
├── database.md
└── api-routes.md

src/
├── app/                    # App Router
├── components/              # React components
├── lib/                    # Utilities (db, auth, helpers)
└── types/                   # TypeScript types

AGENTS.md:
  Build: npm run dev
  Test: npm run test
  Typecheck: npx tsc --noEmit
  Lint: npm run lint
```

### Python (Scripts/Notebooks/FastAPI)

```
specs/
├── data-pipeline.md
├── model-training.md
└── api-endpoints.md

src/
├── pipeline.py
├── models/
├── api/
└── tests/

AGENTS.md:
  Build: python -m src.main
  Test: pytest
  Typecheck: mypy src/
  Lint: ruff check src/
```

### GPU Workloads

```
specs/
├── model-architecture.md
├── training-data.md
└── inference-pipeline.md

src/
├── models/
├── training/
├── inference/
└── utils/

AGENTS.md:
  Train: python train.py
  Test: pytest tests/
  Lint: ruff check src/
  GPU Check: nvidia-smi
```
