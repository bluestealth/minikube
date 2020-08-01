// +build linux

/*
Copyright 2020 The Kubernetes Authors All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package kvm

import (
	"regexp"
	"strings"

	libvirt "github.com/libvirt/libvirt-go"
	libvirtxml "github.com/libvirt/libvirt-go-xml"
)

func GetHostCapabilities(conn *libvirt.Connect) (capabilities libvirtxml.Caps, err error) {
	var xmlString string
	xmlString, err = conn.GetCapabilities()
	if err != nil {
		return
	}
	err = capabilities.Unmarshal(xmlString)
	return
}

func GetDomainCapabilities(conn *libvirt.Connect, emulator, arch, machine, virtType string) (capabilities libvirtxml.DomainCaps, err error) {
	var xmlString string
	xmlString, err = conn.GetDomainCapabilities(emulator, arch, machine, virtType, 0)
	if err != nil {
		return
	}
	err = capabilities.Unmarshal(xmlString)
	return
}

func GetPlatformMachine(h libvirtxml.Caps, arch string) string {
	for _, guest := range h.Guests {
		if guest.Arch.Name == arch {
			switch arch {
			case "x86_64":
				for _, machine := range guest.Arch.Machines {
					if machine.Name == "q35" {
						return machine.Canonical
					}
				}
				for _, machine := range guest.Arch.Machines {
					if machine.Name == "pc" {
						return machine.Canonical
					}
				}
			case "aarch64":
				for _, machine := range guest.Arch.Machines {
					if machine.Name == "virt" {
						return machine.Canonical
					}
				}
			case "ppc64", "ppc64le":
				for _, machine := range guest.Arch.Machines {
					if machine.Name == "pseries" {
						return machine.Canonical
					}
				}
			}
		}
	}
	return "none"
}

func GetVirtualizationType(h libvirtxml.Caps, arch string) string {
	for _, guest := range h.Guests {
		if guest.Arch.Name == arch {
			var hasQemu, hasKvm bool
			for _, domain := range guest.Arch.Domains {
				if domain.Type == "kvm" {
					hasKvm = true
				} else if domain.Type == "qemu" {
					hasQemu = true
				}
			}
			if hasKvm {
				return "kvm"
			} else if hasQemu {
				return "qemu"
			}
		}
	}
	return "none"
}

func GetPlatformOSType(h libvirtxml.Caps, arch string) string {
	for _, guest := range h.Guests {
		if guest.Arch.Name == arch {
			return guest.OSType
		}
	}
	return "none"
}

func DomainHasNVRAM(dom *libvirt.Domain) (hasNvram bool, err error) {
	xmlString, err := dom.GetXMLDesc(0)
	if err != nil {
		return
	}
	var domain libvirtxml.Domain
	err = domain.Unmarshal(xmlString)
	if err != nil {
		return
	}
	hasNvram = domain.OS.NVRam != nil
	return
}

func GetLoader(osLoader *libvirtxml.DomainCapsOSLoader, platform string) (loader string) {
	if osLoader == nil || len(osLoader.Values) == 0 {
		return
	}
	var re *regexp.Regexp
	// libvirt isn't very intelligent about the loaders it lists for platforms
	switch platform {
	case "x86_64":
		re = regexp.MustCompile("OVMF|ovmf|x86_64|x64")
	case "aarch64":
		re = regexp.MustCompile("AAVMF|aarch64")
	default:
		return
	}
	for _, osLoader := range osLoader.Values {
		// our efi binaries are not signed, prefer unsigned loaders
		if re.MatchString(osLoader) && (loader == "" || !strings.Contains(osLoader, "secure")) {
			loader = osLoader
		}
	}
	return
}
