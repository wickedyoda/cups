# cups

Dockerized CUPS server with configurable admin credentials, USB passthrough, and health checks.

## Quick start (Docker Compose)

```bash
export CUPS_ADMIN_USER=admin
export CUPS_ADMIN_PASSWORD=change-me

docker compose up --build -d
```

Then open <http://localhost:631> and sign in with the admin credentials.

## Environment variables

- `CUPS_ADMIN_USER`: username created inside the container (default `admin`).
- `CUPS_ADMIN_PASSWORD`: password for the admin user (default `admin`).

## USB passthrough

The `docker-compose.yml` configuration maps USB devices into the container:

- `/dev/bus/usb` for general USB access
- `/dev/usb/lp0` for older parallel-style USB printer nodes

If your host uses a different device node, update the `devices` section accordingly.

## Health checks

The container uses HTTP health checks against `http://localhost:631/`.

## Standalone Docker run

```bash
docker build -t cups .

docker run -d \
  --name cups \
  -p 631:631 \
  -e CUPS_ADMIN_USER=admin \
  -e CUPS_ADMIN_PASSWORD=change-me \
  --device /dev/bus/usb:/dev/bus/usb \
  --device /dev/usb/lp0:/dev/usb/lp0 \
  cups
```
