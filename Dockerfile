FROM python:3.12-slim

# 1. Install uv using the official binary to keep the layer clean
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 2. Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# 3. Install dependencies separately for better caching
# Using --no-install-project ensures we only install deps, not the app itself yet
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

# 4. Copy the application code
COPY . .

# 5. Sync the project (installs the current project)
RUN uv sync --frozen --no-dev

# 6. Place /app/.venv/bin at the front of the PATH
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 5001

# Use the venv directly for faster startup
CMD ["python", "app.py"]