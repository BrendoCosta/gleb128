// SPDX-License-Identifier: MIT

import gleeunit
import gleeunit/should
import gleam/list
import gleb128/internal/native
import common

pub fn main()
{
    gleeunit.main()
}

pub fn decode_native_unsigned_integer__little_endian_test()
{
    common.unsigned_little_endian_test_cases
    |> list.each
    (
        fn (pair)
        {
            native.decode_native_unsigned_integer(pair.1, native.Little)
            |> should.equal(pair.0)
        }
    )
}

pub fn decode_native_unsigned_integer__big_endian_test()
{
    common.unsigned_big_endian_test_cases
    |> list.each
    (
        fn (pair)
        {
            native.decode_native_unsigned_integer(pair.1, native.Big)
            |> should.equal(pair.0)
        }
    )
}

pub fn decode_native_signed_integer__little_endian_test()
{
    common.signed_little_endian_test_cases
    |> list.each
    (
        fn (pair)
        {
            native.decode_native_signed_integer(pair.1, native.Little)
            |> should.equal(pair.0)
        }
    )
}

pub fn decode_native_signed_integer__big_endian_test()
{
    common.signed_big_endian_test_cases
    |> list.each
    (
        fn (pair)
        {
            native.decode_native_signed_integer(pair.1, native.Big)
            |> should.equal(pair.0)
        }
    )
}