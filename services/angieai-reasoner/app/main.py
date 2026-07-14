"""
AngieAI rule-based reasoner service.

Deterministic if-then routing/classification layer — the "text CPU" logic
AngieAI leans on before deciding which lane (local ONNX, OpenRouter model,
dmux sub-agent, Google AI Studio) should handle a task. Kept dependency-light
on purpose; swap the body of `reason()` for an Experta ruleset if you want a
full CLIPS-style engine later.
"""
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="AngieAI reasoner service")


class Query(BaseModel):
    text: str


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/reason")
def reason(q: Query):
    text = q.text.lower()

    if "urgent" in text or "asap" in text:
        return {"decision": "priority", "lane": "AngieAI-local"}
    if "login" in text or "auth" in text or "security" in text:
        return {"decision": "security", "lane": "AngieAI-local"}
    if "build" in text or "apk" in text or "bar" in text or "android" in text:
        return {"decision": "build", "lane": "google-ai-studio"}
    if "branch" in text or "worktree" in text or "merge" in text or "ci" in text:
        return {"decision": "dev-workflow", "lane": "dmux"}
    if "model" in text or "predict" in text or "inference" in text:
        return {"decision": "inference", "lane": "angieai-onnx"}

    return {"decision": "default", "lane": "openrouter"}
