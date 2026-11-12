# Embedded Test Runner

A bare-metal (`no_std`) Rust test runner targeting the **Espressif ESP32-S3** microcontroller, designed for deterministic unit and integration testing across real silicon and QEMU hardware emulation.

---

## Target Microcontroller: ESP32-S3

The project targets the **ESP32-S3**, a dual-core Xtensa LX7 SoC engineered by Espressif Systems tailored for connected edge computing, AI acceleration, and embedded systems development.

### Hardware Specifications
* **Architecture:** 32-bit Xtensa dual-core LX7 running up to 240 MHz.
* **Vector Instructions:** Built-in vector instructions for accelerating digital signal processing (DSP) and neural network inference.
* **On-Chip Memory:**
  * 512 KB internal SRAM (384 KB usable for data/instruction storage, 64 KB cache).
  * 384 KB internal ROM.
  * 16 KB SRAM in RTC.
* **External Flash:** Configured for **8 MB SPI Flash** (`--flash-size 8MB`, DIO mode @ 40 MHz).
* **Connectivity:** 2.4 GHz Wi-Fi (802.11 b/g/n) and Bluetooth 5 (LE + Mesh).
* **Peripherals:** USB Serial/JTAG, GPIOs, SPI, I2C, I2S, UART, RMT, Pulse Counter, PWM, and capacitive touch sensors.

### Why ESP32-S3 for this Project?
1. **Modern Xtensa LX7 Architecture:** Supports rich `no_std` embedded Rust tooling via the `esp-rs` ecosystem (`esp-hal`, `esp-alloc`, `esp-backtrace`, `esp-println`).
2. **Dual Memory Management Models:** Enables testing both fixed zero-allocation data structures (`heapless`) and dynamic heap management (`esp-alloc`) on bare metal.
3. **Emulation Support:** Supported in Espressif's system emulator (`qemu-system-xtensa`), allowing headless test execution and automated testing pipelines without requiring physical hardware plugged in.

---

## Project Structure

* `src/main.rs`: Entry point testing core runtime bootstrap, `heapless` static buffers, and dynamic allocation via `esp-alloc`.
* `.cargo/config.toml`: Target configuration for `xtensa-esp32s3-none-elf`, linker arguments (`linkall.x`), and `build-std` crates (`core`, `alloc`).
* `Cargo.toml`: Dependency manifest including `esp-hal`, `esp-backtrace`, `esp-println`, `esp-alloc`, and `heapless`.

---

## Prerequisites

1. **Rust Xtensa Toolchain:**
   Installed via `espup`:
   ```bash
   espup install
   # Source the export environment if needed:
   source ~/export-esp.sh
   ```

2. **Espressif QEMU:**
   `qemu-system-xtensa` (Espressif fork supporting the `esp32s3` machine target).

3. **Image Tools:**
   `cargo-espflash` or `esptool`.

---

## Quick Start: One-Click Run Script

An executable runner script `run.sh` is provided to automatically source the environment, compile the project, produce the 8 MB merged image, and start QEMU:

```bash
./run.sh
```

---

## Building and Running in QEMU (8 MB Flash)

### 1. Build the Binary
Compile the project with the `esp` Rust toolchain:
```bash
cargo +esp build
```

### 2. Generate the 8 MB Merged Flash Image

Compile and generate the merged bootloader, partition table, and application flash image with `cargo espflash`:
```bash
cargo +esp espflash save-image \
  --chip esp32s3 \
  --merge \
  -s 8mb \
  target/qemu-flash.bin
```

### 3. Launch QEMU
Run the emulated ESP32-S3 system with the 8 MB raw flash image:
```bash
qemu-system-xtensa -nographic -machine esp32s3 \
  -drive file=target/qemu-flash.bin,if=mtd,format=raw \
  -no-reboot
```

> **Tip:** To exit QEMU's `-nographic` mode, press `Ctrl + A` followed by `X`.
