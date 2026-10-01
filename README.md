# VMware

Automation and infrastructure-as-code from hands-on VMware work by **Steven Slocum** —
PowerCLI for day-to-day vSphere operations, plus Terraform for a VMware Cloud Foundation
(VCF) / VMware-on-cloud SDDC build. Drawn from real engagements and a persistent home lab;
sanitized for publication (lab values, placeholder secrets).

## Background behind this repo

Principal / senior VMware cloud solutions architect experience spanning vSphere, NSX
(NSX-V and NSX-T), vSAN, HCX-based DR and migration, vRealize/Aria and VMware-on-cloud
SDDCs. This includes NSX rule-set and group migrations, host-route–based IP migration
(migrating workloads in groups as small as one), and SDDC network integration on cloud
VMware platforms.

## Layout

| Folder | Contents | Status |
|---|---|---|
| [ESXI](ESXI/) | Host deploy (nested ESXi) and a broad host-config verification toolkit | **Populated** |
| [Networking](Networking/) | VDS + distributed portgroup automation; vSwitch/portgroup reporting | **Populated** |
| [VM-Provisioning](VM-Provisioning/) | CSV-driven Windows/Linux VM deployment from templates + customization specs | **Populated** |
| [vCenter](vCenter/) | Scripted VCSA (`vcsa-deploy`) deployment specs and command reference | **Populated** |
| [Hardware](Hardware/) | Dell iDRAC (Redfish) and Cisco UCS inventory/audit | **Populated** |
| [Lab](Lab/) | Windows/AD/DNS foundation for the vSphere home lab | **Populated** |
| [VCF](VCF/) | **Terraform IaC** for a VMware-on-cloud (OCVS/OCI) SDDC — network + SDDC modules, BOM, design decisions | **Populated** |
| [NSX-T](NSX-T/) | NSX-T config/automation (consolidated from the `NSXT` repo) | Seed |
| [HCX](HCX/) · [NSX-V](NSX-V/) · [Tanzu](Tanzu/) · [vSAN](vSAN/) | Intended scope | Planned stubs |

## Highlights

- **VCF / OCVS Terraform** ([VCF](VCF/)) — a typed, modular Terraform build of a
  VMware Cloud Foundation SDDC on Oracle Cloud VMware Solution: wizard-equal CIDR
  slicing, per-VLAN route tables and NSGs, a pinned software BOM, and an operator-supplied
  SSH key. See [VCF/docs/design-decisions.md](VCF/docs/design-decisions.md) and
  [VCF/docs/vcf-bom-5.2.4.md](VCF/docs/vcf-bom-5.2.4.md).
- **Host verification** ([ESXI/Verify-Hosts.ps1](ESXI/Verify-Hosts.ps1)) — one-pass config
  baseline across syslog, NTP, SNMP, VMkernel, VDS, datastores/SIOC, LUNs, HBAs, DNS,
  TCP/IP stacks and host authentication.
- **CSV-driven provisioning** ([VM-Provisioning](VM-Provisioning/)) — template +
  customization-spec deployment with full per-VM IPv4/IPv6 control.

## Using these scripts

- **PowerCLI** is required for the vSphere scripts (`Connect-VIServer` first). Several
  reporting scripts are operational snippets that expect an input collection (host list)
  to be populated in the session; each script's `.NOTES` says so. Edit the CSV / export
  paths near the top before running.
- **Terraform** (VCF): copy `infra/terraform.tfvars.example` → `terraform.tfvars`, fill in,
  then `terraform init && terraform validate && terraform plan`.
- Every script carries comment-based help — `Get-Help .\Script.ps1 -Full`.

## Note on provenance

Only the author's own work is included here. Scripts originally authored by others
(colleagues, vendors, or VMware Hands-on-Lab content) were deliberately excluded. vCenter
deployment JSON derives from VMware's published `vcsa-deploy` sample templates, noted as
such in [vCenter](vCenter/).

## License

[MIT](LICENSE).
