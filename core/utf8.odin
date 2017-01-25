RUNE_ERROR :: '\ufffd';
RUNE_SELF  :: 0x80;
RUNE_BOM   :: 0xfeff;
RUNE_EOF   :: ~cast(rune)0;
MAX_RUNE   :: '\U0010ffff';
UTF_MAX    :: 4;

SURROGATE_MIN :: 0xd800;
SURROGATE_MAX :: 0xdfff;

Accept_Range :: struct { lo, hi: u8 }

accept_ranges := [5]Accept_Range{
	{0x80, 0xbf},
	{0xa0, 0xbf},
	{0x80, 0x9f},
	{0x90, 0xbf},
	{0x80, 0x8f},
};

accept_sizes := [256]byte{
	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, // 0x00-0x0f
	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, // 0x10-0x1f
	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, // 0x20-0x2f
	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, // 0x30-0x3f
	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, // 0x40-0x4f
	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, // 0x50-0x5f
	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, // 0x60-0x6f
	0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, // 0x70-0x7f

	0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, // 0x80-0x8f
	0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, // 0x90-0x9f
	0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, // 0xa0-0xaf
	0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, // 0xb0-0xbf
	0xf1, 0xf1, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, // 0xc0-0xcf
	0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, // 0xd0-0xdf
	0x13, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x23, 0x03, 0x03, // 0xe0-0xef
	0x34, 0x04, 0x04, 0x04, 0x44, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, 0xf1, // 0xf0-0xff
};

encode_rune :: proc(r: rune) -> ([4]byte, int) {
	buf: [4]byte;
	i := cast(u32)r;
	mask: byte : 0x3f;
	if i <= 1<<7-1 {
		buf[0] = cast(byte)r;
		return buf, 1;
	}
	if i <= 1<<11-1 {
		buf[0] = 0xc0 | cast(byte)(r>>6);
		buf[1] = 0x80 | cast(byte)r & mask;
		return buf, 2;
	}

	// Invalid or Surrogate range
	if i > 0x0010ffff ||
	   (0xd800 <= i && i <= 0xdfff) {
		r = 0xfffd;
	}

	if i <= 1<<16-1 {
		buf[0] = 0xe0 | cast(byte)(r>>12);
		buf[1] = 0x80 | cast(byte)(r>>6) & mask;
		buf[2] = 0x80 | cast(byte)r    & mask;
		return buf, 3;
	}

	buf[0] = 0xf0 | cast(byte)(r>>18);
	buf[1] = 0x80 | cast(byte)(r>>12) & mask;
	buf[2] = 0x80 | cast(byte)(r>>6)  & mask;
	buf[3] = 0x80 | cast(byte)r     & mask;
	return buf, 4;
}

decode_rune :: proc(s: string) -> (rune, int) {
	n := s.count;
	if n < 1 {
		return RUNE_ERROR, 0;
	}
	b0 := s[0];
	x := accept_sizes[b0];
	if x >= 0xf0 {
		mask := (cast(rune)x << 31) >> 31; // all zeros or all ones
		return cast(rune)b0 &~ mask | RUNE_ERROR&mask, 1;
	}
	size := x & 7;
	ar := accept_ranges[x>>4];
	if n < cast(int)size {
		return RUNE_ERROR, 1;
	}
	b1 := s[1];
	if b1 < ar.lo || ar.hi < b1 {
		return RUNE_ERROR, 1;
	}

	MASK_X :: 0b00111111;
	MASK_2 :: 0b00011111;
	MASK_3 :: 0b00001111;
	MASK_4 :: 0b00000111;

	if size == 2 {
		return cast(rune)(b0&MASK_2)<<6 | cast(rune)(b1&MASK_X), 2;
	}
	b2 := s[2];
	if b2 < 0x80 || 0xbf < b2 {
		return RUNE_ERROR, 1;
	}
	if size == 3 {
		return cast(rune)(b0&MASK_3)<<12 | cast(rune)(b1&MASK_X)<<6 | cast(rune)(b2&MASK_X), 3;
	}
	b3 := s[3];
	if b3 < 0x80 || 0xbf < b3 {
		return RUNE_ERROR, 1;
	}
	return cast(rune)(b0&MASK_4)<<18 | cast(rune)(b1&MASK_X)<<12 | cast(rune)(b3&MASK_X)<<6 | cast(rune)(b3&MASK_X), 4;

}


valid_rune :: proc(r: rune) -> bool {
	if r < 0 {
		return false;
	} else if SURROGATE_MIN <= r && r <= SURROGATE_MAX {
		return false;
	} else if r > MAX_RUNE {
		return false;
	}
	return true;
}

valid_string :: proc(s: string) -> bool {
	n := s.count;
	i := 0;
	while i < n {
		si := s[i];
		if si < RUNE_SELF { // ascii
			i += 1;
			continue;
		}
		x := accept_sizes[si];
		if x == 0xf1 {
			return false;
		}
		size := cast(int)(x & 7);
		if i+size > n {
			return false;
		}
		ar := accept_ranges[x>>4];
		if b := s[i+1]; b < ar.lo || ar.hi < b {
			return false;
		} else if size == 2 {
			// Okay
		} else if b := s[i+2]; b < 0x80 || 0xbf < b {
			return false;
		} else if size == 3 {
			// Okay
		} else if b := s[i+3]; b < 0x80 || 0xbf < b {
			return false;
		}
		i += size;
	}
	return true;
}

rune_count :: proc(s: string) -> int {
	count := 0;
	n := s.count;
	i := 0;
	while i < n {
		defer count += 1;
		si := s[i];
		if si < RUNE_SELF { // ascii
			i += 1;
			continue;
		}
		x := accept_sizes[si];
		if x == 0xf1 {
			i += 1;
			continue;
		}
		size := cast(int)(x & 7);
		if i+size > n {
			i += 1;
			continue;
		}
		ar := accept_ranges[x>>4];
		if b := s[i+1]; b < ar.lo || ar.hi < b {
			size = 1;
		} else if size == 2 {
			// Okay
		} else if b := s[i+2]; b < 0x80 || 0xbf < b {
			size = 1;
		} else if size == 3 {
			// Okay
		} else if b := s[i+3]; b < 0x80 || 0xbf < b {
			size = 1;
		}
		i += size;
	}
	return count;
}


rune_size :: proc(r: rune) -> int {
	match {
	case r < 0:          return -1;
	case r <= 1<<7  - 1: return 1;
	case r <= 1<<11 - 1: return 2;
	case SURROGATE_MIN <= r && r <= SURROGATE_MAX: return -1;
	case r <= 1<<16 - 1: return 3;
	case r <= MAX_RUNE:  return 4;
	}
	return -1;
}
