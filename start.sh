#!/usr/bin/env bash
# =============================================================================
# setup_airflow.sh — Airflow Standalone for GitHub Codespaces (or local)
# Usage: bash setup_airflow.sh
# =============================================================================
set -euo pipefail
cd "$(dirname "$0")"

# ── Colour helpers ────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Config ────────────────────────────────────────────────────────────────────
AIRFLOW_VERSION="${AIRFLOW_VERSION:-2.10.2}"
PROJECT_DIR="$(pwd)"   
AIRFLOW_HOME="${AIRFLOW_HOME:-$PROJECT_DIR/airflow}"
VENV_DIR="$(pwd)/airflow_env"
PORT="${AIRFLOW__WEBSERVER__WEB_SERVER_PORT:-8080}"

export AIRFLOW_HOME
mkdir -p "$AIRFLOW_HOME"

# ── 1. Python virtual environment ─────────────────────────────────────────────
info "Setting up Python virtual environment at $VENV_DIR …"
if [[ ! -f "$VENV_DIR/bin/activate" ]]; then
  rm -rf "$VENV_DIR"
  python3 -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

pip install --quiet --upgrade pip setuptools wheel

# ── 2. Install Airflow with constraints ───────────────────────────────────────
PYTHON_VERSION="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

info "Installing Apache Airflow ${AIRFLOW_VERSION} (Python ${PYTHON_VERSION}) …"
pip install --quiet \
  "apache-airflow==${AIRFLOW_VERSION}" \
  --constraint "${CONSTRAINT_URL}"

# ── 3. Resolve Base URL (the critical Codespaces fix) ─────────────────────────
#
# GitHub Codespaces forwards ports via:
#   https://{PORT}-{CODESPACE_NAME}.{GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}
#
# Airflow's webserver checks the HTTP Host/Referer header and rejects requests
# that don't match BASE_URL — so we MUST set this to the forwarded URL.
# We also enable proxy-fix so Airflow trusts X-Forwarded-* headers from the
# Codespaces reverse proxy.

if [[ -n "${AIRFLOW_BASE_URL:-}" ]]; then
  # Explicit override — highest priority
  BASE_URL="$AIRFLOW_BASE_URL"
  info "Using user-supplied AIRFLOW_BASE_URL: $BASE_URL"

elif [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
  # Auto-detect from Codespaces environment variables
  BASE_URL="https://${PORT}-${CODESPACE_NAME}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
  info "Detected Codespaces — base URL: $BASE_URL"

elif [[ -n "${CODESPACE_NAME:-}" ]]; then
  # CODESPACE_NAME present but forwarding domain missing (older Codespaces)
  BASE_URL="https://${PORT}-${CODESPACE_NAME}.preview.app.github.dev"
  warn "GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN not set; guessing: $BASE_URL"
  warn "If the UI errors, set: export AIRFLOW_BASE_URL=<your forwarded URL>"

else
  # Local / non-Codespaces
  BASE_URL="http://localhost:${PORT}"
  info "Running locally — base URL: $BASE_URL"
fi

# ── 4. Export ALL required Airflow env vars ───────────────────────────────────
#
# Airflow reads AIRFLOW__{SECTION}__{KEY} at runtime; no airflow.cfg edits needed.

# Webserver
export AIRFLOW__WEBSERVER__WEB_SERVER_HOST="0.0.0.0"
export AIRFLOW__WEBSERVER__WEB_SERVER_PORT="$PORT"
export AIRFLOW__WEBSERVER__BASE_URL="$BASE_URL"

# Proxy fix — MUST be enabled so Airflow trusts X-Forwarded-Proto/Host
# from the Codespaces reverse proxy; without this you get "CSRF / host mismatch" errors.
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX="True"
export AIRFLOW__WEBSERVER__PROXY_FIX_X_FOR="1"
export AIRFLOW__WEBSERVER__PROXY_FIX_X_PROTO="1"
export AIRFLOW__WEBSERVER__PROXY_FIX_X_HOST="1"
export AIRFLOW__WEBSERVER__PROXY_FIX_X_PORT="1"
export AIRFLOW__WEBSERVER__PROXY_FIX_X_PREFIX="1"

# Core
export AIRFLOW__CORE__LOAD_EXAMPLES="False"          # skip noisy example DAGs
export AIRFLOW__CORE__EXECUTOR="SequentialExecutor"  # standalone default; no extra deps

# Database (SQLite — fine for standalone)
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="sqlite:///${AIRFLOW_HOME}/airflow.db"

# ── 5. Summary before launch ──────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info  "AIRFLOW_HOME : $AIRFLOW_HOME"
info  "Base URL     : $BASE_URL"
info  "Port         : $PORT"
info  "Python       : $PYTHON_VERSION"
info  "Airflow ver  : $AIRFLOW_VERSION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ -n "${CODESPACE_NAME:-}" ]]; then
  warn "In Codespaces: make sure port ${PORT} is set to PUBLIC (or at least"
  warn "forwarded) in the Ports tab, otherwise the browser preview will 403."
  echo ""
fi

info "Starting Airflow standalone (Ctrl-C to stop) …"
info "The admin password will appear in the log below — look for:"
info "  'standalone | Login with username: admin  password: XXXX'"
echo ""

# ── 6. Launch ─────────────────────────────────────────────────────────────────
exec airflow standalone
