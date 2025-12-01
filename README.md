# ⭐ **QEMU-Compose — Lightweight QEMU Orchestrator (Docker-Compose Style)**

Create and manage virtual machines using a simple YAML file.

QEMU-Compose allows you to:

* Start/stop VMs using `qemu-compose up` / `qemu-compose down`
* Configure CPUs, memory, architecture, disks, networks
* Boot from ISO
* Create mobile-like ARM devices (Android-style)
* Fake hardware identity (IMEI, serial, vendor, model, MAC addresses)
* Add touchscreen display, mobile resolution, sensors
* Use KVM acceleration when available
* Auto fallback to TCG when KVM not present
* Manage monitor sockets and logs
* Use safe defaults when options are not defined

---

# 📦 **Installation**

```bash
git clone https://github.com/yourname/qemu-compose
cd qemu-compose
sudo chmod +x install.sh
sudo ./install.sh
```

This installs:

* `~/.local/bin/qemu-compose`
* Required folders
* Permissions fix

Run:

```bash
qemu-compose -h
```

---

# 📘 **Basic Usage**

Start VMs:

```bash
qemu-compose up
```

Stop VMs:

```bash
qemu-compose down
```

Use a custom file:

```bash
qemu-compose -f myvms.yml up
```

---

# 🧩 **YAML Structure Overview**

```yaml
version: "2.0"

vms:
  <vm_name>:
    arch: x86_64 | aarch64 | riscv64 | arm | ppc64
    machine: q35 | pc | virt | raspi3 | virt-2.12
    cpus: 2
    cpu_model: host | max | cortex-a57
    memory: 2048

    # Optional hardware identity
    hardware:
      vendor: "Samsung"
      model: "Galaxy S22"
      board: "SM-S901"
      serial: "A15578BXY9931"
      imei: "355555112233444"
      mac_wifi: "02:11:22:33:44:55"
      mac_bt: "02:22:33:44:55:66"

    # Display config
    display:
      type: gtk
      width: 1080
      height: 2400
      dpi: 420
      touchscreen: true

    # Networking
    networks:
      - type: user
        forwards:
          - host_port: 2222
            guest_port: 22

    # Boot order
    boot:
      - cdrom
      - disks

    # Disk devices
    disks:
      - path: ./alpine.qcow2
        format: qcow2
        interface: virtio

    # ISO image
    cdrom:
      path: ~/isos/alpine.iso
      interface: ide

    # Android-specific extras
    sensors:
      gps: true
      accelerometer: true
      gyroscope: true

    modem:
      enabled: true
      imei: "355112233445566"
      iccid: "8991101200003204512"
      imsi: "404445557777777"

    gps:
      enabled: true
      source: "./gps-feed.nmea"

    kernel:
      path: ./Image
      dtb: ./devicetree.dtb
      cmdline: "console=ttyAMA0 root=/dev/vda"
```

---

# 🎮 **Example 1 — Standard PC (x86_64)**

```yaml
version: "2.0"

vms:
  pc1:
    arch: x86_64
    machine: q35
    cpus: 4
    cpu_model: host
    memory: 4096

    display:
      type: gtk

    networks:
      - type: user
        forwards:
          - host_port: 2222
            guest_port: 22

    disks:
      - path: ./debian.qcow2
        format: qcow2
        interface: virtio

    cdrom:
      path: ~/isos/debian-12.iso
      interface: ide

    boot:
      - cdrom
      - disks
```

---

# 📱 **Example 2 — Android-like Mobile Device (ARM64)**

```yaml
version: "2.0"

vms:
  android_phone:
    arch: aarch64
    machine: virt
    cpus: 8
    cpu_model: cortex-a57
    memory: 6144

    # Mobile identity
    hardware:
      vendor: "Samsung"
      model: "Galaxy S22"
      board: "SM-S901"
      serial: "A15578BXY9931"
      imei: "355555112233444"
      mac_wifi: "02:11:22:33:44:55"
      mac_bt: "02:22:33:44:55:66"

    display:
      type: gtk
      width: 1080
      height: 2400
      dpi: 420
      touchscreen: true

    sensors:
      gps: true
      accelerometer: true
      gyroscope: true

    modem:
      enabled: true
      imei: "355555112233444"
      iccid: "8991101200003204512"
      imsi: "404445557777777"

    gps:
      enabled: true
      source: ./gps-track.nmea

    networks:
      - type: user

    disks:
      - path: ./android.qcow2
        interface: virtio

    kernel:
      path: ./Image
      dtb: ./android.dtb
      cmdline: "console=ttyAMA0 androidboot.hardware=qemu"
```

---

# 💽 **Example 3 — Boot from ISO Only**

```yaml
version: "2.0"

vms:
  liveos:
    arch: x86_64
    machine: pc
    cpus: 2
    memory: 2048

    boot:
      - cdrom

    cdrom:
      path: ~/isos/ubuntu.iso
```

---

# 🖥️ **Example 4 — GPU Passthrough**

```yaml
version: "2.0"

vms:
  gpu_vm:
    arch: x86_64
    machine: q35
    cpus: 8
    memory: 16384

    pci_passthrough:
      - host: "0000:01:00.0"   # GPU
      - host: "0000:01:00.1"   # HDMI Audio

    disks:
      - path: ./win11.qcow2
        interface: virtio

    networks:
      - type: user
```

---

# 🛰 **Example 5 — RISC-V VM**

```yaml
vms:
  riscv_test:
    arch: riscv64
    machine: virt
    cpus: 4
    memory: 2048

    disks:
      - path: ./riscv.qcow2
```
---
# ⭐ **Two VMs on the Same LAN (Bridge Mode)**

### Requirements:

You need a Linux bridge:

```bash
sudo ip link add name br0 type bridge
sudo ip addr add 192.168.100.1/24 dev br0
sudo ip link set br0 up
```

Enable DHCP server if needed (dnsmasq/default).

Add your internet NIC (example: `eth0`) to bridge if you want NAT internet:

```bash
sudo ip link set eth0 master br0
```

---

# 🧩 **Full Working YAML (vm1 ↔ vm2 LAN)**

```yaml
version: "2.0"

vms:
  mypc:
    arch: x86_64
    machine: q35

    cpus: 1
    cpu_model: host
    memory: 1024

    display:
      type: sdl
      fullscreen: false

    networks:
      - type: tap
        bridge: br0
        mac: "52:54:00:12:34:01"

    disks:
      - path: ./alpine.qcow2
        format: qcow2
        interface: virtio

  mypc2:
    arch: x86_64
    machine: q35

    cpus: 1
    cpu_model: host
    memory: 1024

    display:
      type: sdl
      fullscreen: false

    networks:
      - type: tap
        bridge: br0
        mac: "52:54:00:12:34:02"

    disks:
      - path: ./alpine2.qcow2
        format: qcow2
        interface: virtio
```

---

# 📡 **How VM Networking Works Here**

### VM1

* MAC: `52:54:00:12:34:01`
* On the same bridge `br0`
  → behaves like a real PC on LAN

### VM2

* MAC: `52:54:00:12:34:02`
* Same bridge
  → can ping and communicate with VM1

### They both get IP from

* dhcp on br0 (your host) or
* static IP inside Alpine

Example inside VM1:

```bash
ip addr add 192.168.100.10/24 dev eth0
```

Inside VM2:

```bash
ip addr add 192.168.100.11/24 dev eth0
```

Test:

```bash
ping 192.168.100.11
```
---

# 📑 **QEMU-Compose Features**

| Feature                    | Supported |
| -------------------------- | --------- |
| x86, ARM, RISC-V, PPC64    | ✅         |
| Boot from ISO              | ✅         |
| GPU passthrough            | ✅         |
| Custom hardware identity   | ✅         |
| IMEI, Serial, Vendor       | ✅         |
| Touchscreen                | ✅         |
| Sensors (GPS, gyro, accel) | ✅         |
| GPS NMEA feed              | ✅         |
| KVM acceleration           | ✅         |
| Auto fallback to TCG       | ✅         |
| Multiple networks          | ✅         |
| Port forwarding            | ✅         |
| Multiple disks             | ✅         |
| Monitor socket             | ✅         |
| Logs                       | ✅         |

---

# 🔧 **Troubleshooting**

### KVM not detected?

Enable virtualization in BIOS and run:

```bash
sudo modprobe kvm
sudo modprobe kvm_intel   # Intel
sudo modprobe kvm_amd     # AMD
```

---
