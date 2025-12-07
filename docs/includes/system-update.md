!!! tip "System Update & Dependencies"
Unless the `--no-update` flag is passed, this component performs:

```
- Package index refresh (`apt update`)
- Installation of foundational packages:
    - `curl`
    - `wget`
    - `ca-certificates`
    - `gnupg`
    - `lsb-release`
    - `net-tools`
    - `tree`
    - `jq`

These are required for:
- Secure repository access  
- TLS certificate validation  
- Environment detection  
- Network discovery tools  
- Modern CLI operations  
```
