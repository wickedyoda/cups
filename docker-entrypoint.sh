#!/usr/bin/env bash
set -euo pipefail

CUPS_ADMIN_USER="${CUPS_ADMIN_USER:-}"
CUPS_ADMIN_PASSWORD="${CUPS_ADMIN_PASSWORD:-}"

if [[ -n "${CUPS_ADMIN_USER}" && -n "${CUPS_ADMIN_PASSWORD}" ]]; then
  if ! id "${CUPS_ADMIN_USER}" >/dev/null 2>&1; then
    useradd --create-home --shell /bin/bash --groups lpadmin "${CUPS_ADMIN_USER}"
  fi
  echo "${CUPS_ADMIN_USER}:${CUPS_ADMIN_PASSWORD}" | chpasswd
fi

CUPSD_CONF="/etc/cups/cupsd.conf"

if [[ -f "${CUPSD_CONF}" ]]; then
  if grep -q "^Listen localhost:631" "${CUPSD_CONF}"; then
    sed -i "s/^Listen localhost:631/Listen 0.0.0.0:631/" "${CUPSD_CONF}"
  elif ! grep -q "^Listen 0.0.0.0:631" "${CUPSD_CONF}"; then
    echo "Listen 0.0.0.0:631" >> "${CUPSD_CONF}"
  fi

  if ! grep -q "^WebInterface Yes" "${CUPSD_CONF}"; then
    echo "WebInterface Yes" >> "${CUPSD_CONF}"
  fi

  if ! grep -q "^DefaultAuthType Basic" "${CUPSD_CONF}"; then
    echo "DefaultAuthType Basic" >> "${CUPSD_CONF}"
  fi

  if ! grep -q "<Location /admin>" "${CUPSD_CONF}"; then
    cat <<'BLOCK' >> "${CUPSD_CONF}"

<Location /admin>
  Order allow,deny
  Allow all
  Require user @SYSTEM
</Location>
BLOCK
  fi

  if ! grep -q "<Location /admin/conf>" "${CUPSD_CONF}"; then
    cat <<'BLOCK' >> "${CUPSD_CONF}"

<Location /admin/conf>
  Order allow,deny
  Allow all
  Require user @SYSTEM
</Location>
BLOCK
  fi
fi

exec "$@"
