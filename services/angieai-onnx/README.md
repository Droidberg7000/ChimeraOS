# angieai-onnx

Minimal ONNX Runtime inference service for AngieAI's local model lane.

- `GET /health` — liveness check
- `POST /predict` — body: `{"input": [...]}`, returns `{"output": [...]}`

## Default model (verified working)

A real `model.onnx` now ships in this folder by default — the classic
[ONNX Model Zoo MNIST digit classifier](https://huggingface.co/onnxmodelzoo/mnist-8)
(opset 8, ~26 KB, Apache-2.0-compatible/MIT-style ONNX Model Zoo license).
It's not AngieAI's real NLP brain — it exists so the local-inference lane is
no longer a stub: the container builds, `ort.InferenceSession` loads a real
graph, and `/predict` returns real tensor math instead of a "model not found"
error. This was verified end-to-end (FastAPI `TestClient`, `/health` +
`/predict`) before being committed.

Input/output shape for the default model: input `[1, 1, 28, 28]` float32
(a flattened 28x28 grayscale image), output `[1, 10]` float32 (digit logits
0-9). Example:

```bash
python3 - <<'PY'
import json, numpy as np
print(json.dumps({"input": np.zeros((1,1,28,28), dtype=np.float32).tolist()}))
PY
# pipe that JSON into:
curl -s -X POST http://localhost:8000/predict -H 'content-type: application/json' -d @-
```

### Swapping in AngieAI's real model

When a proper text/intent model is ready (e.g. a tiny distilled
sentiment/intent classifier or embedding model exported to ONNX), just
replace `model.onnx` with it — the FastAPI wrapper is shape-agnostic, it
only needs `input` to match whatever tensor shape the new model's first
input expects. If the new model needs tokenization before inference, add
that preprocessing step in `app/main.py::predict()` before calling
`sess.run(...)`.

## Build & run

```bash
docker build -t angieai-onnx .
docker run -p 8000:8000 angieai-onnx
curl -v http://localhost:8000/health
```

If `model.onnx` is ever removed/missing, this service is a placeholder
shell — AngieAI should treat that as "local inference lane unavailable,
fall back to OpenRouter" rather than an error the user needs to fix
immediately.

## Optional: TorchServe path

For managed multi-model serving instead of this single-model FastAPI shell:

```bash
torch-model-archiver -f \
  --model-name onnx \
  --version 1.0 \
  --serialized-file model.onnx \
  --export-path model_store \
  --handler onnx_handler.py

torchserve --start --model-store model_store --models onnx=onnx.mar
curl -v http://localhost:8080/predictions/onnx
```
