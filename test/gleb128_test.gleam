// SPDX-License-Identifier: MIT

import gleeunit
import gleeunit/should
import gleam/list
import gleb128

const unsigned_test_cases =
[
    // #(number, unsigned leb128)
    #(0, <<0x00>>),
    #(1, <<0x01>>),
    #(2, <<0x02>>),
    #(127, <<0x7f>>),
    #(128, <<0x80, 0x01>>),
    #(129, <<0x81, 0x01>>),
    #(130, <<0x82, 0x01>>),
    #(255, <<0xff, 0x01>>),
    #(1036, <<0x8c, 0x08>>),
    #(12857, <<0xb9, 0x64>>),
    #(16256, <<0x80, 0x7f>>),
    #(123456, <<0xc0, 0xc4, 0x07>>),
    #(624485, <<0xe5, 0x8e, 0x26>>),
    #(2000000, <<0x80, 0x89, 0x7a>>),
    #(2147483647, <<0xff, 0xff, 0xff, 0xff, 0x07>>),
    #(4294967295, <<0xff, 0xff, 0xff, 0xff, 0x0f>>),
    #(60000000000000000, <<0x80, 0x80, 0x98, 0xf4, 0xe9, 0xb5, 0xca, 0x6a>>),
    #(24197857200151252728969465429440056815, <<0xef, 0x9b, 0xaf, 0x85, 0x89, 0xcf, 0x95, 0x9a, 0x92, 0xde, 0xb7, 0xde, 0x8a, 0x92, 0x9e, 0xab, 0xb4, 0x24>>)
]

const signed_test_cases =
[
    // #(number, signed leb128)
    #(-24197857200151252728969465429440056815, <<0x91, 0xe4, 0xd0, 0xfa, 0xf6, 0xb0, 0xea, 0xe5, 0xed, 0xa1, 0xc8, 0xa1, 0xf5, 0xed, 0xe1, 0xd4, 0xcb, 0x5b>>),
    #(-60000000000000000, <<0x80, 0x80, 0xe8, 0x8b, 0x96, 0xca, 0xb5, 0x95, 0x7f>>),
    #(-4294967295, <<0x81, 0x80, 0x80, 0x80, 0x70>>),
    #(-2147483647, <<0x81, 0x80, 0x80, 0x80, 0x78>>),
    #(-2000000, <<0x80, 0xf7, 0x85, 0x7f>>),
    #(-624485, <<0x9b, 0xf1, 0x59>>),
    #(-123456, <<0xc0, 0xbb, 0x78>>),
    #(-16256, <<0x80, 0x81, 0x7f>>),
    #(-12857, <<0xc7, 0x9b, 0x7f>>),
    #(-1036, <<0xf4, 0x77>>),
    #(-255, <<0x81, 0x7e>>),
    #(-130, <<0xfe, 0x7e>>),
    #(-129, <<0xff, 0x7e>>),
    #(-128, <<0x80, 0x7f>>),
    #(-127, <<0x81, 0x7f>>),
    #(-2, <<0x7e>>),
    #(-1, <<0x7f>>),
    #(0, <<0x00>>),
    #(1, <<0x01>>),
    #(2, <<0x02>>),
    #(127, <<0xff, 0x00>>),
    #(128, <<0x80, 0x01>>),
    #(129, <<0x81, 0x01>>),
    #(130, <<0x82, 0x01>>),
    #(255, <<0xff, 0x01>>),
    #(1036, <<0x8c, 0x08>>),
    #(12857, <<0xb9, 0xe4, 0x00>>),
    #(16256, <<0x80, 0xff, 0x00>>),
    #(123456, <<0xc0, 0xc4, 0x07>>),
    #(624485, <<0xe5, 0x8e, 0x26>>),
    #(2000000, <<0x80, 0x89, 0xfa, 0x00>>),
    #(2147483647, <<0xff, 0xff, 0xff, 0xff, 0x07>>),
    #(4294967295, <<0xff, 0xff, 0xff, 0xff, 0x0f>>),
    #(60000000000000000, <<0x80, 0x80, 0x98, 0xf4, 0xe9, 0xb5, 0xca, 0xea, 0x00>>),
    #(24197857200151252728969465429440056815, <<0xef, 0x9b, 0xaf, 0x85, 0x89, 0xcf, 0x95, 0x9a, 0x92, 0xde, 0xb7, 0xde, 0x8a, 0x92, 0x9e, 0xab, 0xb4, 0x24>>)
]

const unsigned_little_endian_test_cases =
[
    #(0, <<0x00>>),
    #(1, <<0x01>>),
    #(2, <<0x02>>),
    #(16, <<0x10>>),
    #(65536, <<0x00, 0x00, 0x01>>),
    #(16777216, <<0x00, 0x00, 0x00, 0x01>>),
    #(4294967295, <<0xff, 0xff, 0xff, 0xff>>),
    #(4294967296, <<0x00, 0x00, 0x00, 0x00, 0x01>>)
]

const unsigned_big_endian_test_cases =
[
    #(0, <<0x00>>),
    #(1, <<0x01>>),
    #(1, <<0x00, 0x01>>),
    #(2, <<0x02>>),
    #(16, <<0x10>>),
    #(65536, <<0x01, 0x00, 0x00>>),
    #(16777216, <<0x01, 0x00, 0x00, 0x00>>),
    #(4294967295, <<0xff, 0xff, 0xff, 0xff>>),
    #(4294967296, <<0x01, 0x00, 0x00, 0x00, 0x00>>)
]

const signed_little_endian_test_cases =
[
    #(-2147483647, <<0x01, 0x00, 0x00, 0x80>>),
    #(-65536, <<0x00, 0x00, 0xff, 0xff>>),
    #(-65535, <<0x01, 0x00, 0xff, 0xff>>),
    #(-1024, <<0x00, 0xfc>>),
    #(-3, <<0xfd>>),
    #(-2, <<0xfe>>),
    #(-1, <<0xff>>),
    #(-1, <<0xff, 0xff, 0xff, 0xff>>),
    #(2, <<0x02>>),
    #(3, <<0x03>>),
    #(1024, <<0x00, 0x04>>),
    #(65535, <<0xff, 0xff, 0x00>>),
    #(65536, <<0x00, 0x00, 0x01>>),
    #(2147483647, <<0xff, 0xff, 0xff, 0x7f>>)
]

const signed_big_endian_test_cases =
[
    #(-2147483647, <<0x80, 0x00, 0x00, 0x01>>),
    #(-65536, <<0xff, 0xff, 0x00, 0x00>>),
    #(-65535, <<0xff, 0xff, 0x00, 0x01>>),
    #(-1024, <<0xfc, 0x00>>),
    #(-3, <<0xfd>>),
    #(-2, <<0xfe>>),
    #(-1, <<0xff>>),
    #(-1, <<0xff, 0xff, 0xff, 0xff>>),
    #(2, <<0x02>>),
    #(3, <<0x03>>),
    #(1024, <<0x04, 0x00>>),
    #(65535, <<0x00, 0xff, 0xff>>),
    #(65536, <<0x01, 0x00, 0x00>>),
    #(2147483647, <<0x7f, 0xff, 0xff, 0xff>>)
]

pub fn main()
{
    gleeunit.main()
}

pub fn encode_unsigned_test()
{
    unsigned_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.encode_unsigned(pair.0)
            |> should.equal(Ok(pair.1))
        }
    )
}

pub fn encode_signed_test()
{
    signed_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.encode_signed(pair.0)
            |> should.equal(pair.1)
        }
    )
}

pub fn decode_unsigned_test()
{
    unsigned_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_unsigned(pair.1)
            |> should.be_ok
            |> should.equal(pair.0)
        }
    )
}

pub fn decode_signed_test()
{
    signed_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_signed(pair.1)
            |> should.be_ok
            |> should.equal(pair.0)
        }
    )
}

pub fn fast_decode_unsigned_test()
{
    unsigned_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.fast_decode_unsigned(pair.1)
            |> should.be_ok
            |> should.equal(pair.0)
        }
    )
}

pub fn fast_decode_signed_test()
{
    signed_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.fast_decode_signed(pair.1)
            |> should.be_ok
            |> should.equal(pair.0)
        }
    )
}

pub fn decode_native_unsigned_integer__little_endian_test()
{
    unsigned_little_endian_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_native_unsigned_integer(pair.1, gleb128.Little)
            |> should.equal(pair.0)
        }
    )
}

pub fn decode_native_unsigned_integer__big_endian_test()
{
    unsigned_big_endian_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_native_unsigned_integer(pair.1, gleb128.Big)
            |> should.equal(pair.0)
        }
    )
}

pub fn decode_native_signed_integer__little_endian_test()
{
    signed_little_endian_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_native_signed_integer(pair.1, gleb128.Little)
            |> should.equal(pair.0)
        }
    )
}

pub fn decode_native_signed_integer__big_endian_test()
{
    signed_big_endian_test_cases
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_native_signed_integer(pair.1, gleb128.Big)
            |> should.equal(pair.0)
        }
    )
}
