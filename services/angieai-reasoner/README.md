# angieai-reasoner

Deterministic routing/reasoning microservice for AngieAI. Given a piece of
text, it decides which lane in the AI-to-AI protocol should handle it
(`AngieAI-local`, `google-ai-studio`, `dmux`, `angieai-onnx`, `angieai-pentest`,
`openrouter`). Recon/scan-flavored text ("scan", "recon", "nmap", "pentest",
"cyberdeck", "subnet", "port scan") routes to `angieai-pentest` — see
`services/angieai-pentest/README.md` for the authorized-use-only guardrails
on that lane.

- `GET /health` — liveness check
- `POST /reason` — body: `{"text": "..."}`, returns `{"decision": ..., "lane": ...}`

## Build & run

```bash
docker build -t angieai-reasoner .
docker run -p 8001:8001 angieai-reasoner
curl -s -X POST http://localhost:8001/reason -H 'content-type: application/json' \
  -d '{"text": "build me an apk for the Q20"}'
# {"decision":"build","lane":"google-ai-studio"}
```

## Upgrading to a real rule engine

The current logic is plain if/elif routing. To go further, swap the body of
`reason()` in `app/main.py` for an [Experta](https://github.com/nilp0inter/experta)
ruleset (a Python CLIPS-like expert-system library) for proper forward-chaining
inference instead of hand-written keyword checks.
