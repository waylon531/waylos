#[derive(Clone,Copy)]
pub struct hy_info {
    pub magic: u32,
    flags: u32,
    length: u16,

    lapic_paddr: u64,
    rsdp_paddr: u64,

    idt_paddr: u64,
    gdt_paddr: u64,
    tss_paddr: u64,

    free_paddr: u64,

/*    irq_gsi: [u32; 16],
    irq_flags: [u8; 16],

    cpu_offset: u16,
    ioapic_offset: u16,
    mmap_offset: u16,
    module_offset: u16,
    string_offset: u16,

    cpu_count_active: u16,
    cpu_count: u16,
    ioapic_count: u16,
    mmap_count: u16,
    module_count: u16, */
}
pub struct hy_cpu_info {
    apic_id: u32,
    acpi_id: u32,
    flags: u16,
    lapic_timer_freq: u32,
    domain: u32
}
