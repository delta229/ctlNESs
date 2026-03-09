use ctlness::emu::cart::*;

pub struct Nrom {
    cart: Cart,
    one_bank: bool,
    chr_ram: ?[u8; 0x2000],

    pub fn new(cart: Cart): This {
        Nrom(
            one_bank: cart.prg_rom.len() == 0x4000,
            chr_ram: if cart.chr_rom.is_empty() { [0; 0x2000] },
            cart:
        )
    }

    impl super::Mem {
        fn peek(this, addr: u16): ?u8 {
            if addr >= 0x8000 {
                let addr = this.one_bank then (addr - 0x8000) & 0x3fff else addr - 0x8000;
                this.cart.prg_rom[addr]
            }
        }

        fn write(mut this, _: *mut super::Bus, addr: u16, val: u8) {
            if addr >= 0x8000 {
                eprintln("attempt to write {val:#x} to rom at addr {addr:#x}");
            }
        }
    }

    impl super::Mapper {
        fn peek_chr(this, addr: u16): u8 {
            if &this.chr_ram is ?chr_ram {
                chr_ram[addr]
            } else {
                this.cart.chr_rom[addr]
            }
        }

        fn write_chr(mut this, addr: u16, val: u8) {
            if &mut this.chr_ram is ?chr_ram {
                chr_ram[addr] = val;
            }
        }

        fn mirroring(this): Mirroring => this.cart.mirroring;

        fn reset(mut this) {}
    }

    impl super::Persist {
        fn save_state(this, buf: *mut super::StateBuf) {
            buf.new_storage("Nrom", |=this, buf| {
                if &this.chr_ram is ?chr_ram {
                    buf.store_bits("chr_ram", chr_ram);
                }
            });
        }

        fn load_state(mut this, buf: *super::StateBuf) {
            buf.get_storage("Nrom", |=this, buf| {
                if &mut this.chr_ram is ?chr_ram {
                    buf.load_bits("chr_ram", chr_ram);
                }
            });
        }
    }
}
