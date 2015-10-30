/*  Waylos, a kernel built in rust
    Copyright (C) 2015 Waylon Cude

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#[repr(C,packed)]
#[allow(unused)]
#[derive(Clone,Copy,Debug)]
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

    /*irq_gsi: [u32; 16], //Why doesn't this work?
    irq_flags: [u8; 16],*/
}
#[repr(C,packed)]
#[derive(Clone,Copy,Debug)]
pub struct hy_info_second_half {
    cpu_offset: u16,
    ioapic_offset: u16,
    mmap_offset: u16,
    module_offset: u16,
    string_offset: u16,

    cpu_count_active: u16,
    cpu_count: u16,
    ioapic_count: u16,
    mmap_count: u16,
    module_count: u16,
}
#[derive(Clone,Copy)]
pub struct cpu_info {
    apic_id: u32,
    acpi_id: u32,
    flags: u16,
    lapic_timer_freq: u32,
    domain: u32
}
#[derive(Clone,Copy,Debug)]
#[repr(packed)]
pub struct mmap_info {
    pub address: u64,
    pub length: u64,
    pub available: u64,
    pub padding: u64
}
impl mmap_info {
    pub fn contains(&self, address: u64, length: u64) -> bool{ //This should probably return the next available address
        return if address >= self.address && self.available == 1 && address + length <= self.address + self.length && self.available == 1{
            true
        } else {
            false
        }
    }
}
