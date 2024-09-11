// SPDX-License-Identifier: MIT

import gleeunit
import gleeunit/should
import gleam/list
import gleb128
import gleb128/internal/runtime
import common

pub fn main()
{
    gleeunit.main()
}

pub fn encode_unsigned_test()
{
    case runtime.get_current_runtime()
    {
        runtime.Erlang -> common.unsigned_test_cases |> list.append(common.unsigned_test_cases_erlang)
        runtime.JavaScript -> common.unsigned_test_cases
    }
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
    case runtime.get_current_runtime()
    {
        runtime.Erlang -> common.signed_test_cases |> list.append(common.signed_test_cases_erlang)
        runtime.JavaScript -> common.signed_test_cases
    }
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
    case runtime.get_current_runtime()
    {
        runtime.Erlang -> common.unsigned_test_cases |> list.append(common.unsigned_test_cases_erlang)
        runtime.JavaScript -> common.unsigned_test_cases
    }
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_unsigned(pair.1)
            |> should.be_ok
            |> should.equal(#(pair.0, pair.2))
        }
    )
}

pub fn decode_signed_test()
{
    case runtime.get_current_runtime()
    {
        runtime.Erlang -> common.signed_test_cases |> list.append(common.signed_test_cases_erlang)
        runtime.JavaScript -> common.signed_test_cases
    }
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_signed(pair.1)
            |> should.be_ok
            |> should.equal(#(pair.0, pair.2))
        }
    )
}

pub fn fast_decode_unsigned_test()
{
    case runtime.get_current_runtime()
    {
        runtime.Erlang -> common.unsigned_test_cases |> list.append(common.unsigned_test_cases_erlang)
        runtime.JavaScript -> common.unsigned_test_cases
    }
    |> list.each
    (
        fn (pair)
        {
            gleb128.fast_decode_unsigned(pair.1)
            |> should.be_ok
            |> should.equal(#(pair.0, pair.2))
        }
    )
}

pub fn fast_decode_signed_test()
{
    case runtime.get_current_runtime()
    {
        runtime.Erlang -> common.signed_test_cases |> list.append(common.signed_test_cases_erlang)
        runtime.JavaScript -> common.signed_test_cases
    }
    |> list.each
    (
        fn (pair)
        {
            gleb128.fast_decode_signed(pair.1)
            |> should.be_ok
            |> should.equal(#(pair.0, pair.2))
        }
    )
}

pub fn truncated_unsigned_decode_test()
{
    [
        // #(number, unsigned leb128, valid bytes count)
        #(2, <<0x02, 0x03, 0x04, 0x06, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f>>, 1),
        #(128, <<0x80, 0x01, 0x00>>, 2),
        #(128, <<0x80, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x06, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f>>, 2),
        #(123456, <<0xc0, 0xc4, 0x07, -1, -2, -3, -4, -5, -6>>, 3),
    ]
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_unsigned(pair.1)
            |> should.be_ok
            |> should.equal(#(pair.0, pair.2))
        }
    )
}

pub fn truncated_signed_decode_test()
{
    [
        // #(number, unsigned leb128, valid bytes count)
        #(-2, <<0x7e, 0x03, 0x04, 0x06, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f>>, 1),
        #(-128, <<0x80, 0x7f, 0x00>>, 2),
        #(-128, <<0x80, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x06, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f>>, 2),
        #(-123456, <<0xc0, 0xbb, 0x78, -1, -2, -3, -4, -5, -6>>, 3),
    ]
    |> list.each
    (
        fn (pair)
        {
            gleb128.decode_signed(pair.1)
            |> should.be_ok
            |> should.equal(#(pair.0, pair.2))
        }
    )
}
