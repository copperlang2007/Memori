# Multi-stage Dockerfile for Memori SDK
FROM python:3.11-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Create app directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Production stage
FROM base as production

# Copy requirements first for better caching
COPY requirements.txt requirements-dev.txt ./
COPY pyproject.toml ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY memori/ ./memori/
COPY README.md LICENSE ./

# Install the package
RUN pip install --no-cache-dir -e .

# Create a non-root user
RUN useradd -m -u 1000 memori && \
    chown -R memori:memori /app

USER memori

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import memori; print(memori.__version__)" || exit 1

CMD ["python"]

# Demo apps stage - for running Streamlit demos
FROM base as demos

# Copy requirements
COPY requirements.txt ./
COPY pyproject.toml ./

# Install base dependencies and streamlit
RUN pip install --no-cache-dir -r requirements.txt streamlit pandas plotly

# Copy application code
COPY memori/ ./memori/
COPY demos/ ./demos/
COPY README.md LICENSE ./

# Install the package
RUN pip install --no-cache-dir -e .

# Create non-root user
RUN useradd -m -u 1000 memori && \
    chown -R memori:memori /app

USER memori

EXPOSE 8501

# Default to running personal diary assistant
CMD ["streamlit", "run", "demos/personal_diary_assistant/streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]

# Documentation stage - for building and serving docs
FROM base as docs

# Copy requirements and install mkdocs dependencies
COPY requirements.txt ./
COPY pyproject.toml ./

RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir \
    mkdocs>=1.5.0 \
    mkdocs-material>=9.0.0 \
    mkdocs-git-revision-date-localized-plugin>=1.2.0 \
    mkdocs-minify-plugin>=0.7.0 \
    mkdocs-redirects>=1.2.0

# Copy docs and config
COPY docs/ ./docs/
COPY mkdocs.yml ./
COPY README.md LICENSE ./

# Build the documentation
RUN mkdocs build

# Serve documentation
EXPOSE 8000
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8000"]
