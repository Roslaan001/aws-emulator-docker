# AWS Emulator Docker

[![Build & Publish Multi-Arch Image](https://github.com/Roslaan001/aws-emulator-docker/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/Roslaan001/aws-emulator-docker/actions/workflows/build-and-push.yml)
[![GitHub release](https://img.shields.io/github/v/release/Roslaan001/aws-emulator-docker?include_prereleases)](https://github.com/Roslaan001/aws-emulator-docker/releases)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

An automated, multi-architecture (`linux/amd64` and `linux/arm64`) container image for the **official AWS Emulator**.

> **Why this image exists**: AWS does not currently publish a pre-built container image to Docker Hub or ECR Public; they instruct users to compile their own image using an RPM. This repository automates that packaging directly from official AWS sources, providing multi-arch container images ready to pull into your local development workflows and CI/CD pipelines.

---

## 📦 Pull the Image

Available across three major container registries:

### GitHub Container Registry (GHCR)
```bash
docker pull ghcr.io/roslaan001/aws-emulator:latest
```

### Docker Hub
```bash
docker pull abdulsomad005/aws-emulator:latest
```

### Amazon ECR Public
```bash
docker pull public.ecr.aws/t4e4a3g4/aws-emulator:latest
```

### 🏷️ Versioning Strategy
To protect your CI pipelines from breaking unexpectedly when upstream AWS releases updates, we publish immutable version tags for every release:

* **`:0.0.1`** (or your pinned release tag) — 🟢 **Immutable**. Recommended for CI pipelines and production testing to guarantee 100% reproducible test runs.
* **`:latest`** — 🔴 **Floating**. Automatically tracks the latest upstream AWS updates.

For CI pipelines, pinning `:0.0.1` ensures tests never fail unexpectedly from upstream changes:
```bash
docker pull ghcr.io/roslaan001/aws-emulator:0.0.1
```

---

## 🚀 Quick Start

### 1. Run with Docker CLI
```bash
docker run --rm -d \
  --name aws-emulator \
  -p 127.0.0.1:9297:9297 \
  ghcr.io/roslaan001/aws-emulator:latest
```

### 2. Run with Docker Compose
Save this as `docker-compose.yml`:
```yaml
services:
  aws-emulator:
    image: ghcr.io/roslaan001/aws-emulator:latest
    ports:
      - "127.0.0.1:9297:9297"
    command: ["-b", "0.0.0.0", "-p", "9297", "-a", "off", "-t", "off"]
```
Run:
```bash
docker compose up -d
```

### 3. Check Health
```bash
curl -vk https://127.0.0.1:9297/__admin/health
# Returns: 200 OK (ok)
```

---

## 🔒 TLS & Certificate Trust

The AWS Emulator runs over **HTTPS** by default and generates an internal self-signed Certificate Authority (CA) on startup.

### Extract and Trust the CA in CI / Tests
```bash
# 1. Copy the generated root CA from the container
docker cp aws-emulator:/home/emulator/.aws/emulator/9297/ca.pem /tmp/aws-emulator-ca.pem

# 2. Configure AWS SDK or CLI to trust it
export AWS_CA_BUNDLE=/tmp/aws-emulator-ca.pem
export AWS_ENDPOINT_URL=https://127.0.0.1:9297
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test

# Example AWS CLI call:
aws ecs list-clusters
```

---

## ⚙️ Configuration & Flags

The container runs `aws-emulator` as entrypoint. Supported parameters:

| Flag | Description | Default in Container |
| :--- | :--- | :--- |
| `-b, --bind <ip>` | Address to bind (`0.0.0.0` or `127.0.0.1`) | `0.0.0.0` |
| `-p, --port <port>` | Port to listen on | `9297` |
| `-a, --auth on\|off` | Enforce SigV4 authentication signatures | `off` (accepts test keys) |
| `-t, --telemetry on\|off` | Telemetry reporting to AWS | `off` |
| `--idle-timeout <secs>` | Exit container after idle timeout | Disabled |

---

## 🛡️ Software Supply Chain & Provenance

We take container security and provenance seriously:
- **Base Image**: Official `public.ecr.aws/amazonlinux/amazonlinux:2023-minimal`.
- **Upstream Source**: Fetches the official AWS RPM directly from `https://downloads.aws.com/aws-emulator/packages/aws-emulator/LTS/latest/`.
- **Non-Root**: Runs under an unprivileged user (`1000:1000`).
- **Attestation**: GitHub Actions cryptographically signs and generates build provenance attestations for all pushed container images.
- **Automated Tracking**: A weekly GitHub Actions cron checks for new AWS LTS RPM updates and publishes fresh tags automatically.

---

## ⚠️ Important: The IAM Authorization Trap

As documented by AWS, **the AWS Emulator does not evaluate IAM policies for authorization.**

- You can call `iam:CreateRole` and attach pre-seeded AWS managed policies.
- However, **all requests will succeed regardless of permissions defined in statements or conditions**.
- **Do not rely on this emulator for IAM permission audits.** Use the **AWS IAM Policy Simulator** (`aws iam simulate-principal-policy`) or real cloud smoke tests for security verification.

---

## 📄 License

- This packaging automation repository is licensed under the [Apache 2.0 License](LICENSE).
- The underlying AWS Emulator binary and packages are distributed and copyrighted by **Amazon Web Services, Inc.**
