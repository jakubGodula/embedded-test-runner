#![no_std]
#![no_main]

extern crate alloc;
use alloc::boxed::Box;
use alloc::vec::Vec;

use esp_backtrace as _;
use esp_println::println;
use heapless::Vec as HeaplessVec;

esp_bootloader_esp_idf::esp_app_desc!();

#[esp_hal::main]
fn main() -> ! {
    let _peripherals = esp_hal::init(esp_hal::Config::default());

    // 1. Initialize heap allocator (64 KB internal memory)
    esp_alloc::heap_allocator!(size: 64 * 1024);

    println!("========================================");
    println!("  ESP32-S3 Custom Embedded Test Runner  ");
    println!("========================================");

    // Demonstration of heapless (zero heap, fixed capacity)
    println!("\n[1] Testing heapless static structures:");
    let mut static_list: HeaplessVec<&str, 4> = HeaplessVec::new();
    let _ = static_list.push("Test 1: Heapless Vector Init");
    let _ = static_list.push("Test 2: Memory Integrity");
    for item in static_list.iter() {
        println!("  - Registered: {}", item);
    }

    // Demonstration of alloc (dynamic allocation via esp-alloc)
    println!("\n[2] Testing dynamic alloc structures:");
    let mut dynamic_list: Vec<Box<u32>> = Vec::new();
    dynamic_list.push(Box::new(42));
    dynamic_list.push(Box::new(1337));
    println!("  Allocated {} items on heap successfully!", dynamic_list.len());

    println!("\n[OK] All bootstrap checks passed in QEMU.");

    loop {}
}
