// SPDX-License-Identifier: MIT

import gleam/bit_array

pub type Endianness
{
    Big
    Little
}

// Determines the if the current CPU is either little endian or big endian.
pub fn get_cpu_endianness() -> Result(Endianness, String)
{
    case <<0x01:native-size(32)>>
    {
        <<0x01, 0x00, 0x00, 0x00>> -> Ok(Little)
        <<0x00, 0x00, 0x00, 0x01>> -> Ok(Big)
        _ -> Error("Can't determine CPU's endianness. Maybe the CPU uses a mixed-endian format?")
    }
}

/// Decodes an arbitrary bit array into a native unsigned (positive) integer.
@external(erlang, "binary", "decode_unsigned")
pub fn decode_native_unsigned_integer(data: BitArray, endianness: Endianness) -> Int
{
    let size_in_bits = bit_array.byte_size(data) * 8

    case endianness, data
    {
        Little, <<x:unsigned-little-size(size_in_bits)>> -> x
        Big, <<x:unsigned-big-size(size_in_bits)>> -> x
        _, _ -> 0
    }
}

/// Decodes an arbitrary bit array into a native signed (positive or negative) integer.
pub fn decode_native_signed_integer(data: BitArray, endianness: Endianness) -> Int
{
    let size_in_bits = bit_array.byte_size(data) * 8

    case endianness, data
    {
        Little, <<x:signed-little-size(size_in_bits)>> -> x
        Big, <<x:signed-big-size(size_in_bits)>> -> x
        _, _ -> 0
    }
}