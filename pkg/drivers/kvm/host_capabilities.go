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
	"encoding/xml"
	"fmt"

	libvirt "github.com/libvirt/libvirt-go"
)

type domain struct {
	XMLName  xml.Name `xml:"domain"`
	TypeName string   `xml:"type,attr"`
}

type machine struct {
	XMLName       xml.Name `xml:"machine"`
	MaxCPUs       int      `xml:"maxCpus,attr"`
	CanonicalName *string  `xml:"canonical,attr"`
	Name          string   `xml:",chardata"`
}

type arch struct {
	XMLName  xml.Name  `xml:"arch"`
	Name     string    `xml:"name,attr"`
	WordSize *int      `xml:"wordsize"`
	Emulator *string   `xml:"emulator"`
	Loader   *string   `xml:"loader"`
	Machines []machine `xml:"machine"`
	Domains  []domain  `xml:"domain"`
}

type guest struct {
	XMLName xml.Name `xml:"guest"`
	OS      string   `xml:"os_type"`
	Arch    arch     `xml:"arch"`
}

type cpu struct {
	XMLName xml.Name `xml:"cpu"`
	Arch    string   `xml:"arch"`
	Model   string   `xml:"model"`
	Vendor  string   `xml:"vendor"`
}

type host struct {
	XMLName xml.Name `xml:"host"`
	UUID    string   `xml:"uuid"`
	CPU     cpu      `xml:"cpu"`
}

type HostCapabilities struct {
	XMLName xml.Name `xml:"capabilities"`
	Host    host     `xml:"host"`
	Guests  []*guest `xml:"guest"`
}

func GetHostCapabilities(conn *libvirt.Connect) (capabilities HostCapabilities, err error) {
	var xmlString string
	xmlString, err = conn.GetCapabilities()
	err = xml.Unmarshal([]byte(xmlString), &capabilities)
	fmt.Println("xml", capabilities.Host)
	return
}

func (h HostCapabilities) GetHostArch() string {
	return h.Host.CPU.Arch
}

func (h HostCapabilities) GetPlatformMachine(arch string) string {
	for _, guest := range h.Guests {
		if guest.Arch.Name == arch {
			switch arch {
			case "x86_64", "i686":
				for _, machine := range guest.Arch.Machines {
					if machine.Name == "q35" {
						return *machine.CanonicalName
					}
				}
				for _, machine := range guest.Arch.Machines {
					if machine.Name == "pc" {
						return *machine.CanonicalName
					}
				}
			case "aarch64":
				for _, machine := range guest.Arch.Machines {
					if machine.Name == "virt" {
						return *machine.CanonicalName
					}
				}
			}
		}
	}
	return "none"
}

func (h HostCapabilities) GetVirtualizationType(arch string) string {
	for _, guest := range h.Guests {
		if guest.Arch.Name == arch {
			var hasQemu, hasKvm bool
			for _, domain := range guest.Arch.Domains {
				if domain.TypeName == "kvm" {
					hasKvm = true
				} else if domain.TypeName == "qemu" {
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

func (h HostCapabilities) GetPlatformOSType(arch string) string {
	for _, guest := range h.Guests {
		if guest.Arch.Name == arch {
			return guest.OS
		}
	}
	return "none"
}
