pub use super::ppu::Mirroring;

packed struct INesHeader {
    magic: u32,           // Always "NES\x1a"             ; [u8; 4]
    prg_size: u8,         // Amount of PRG-ROM data in 16KB blocks
    chr_size: u8,         // Amount of CHR-ROM data in 8KB blocks
    // Flags 6
    vert_mirroring: bool,
    has_battery: bool,
    has_trainer: bool,
    alt_mirroring: bool,
    mapper_lo: u4,
    // Flags 7
    _vs_unisystem: bool,
    _playchoice_10: bool, // 8KB of hint screen data stored after CHR data
    _nes_2: u2,           // if nes_2 == 2, flags 8-15 are in NES 2.0 format
    mapper_hi: u4,
    // Flags 8-15
    _flags8_15: u64,
}

pub struct Cart {
    pub chr_rom: [u8..],
    pub prg_rom: [u8..],
    pub mirroring: Mirroring,
    pub has_battery: bool,
    pub mapper: u8,

    pub fn new(mut data: [u8..]): ?This {
        let header = data.read_exact(std::mem::size_of::<INesHeader>())?;
        let header = unsafe header.as_raw().cast::<INesHeader>().read_unaligned();
        guard header.magic == u32::from_le_bytes(*b"NES\x1a") else {
            return null;
        }

        if header.has_trainer {
            eprintln("cartridge has trainer present, ignoring it");
            data.read_exact(512);
        }
        Cart(
            prg_rom: data.read_exact(0x4000 * header.prg_size as uint)?,
            chr_rom: data.read_exact(0x2000 * header.chr_size as uint)?,
            mirroring: if header.alt_mirroring {
                :FourScreen
            } else {
                match header.vert_mirroring {
                    false => :Horizontal,
                    true => :Vertical,
                }
            },
            has_battery: header.has_battery,
            mapper: header.mapper_lo as u8 + (header.mapper_hi as u8 << 4),
        )
    }
}
