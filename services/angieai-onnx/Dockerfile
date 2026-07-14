FROM python:3.11-slim
WORKDIR /app
RUN pip install --no-cache-dir fastapi uvicorn onnxruntime numpy
COPY app /app/app
# Place your exported model.onnx next to this Dockerfile before building,
# or mount it at runtime via MODEL_PATH.
COPY model.onnx /app/model.onnx
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
