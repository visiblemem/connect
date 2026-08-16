# Security Policy

Connect provides authorized remote administration. Do not deploy it as an open relay or install an Agent without the device owner's explicit consent.

## Supported deployment

- The server listens on `127.0.0.1:8443` only.
- External access terminates TLS through an authenticated, owner-controlled tunnel.
- New account registration is disabled immediately after creating the first administrator.
- Every administrator enables multi-factor authentication.
- Runtime data and `config.json` remain outside Git.

## Reporting

Do not post credentials, certificates, Agent invitation links, database files, tunnel tokens, screenshots containing device IDs, or sanitized-looking configuration without checking it carefully.

For an upstream MeshCentral vulnerability, follow the reporting instructions in the [MeshCentral repository](https://github.com/Ylianst/MeshCentral/security).
