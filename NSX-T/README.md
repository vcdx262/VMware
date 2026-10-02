# NSX-T

NSX-T automation, configuration, and a deployment runbook. Consolidated from the former
standalone `NSXT` repository.

| File | Purpose |
|---|---|
| `nsx.cfg` | OVF-deployment property file for an NSX Manager lab appliance (passwords are placeholders — set before use) |
| `NSX-T-Overlay-Deployment-Guide.md` | Manager → fabric prep → edge/T0/T1 → first overlay segment runbook |

> Background includes NSX-V and NSX-T rule-set/group migrations and host-route–based IP
> migration (migrating in groups as small as one workload). See the repo root README.
