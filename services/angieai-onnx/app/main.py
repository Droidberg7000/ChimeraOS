"""
AngieAI ONNX inference service.

Lightweight FastAPI wrapper around ONNX Runtime — the "model runtime" lane
AngieAI can call when it needs a local neural inference step instead of a
remote model call. Drop your exported model at services/angieai-onnx/model.onnx
before building the image.
"""
from fastapi import FastAPI, HTTPException
import onnxruntime as ort
import numpy as np
import os

MODEL_PATH = os.environ.get("MODEL_PATH", "model.onnx")

app = FastAPI(title="AngieAI ONNX service")

_session = None


def get_session():
    global _session
    if _session is None:
        if not os.path.exists(MODEL_PATH):
            raise RuntimeError(f"Model not found at {MODEL_PATH}")
        _session = ort.InferenceSession(MODEL_PATH, providers=["CPUExecutionProvider"])
    return _session


@app.get("/health")
def health():
    return {"ok": True}


@app.post("/predict")
def predict(payload: dict):
    try:
        sess = get_session()
        x = np.array(payload["input"], dtype=np.float32)
        inputs = {sess.get_inputs()[0].name: x}
        y = sess.run(None, inputs)
        return {"output": [o.tolist() if hasattr(o, "tolist") else o for o in y]}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
