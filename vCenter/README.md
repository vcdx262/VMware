# vCenter

vCenter Server Appliance (VCSA) deployment inputs and command reference.

The `*.json` files are **filled-in copies of VMware's own `vcsa-deploy` sample
templates** — used to drive scripted, repeatable VCSA deployments in the lab. All
passwords have been replaced with `__REPLACE_ME__`; set them (and adjust hostnames,
IPs and datastores for your environment) before use.

| File | Purpose |
|---|---|
| `DeployvCenter.json` | Embedded-PSC VCSA deploy spec (lab) |
| `deploytinylabvc.json` | Minimal "tiny" lab VCSA |
| `titanvc.json`, `titan1-vc-70.json` | Lab VCSA specs (named lab environments) |
| `k1-vcenterA.json` | Lab site-A VCSA spec |
| `vCenter-Deployment-Command.txt` | The `vcsa-deploy install` command/flags used to drive the above |

> The JSON schema and comments originate from VMware's vCenter Server Appliance
> installer samples; the values are lab-specific inputs.
