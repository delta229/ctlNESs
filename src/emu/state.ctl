pub struct Buffer {
    data: [str: [u8]] = [:],

    pub fn store(mut this, key: str, data: [u8..]) {
        this.data[key] = Vec::from_span(data);
    }

    pub fn store_bits<T>(mut this, key: str, val: *T) {
        this.store(key, unsafe Span::new(val as ^T as ^u8, std::mem::size_of_val(val)));
    }

    pub fn load(this, key: str, data: [mut u8..]): bool {
        guard this.data.get(&key) is ?val and val.len() == data.len() else {
            return false;
        }

        data[..] = val[..];
        true
    }

    pub fn load_bits<T>(this, key: str, val: *mut T): bool {
        this.load(key, unsafe SpanMut::new(val as ^mut T as ^mut u8, std::mem::size_of_val(val)))
    }
}

pub struct StateBuf {
    buffers: [str: Buffer] = [:],

    pub fn new(): This => This();

    pub fn new_storage<F: Fn(*mut Buffer)>(mut this, key: str, f: F) {
        mut buffer = Buffer();
        f(&mut buffer);
        this.buffers[key] = buffer;
    }

    pub fn get_storage<F: Fn(*Buffer)>(this, key: str, f: F) {
        if this.buffers.get(&key) is ?storage {
            f(storage);
        }
    }
}

pub trait Persist {
    fn save_state(this, buf: *mut StateBuf);
    fn load_state(mut this, buf: *StateBuf);
}
