# NSX-T Overlay Deployment Guide — manager to first overlay segment

**Why this exists:** a concise runbook for standing up NSX-T on a prepared vSphere cluster
and getting a working overlay segment, Tier-0 and Tier-1 — the foundation for
micro-segmentation and multi-site networking.

> Lab values throughout (`lab.local`, RFC1918). The `nsx.cfg` in this folder is an OVF
> property file for deploying the NSX Manager appliance — set the placeholder passwords
> before use.

## 0. Ground truth (fill in)

| | |
|---|---|
| NSX Manager | `nsxmgr.lab.local` (3-node cluster in production) |
| Compute cluster | `Cluster-A` (prepared for NSX) |
| Overlay TZ / VLAN TZ | `tz-overlay` / `tz-vlan` |
| Edge nodes | 2x medium/large for T0 |
| Uplink / TEP VLANs | per your fabric |

## 1. Deploy NSX Manager

Deploy the NSX Manager OVF (see [`nsx.cfg`](nsx.cfg) for the property set), form the
management cluster, and license.

## 2. Prepare the fabric

1. Add vCenter as a Compute Manager.
2. Create **transport zones** (overlay + VLAN).
3. Create **uplink** and **TEP** profiles; configure the TEP IP pool.
4. Prepare the cluster as **transport nodes** (installs the NSX host switch).

## 3. Edge + routing

1. Deploy **edge transport nodes**; form an edge cluster.
2. Create a **Tier-0** gateway; configure uplinks + BGP/static to the physical fabric.
3. Create a **Tier-1** gateway linked to the T0; enable route advertisement.

## 4. First overlay segment

1. Create an **overlay segment** attached to the T1 (e.g. `seg-app  10.10.20.0/24`).
2. Attach a test VM; confirm east-west and north-south reachability.

## 5. Verify

- Transport node tunnels **Up** (manager → System → Fabric → Nodes).
- T0/T1 routes advertised; test VM reaches its gateway and beyond.
- Micro-segmentation: apply a DFW rule and confirm enforcement.

> **Background:** real-world NSX experience behind this includes NSX-V and NSX-T
> rule-set/group migrations and host-route–based IP migration (migrating in groups as
> small as one workload). See the repo root README.
