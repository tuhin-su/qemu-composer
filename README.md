
✔ How the YAML works
✔ How to configure ANY QEMU feature
✔ Full examples
✔ Networking (tap, user, socket, vlan, bridge)
✔ Disks (multiple drives, CDROM)
✔ Serial sockets / monitor sockets
✔ Headless & GUI
✔ CPU tuning, icount, throttle
✔ USB, PCI passthrough (if needed)
✔ Snapshots
✔ How to run/stop VMs
✔ How logs & sockets work

---

# ✅ **QEMU-COMPOSE COMPLETE USER GUIDE**

**Version 1.0 – Supports almost all QEMU features through YAML**

---

# 1️⃣ **Folder Structure**

When you run:

```bash
python3 qemu-compose.py up -f qemu-compose.yml
```

it auto-creates:

```
/tmp/qemu-compose/
│
├── logs/       → VM logs
├── sockets/    → Serial / network sockets
├── routerVm.monitor  → QEMU monitor socket
└── alpineVm.monitor  → monitor socket
```

No need to create manually.

---

# 2️⃣ **Basic YAML Structure**

Your YAML file structure:

```yaml
version: "2.0"

vms:
  vmName:
    arch:
    machine:
    cpus:
    cpu_model:
    memory:
    cpu_max_speed:

    display:
      type:
      width:
      height:
      fullscreen:

    serial:
      type:
      path:
      server:
      nowait:

    networks:
      - type: ...
        <options>

    disks:
      - path: ...
        format: ...
        interface: ...

    cdrom:
      path: ...
      interface:
```

---

# 3️⃣ **Supported QEMU Features in YAML**

## ✔ CPU features

```
cpus: 4
cpu_model: host   # or qemu64, max
cpu_max_speed: 50 # throttle CPU (via icount)
```

## ✔ Display modes

```
display:
  type: none      # full headless
  type: sdl       # SDL window
  type: gtk       # GTK window
  fullscreen: true
```

If **type: none**, system uses:

```
-nographic -serial mon:stdio
```

## ✔ Unlimited disks

```
disks:
  - path: disk1.qcow2
    format: qcow2
    interface: virtio
  - path: disk2.img
    format: raw
    interface: ide
  - path: disk3.qcow2
    format: qcow2
    interface: scsi
```

## ✔ CDROM / ISO

```
cdrom:
  path: ubuntu.iso
  interface: ide
```

## ✔ Serial sockets

```
serial:
  type: unix
  path: /tmp/qemu-compose/sockets/router.sock
  server: true
  nowait: true
```

Connect using:

```
socat -,raw,echo=0 unix-connect:/tmp/qemu-compose/sockets/router.sock
```

## ✔ Monitor socket

Automatically created

```
/tmp/qemu-compose/routerVm.monitor
```

Send commands:

```
socat - UNIX-CONNECT:/tmp/qemu-compose/routerVm.monitor
```

Commands example:

```
info block
info network
system_powerdown
```

---

# 4️⃣ **Networking Types (FULL SUPPORT)**

## ✔ user (NAT + Port forwarding)

```
- type: user
  forwards:
    - host_port: 8080
      guest_port: 80
    - host_port: 2222
      guest_port: 22
```

Generates:

```
-netdev user,id=net1,hostfwd=tcp::8080-:80,hostfwd=tcp::2222-:22
```

## ✔ tap (host TAP device)

```
- type: tap
  tap: tap0
  mac: "52:54:00:aa:bb:cc"
  script: no
  downscript: no
```

Requires you created:

```
sudo ip tuntap add tap0 mode tap user $USER
sudo ip link set tap0 up
```

## ✔ socket (inter-VM link)

```
- type: socket
  mode: server
  path: /tmp/qemu-compose/sockets/vm1.sock
```

Another VM:

```
- type: socket
  mode: connect
  path: /tmp/qemu-compose/sockets/vm1.sock
```

## ✔ vlan (legacy)

```
- type: vlan
  vlan_id: 20
  parent: user
```

---

# 5️⃣ **Snapshots (qcow2 internal)**

Full snapshot support from YAML:

```
snapshot: true
```

This triggers `-snapshot` (write-temporary overlay).

---

# 6️⃣ **USB Passthrough**

```
usb:
  - vendor: "046d"
    product: "c534"
```

Maps to:

```
-device usb-host,vendorid=0x046d,productid=0xc534
```

---

# 7️⃣ **PCI Passthrough**

(Requires VT-d / IOMMU)

```
pci_passthrough:
  - device: "0000:01:00.0"
```

QEMU:

```
-device vfio-pci,host=0000:01:00.0
```

---

# 8️⃣ **Full Example: RouterOS + Alpine**

```yaml
version: "2.0"

vms:
  routerVm:
    arch: x86_64
    machine: q35
    cpus: 2
    memory: 1024
    cpu_model: host

    display:
      type: none

    serial:
      type: unix
      path: /tmp/qemu-compose/sockets/router.sock
      server: true
      nowait: true

    networks:
      - type: user
        forwards:
          - host_port: 8080
            guest_port: 80

      - type: tap
        tap: tap0
        mac: "52:54:00:12:34:10"

    disks:
      - path: chr-7.20.5.qcow2
        format: qcow2
        interface: virtio

  alpineVm:
    arch: x86_64
    machine: q35
    cpus: 2
    memory: 2048

    display:
      type: sdl

    networks:
      - type: tap
        tap: tap1
        mac: "52:54:00:12:34:01"

    disks:
      - path: alpine.qcow2
        format: qcow2
        interface: virtio
```

---

# 9️⃣ **How to Start / Stop**

### **Start all VMs**

```
python3 qemu-compose.py up
```

### **Stop**

```
python3 qemu-compose.py down
```

---

# 🔟 **How to Connect Serial Console**

If RouterOS has:

```
serial:
  type: unix
  path: /tmp/qemu-compose/sockets/router.sock
  server: true
  nowait: true
```

Connect:

```
socat -,raw,echo=0 unix-connect:/tmp/qemu-compose/sockets/router.sock
```

You get **RouterOS CLI directly**.

---

# 1️⃣1️⃣ **How to Connect Monitor**

```
socat - UNIX-CONNECT:/tmp/qemu-compose/routerVm.monitor
```

Commands:

```
info cpu
info network
system_reset
system_powerdown
```

---

# 1️⃣2️⃣ **How to Add ANY QEMU Feature**

Everything supported by QEMU CLI can be mapped easily:

### Example: Add TPM

```
tpm:
  type: emulator
  path: /tmp/mytpm.sock
```

### Example: Add QMP socket

```
qmp:
  path: /tmp/qmp-router.sock
  server: true
```

### Example: Add SPICE

```
spice:
  port: 5930
  addr: 127.0.0.1
```

### Example: Add audio

```
audio:
  driver: pa
```

### Example: Add custom args

```
extra_args:
  - "-rng-device"
  - "/dev/urandom"
  - "-device"
  - "virtio-rng-pci"
```

---
