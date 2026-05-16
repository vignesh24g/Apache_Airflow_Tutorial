#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

AIRFLOW_HOME="${AIRFLOW_HOME:-$HOME/airflow}"
export AIRFLOW_HOME
mkdir -p "$AIRFLOW_HOME"

VENV_DIR="./airflow_env"
if [[ ! -d "$VENV_DIR" || ! -f "$VENV_DIR/bin/activate" ]]; then
  rm -rf "$VENV_DIR"
  python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"

pip install --upgrade pip setuptools wheel

AIRFLOW_VERSION="${AIRFLOW_VERSION:-2.10.2}"
PYTHON_VERSION="$(python3 --version | cut -d ' ' -f 2 | cut -d '.' -f 1-2)"
CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

pip install --upgrade "apache-airflow==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"

export AIRFLOW__WEBSERVER__WEB_SERVER_HOST="${AIRFLOW__WEBSERVER__WEB_SERVER_HOST:-0.0.0.0}"
export AIRFLOW__WEBSERVER__WEB_SERVER_PORT="${AIRFLOW__WEBSERVER__WEB_SERVER_PORT:-8080}"

if [[ -n "${AIRFLOW_BASE_URL:-}" ]]; then
  export AIRFLOW__WEBSERVER__BASE_URL="$AIRFLOW_BASE_URL"
elif [[ -n "${CODESPACE_NAME:-}" && -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-}" ]]; then
  export AIRFLOW__WEBSERVER__BASE_URL="https://${AIRFLOW__WEBSERVER__WEB_SERVER_PORT}-${CODESPACE_NAME}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
  echo "Detected Codespaces preview URL: ${AIRFLOW__WEBSERVER__BASE_URL}"
elif [[ -n "${CODESPACE_NAME:-}" ]]; then
  echo "WARNING: Running in Codespaces and AIRFLOW_BASE_URL is not set."
  echo "Set AIRFLOW_BASE_URL to your forwarded preview URL to avoid referrer host errors."
  echo "Example: export AIRFLOW_BASE_URL=\"https://8080-<id>.preview.app.github.dev\""
fi

echo "Airflow home: $AIRFLOW_HOME"
echo "Airflow base URL: ${AIRFLOW__WEBSERVER__BASE_URL:-not set}"

airflow standalone
