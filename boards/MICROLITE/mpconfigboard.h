#define MICROPY_HW_BOARD_NAME "ESP32 module (microlite)"
#define MICROPY_HW_MCU_NAME "ESP32"

// Disable LAN867x Ethernet PHY by default as the required header may not be
// available with all ESP-IDF versions.
#ifndef PHY_LAN867X_ENABLED
#define PHY_LAN867X_ENABLED (0)
#endif
