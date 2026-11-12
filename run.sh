#!/usr/bin/env bash
set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

FLASH_IMAGE="target/qemu-flash.bin"
CHIP="esp32s3"
FLASH_SIZE="8mb"

# Source Espressif environment if available
if [ -f "${HOME}/export-esp.sh" ]; then
    # shellcheck source=/dev/null
    source "${HOME}/export-esp.sh"
fi

echo "=========================================="
echo " Building embedded-test-runner for ${CHIP}"
echo "=========================================="
cargo +esp build

echo ""
echo "=========================================="
echo " Generating ${FLASH_SIZE} merged flash image"
echo "=========================================="
cargo +esp espflash save-image \
    --chip "${CHIP}" \
    --merge \
    -s "${FLASH_SIZE}" \
    "${FLASH_IMAGE}"

echo ""
echo "=========================================="
echo " Launching QEMU System Emulation"
echo " (Press Ctrl+A then X to terminate QEMU)"
echo "=========================================="

# Pass additional arguments to QEMU if provided, or run interactively
if [ "$#" -gt 0 ]; then
    exec qemu-system-xtensa -nographic -machine "${CHIP}" \
        -drive file="${FLASH_IMAGE}",if=mtd,format=raw \
        -no-reboot "$@"
else
    exec qemu-system-xtensa -nographic -machine "${CHIP}" \
        -drive file="${FLASH_IMAGE}",if=mtd,format=raw \
        -no-reboot
fi
