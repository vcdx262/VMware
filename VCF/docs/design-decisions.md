# Design Decisions

Decisions carried from the August 2026 wizard-parity review of `ocvs-deployment` (internal wizard-parity review). Each entry: decision, and what it fixes.

## D1 — Terraform for the OCI layer

The PowerShell scripts' create-if-null-in-state pattern duplicates billable infrastructure on lost state and cannot detect drift (review finding, HIGH). Terraform's refresh/plan/import model retires that class of problem. PowerShell/PowerCLI remains the tool for in-SDDC and day-2 work.

## D2 — Wizard-equal CIDR slicing, derived not hardcoded

One `sddc_cidr` variable (default `10.10.0.0/21`) is sliced into **16 equal prefix+4 segments** with `cidrsubnet()`, exactly the console wizard's slicing at every supported size (/21 → /25 … /24 → /28). Fixes: hardcoded unequal /24s + /29s; the /29 edge uplinks that fell below the wizard's /28 minimum on the immutable, publication-critical VLANs. Per the wizard's sizing table, /24 supports up to 12 hosts and /21 up to 64. Containment of `sddc_cidr` inside `vcn_cidr` is enforced by a precondition on the VCN.

## D3 — Per-VLAN route tables and NSGs

One route table and one NSG per VLAN, wizard-parity, so Oracle's day-2 connectivity quick actions (DRG, Service Gateway/OSN, internet publication on Edge Uplink 1) target one segment's table without touching the rest. Fixes: the single shared two-rule table that made every day-2 workflow structurally impossible.

## D4 — NAT default route only where Oracle prescribes it

`0.0.0.0/0 → NAT` on the vSphere VLAN (the OCVS/HCX sanity-check requirement) and Edge Uplink 1 (workload egress). All other segments (vSAN, vMotion, TEPs, replication, HCX, provisioning) get empty route tables, matching wizard create-time output. Fixes: internet egress from storage/data-plane segments.

## D5 — Public management is an opt-in module, off by default

The lab's public vCenter/NSX pattern (reserved public IPs + admin-/32 IGW return route + 443-only management NSG) survives as `enable_public_management`, scoped to the vSphere VLAN's route table only. Default `false` = wizard baseline (no IGW route, nothing public). Never enable outside the lab.

## D6 — Pinned versions as required inputs

`vmware_software_version` and `esxi_software_version` are pinned variables (defaults = the proven `8.0 update 3` / `esxi8u3k-25595708-1`). Fixes: last-list-position artifact selection that could silently deploy a different build per rebuild.

## D7 — Operator-supplied SSH key

`ssh_authorized_keys` is a required input; nothing generates key material. Fixes: silent reuse/generation of the operator's personal passphrase-less `id_rsa`.

## D8 — Typed output contract

Layer 0 publishes `sddc_id`, vCenter/NSX/HCX FQDNs and private-IP OCIDs, all VLAN OCIDs, subnet/NSG IDs, and the BYOL allocation ID as Terraform outputs. Downstream layers consume `terraform output -json`, never a hand-rolled state file. Fixes: downstream modules parsing `sddc_state.json` directly.

## D9 — Provisioning subnet is private

`prohibit_public_ip_on_vnic = true` on the provisioning subnet, and no dead admin-/32 rules in its security list. Fixes: the review's public-IP-capable subnet + dead-rule drift.

## D10 — Single-host is a variable, not an architecture

`esxi_hosts_count` / `is_single_host_sddc` are inputs. The single-host lab (52-unit BYOL) is the default `tfvars`, but a 3-host deployment is a variable change, not a code fork. (An existing single-host SDDC still cannot be upgraded in place — that's an OCVS constraint; this just makes the rebuild cheap.)
