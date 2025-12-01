
# QEMU-Compose

**QEMU-Compose** is a Docker-Compose-like helper for managing QEMU virtual machines. It allows you to define multiple VMs in a YAML file (`qemu-compose.yml`) or use pre-defined defaults. Supports hardware configuration, GPU/CPU emulation, disks, network, and auto-fills missing fields.

---

## Features

* Define multiple VMs with **YAML configuration**.
* **Defaults provided** for two PCs (`pc1` & `pc2`) if no YAML exists.
* Supports **x86_64 / AMD64, ARM, aarch64** architectures.
* Auto-create **QCOW2 disks** if missing.
* Hardware emulation: CPU, RAM, Display (Spice/VNC), Battery, Sensors.
* Network support with port forwarding.
* VM lifecycle commands similar to Docker Compose: `up`, `down`, `start`, `stop`, `ps`, `logs`.
* Auto **serial number generation** and other missing hardware fields.
* Easy to extend for custom VMs.

---

## Installation

1. Clone or copy the script:

```bash
git clone <your-repo>
cd qemu-compose
```

2. Install dependencies:

```bash
pip install pyyaml
```

3. Ensure `qemu-system-*` and `qemu-img` are installed:

```bash
# Debian/Ubuntu
sudo apt install qemu qemu-kvm qemu-utils
```

4. Make script executable:

```bash
chmod +x qemu-compose.py
```

---

## Quick Start

### Start default VMs

If no `qemu-compose.yml` is present, two default PCs will be created (`pc1` & `pc2`):

```bash
./qemu-compose.py up
```

This will:

* Create default disks in `images/`.
* Start VMs with 4GB/8GB RAM, 4/6 CPU, Spice display, and network with SSH forwarding.

### Stop VMs

```bash
./qemu-compose.py down
```

### Start a single VM

```bash
./qemu-compose.py start pc1
```

### Stop a single VM

```bash
./qemu-compose.py stop pc2
```

### List running VMs

```bash
./qemu-compose.py ps
```

### View VM logs

```bash
./qemu-compose.py logs pc1
```

---

## Configuration (`qemu-compose.yml`)

You can define your own VMs in YAML. Example:

```yaml
version: "2.0"
vms:
  mypc:
    arch: x86_64
    machine: q35
    cpus: 4
    cpu_model: host
    memory: 4096
    networks:
      - type: user
        forwards:
          - host_port: 2222
            guest_port: 22
    disks:
      - path: images/mypc.qcow2
        format: qcow2
        interface: virtio
    hardware:
      vendor: "MyVendor"
      product: "MyPC"
      serial_number: AUTO
      board_id: "BOARD001"
      display:
        type: spice
        width: 1920
        height: 1080
```

**Notes:**

* `serial_number: AUTO` generates a random serial.
* Missing fields are auto-filled with safe defaults.
* Supports multiple VMs under the `vms:` section.
* Network `forwards` maps host ports to guest VM ports.

---

## Directory Structure

```
.
├── images/             # QCOW2 disk images
├── .qemu-compose/      # State (pids, logs)
├── qemu-compose.py     # Main script
├── qemu-compose.yml    # Optional YAML config
└── README.md           # Documentation
```

---

## Supported Architectures

* x86_64 / AMD64
* i386
* ARM (armv7, armhf)
* AArch64 / ARM64

`qemu-compose.py` automatically detects the right `qemu-system-*` binary.

---

## Disk Auto-Creation

If a disk path is missing, the script auto-creates a **qcow2 disk**:

```bash
images/<vmname>.qcow2
```

Default size: **8GB** (change in code if needed).

---

## Extra Features

* **Hardware defaults** for display, sensors, battery.
* **Spice** and **VNC** display support.
* **Port forwarding** for SSH or other services.
* Extra arguments can be passed via YAML `args:`.

---

## Example Commands

```bash
# Start all VMs
./qemu-compose.py up

# Stop all VMs
./qemu-compose.py down

# Start a specific VM
./qemu-compose.py start pc1

# Stop a specific VM
./qemu-compose.py stop pc2

# Check status
./qemu-compose.py ps

# Tail logs
./qemu-compose.py logs pc1
```

---

## Tips

* Use **Spice client** or **virt-viewer** to connect:

```bash
sudo apt install virt-viewer
remote-viewer spice://127.0.0.1:5930
```

* Change disk sizes or RAM by modifying the YAML or default values in `qemu-compose.py`.
* Add custom CPUs, GPUs, or devices using `args:`.

---

## License

MIT License – free to use.
