# ==========================================
# STAGE 1: The Builder
# ==========================================
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .

# Install build dependencies (needed if wheels must compile from source)
# and install python packages directly into a localized folder (--user)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --upgrade pip \
    && python -m pip install --no-cache-dir --user -r requirements.txt

# ==========================================
# STAGE 2: The Final Runtime
# ==========================================
FROM python:3.12-slim AS runner

WORKDIR /app

# Copy the compiled Python site-packages from the builder stage
# Default path for --user flag install is /root/.local
COPY --from=builder /root/.local /root/.local
COPY . .

# Ensure the runner's Python binary can find the copied packages
ENV PATH=/root/.local/bin:$PATH

EXPOSE 5001

CMD ["python", "app.py"]
