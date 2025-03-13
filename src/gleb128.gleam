// SPDX-License-Identifier: MIT

import gleam/bit_array
import gleam/bytes_tree.{type BytesTree}
import gleam/int

fn do_encode_unsigned(value: Int, builder: BytesTree) -> Result(BytesTree, Nil)
{
    case value >= 0
    {
        True ->
        {
            // Get value's least significant 8 bits, keeping the most significant bit among them unset, as the current chunk;
            // 0b01111111 = 0x7f
            let current_chunk = int.bitwise_and(value, 0b01111111)

            // Get the next 7 bits chunk
            let next_chunk = int.bitwise_shift_right(value, 7)

            // There is more chunks to come?
            // -> If done, then all next chunk's bits should be 0
            case next_chunk
            {
                0 -> Ok(bytes_tree.append(builder, <<current_chunk>>)) // No, append
                _ ->
                {
                    // Yes, then set the continuation bit (the most significant bit left unset) of the current chunk;
                    // 0b10000000 = 0x80
                    let current_chunk = int.bitwise_or(current_chunk, 0b10000000)
                    // Append the current chunk to the list and proceeds to encode the next chunk;
                    do_encode_unsigned(next_chunk, bytes_tree.append(builder, <<current_chunk>>))
                }
            }
        }
        // Can't encode a negative value with an unsigned function
        False -> Error(Nil)
    }
}

fn do_encode_signed(value: Int, builder: BytesTree) -> BytesTree
{
    // Get value's least significant 8 bits, keeping the most significant bit among them unset, as the current chunk;
    // 0b01111111 = 0x7f
    let current_chunk = int.bitwise_and(value, 0b01111111)

    // Get the next 7 bits chunk
    let next_chunk = int.bitwise_shift_right(value, 7)

    // Get the state of the sign bit (second most significant bit) of the current chunk
    // 0b01000000 = 0x40
    let sign = int.bitwise_and(value, 0b01000000)
    let sign = int.bitwise_shift_right(sign, 6)

    // There is more chunks to come? To check, we'll do the following...
    // -> If done and the signed number is positive, then all next chunk's bits will be 0 and the sign bit will be 0
    // -> If done and the signed number is negative, then all next chunk's bits will be 1 (two's complement) and the sign bit will be 1
    case { next_chunk == 0  && sign == 0 }
      || { next_chunk == int.bitwise_not(0) && sign == 1 }
    {
        True ->
        {
            // Then we're done, lets append the current and last chunk and return;
            bytes_tree.append(builder, <<current_chunk>>)
        }
        _ ->
        {
            // Then set the continuation bit (the most significant bit left unset) of the current chunk;
            // 0b10000000 = 0x80
            let current_chunk = int.bitwise_or(current_chunk, 0b10000000)
            // Append the current chunk to the list and proceeds to encode the next chunk;
            do_encode_signed(next_chunk, bytes_tree.append(builder, <<current_chunk>>))
        }
    }
}

fn do_decode_unsigned(data: BitArray, position_accumulator: Int, result_accumulator: Int, shift_accumulator: Int) -> Result(#(Int, Int), Nil)
{
    case bit_array.slice(from: data, at: position_accumulator, take: 1)
    {
        Ok(slice) -> case slice
        {
            <<byte:int>> ->
            {
                // Get byte's least significant 8 bits, keeping the most significant bit among them unset, as the current chunk;
                // 0b01111111 = 0x7f
                let current_chunk = int.bitwise_and(byte, 0b01111111)

                // Join the current chunk with result accumulator
                let current_chunk = int.bitwise_shift_left(current_chunk, shift_accumulator)
                let result_accumulator = int.bitwise_or(result_accumulator, current_chunk)

                // Get the next 7 bits chunk
                let next_chunk = int.bitwise_shift_right(byte, 7)

                case next_chunk
                {
                    0 -> Ok(#(result_accumulator, position_accumulator + 1)) // No more chunks to process, return the result + bytes read
                    _ -> do_decode_unsigned(data, position_accumulator + 1, result_accumulator, shift_accumulator + 7) // Continue
                }
            }
            // Can't decode the bit array slice into a byte
            _ -> Error(Nil)
        }
        // Invalid LEB128 integer
        _ -> Error(Nil)
    }
}

fn do_decode_signed(data: BitArray, position_accumulator: Int, result_accumulator: Int, shift_accumulator: Int) -> Result(#(Int, Int), Nil)
{
    case bit_array.slice(from: data, at: position_accumulator, take: 1)
    {
        Ok(slice) -> case slice
        {
            <<byte:int>> ->
            {
                // Get value's least significant 8 bits, keeping the most significant bit among them unset, as the current chunk;
                // 0b01111111 = 0x7f
                let current_chunk = int.bitwise_and(byte, 0b01111111)

                // Join the current chunk with result accumulator
                let current_chunk = int.bitwise_shift_left(current_chunk, shift_accumulator)
                let result_accumulator = int.bitwise_or(result_accumulator, current_chunk)

                let shift_accumulator = shift_accumulator + 7

                // Get the next 7 bits chunk
                let next_chunk = int.bitwise_shift_right(byte, 7)

                case next_chunk
                {
                    0 ->
                    {
                        // Check the state of the sign bit (second most significant bit) of the current chunk
                        // 0b01000000 = 0x40
                        let sign = int.bitwise_and(byte, 0b01000000)
                        let sign = int.bitwise_shift_right(sign, 6)
                        case sign
                        {
                            1 -> Ok(#(int.bitwise_or(result_accumulator, int.bitwise_shift_left(int.bitwise_not(0), shift_accumulator)), position_accumulator + 1))
                            _ -> Ok(#(result_accumulator, position_accumulator + 1))
                        }
                    }
                    _ -> do_decode_signed(data, position_accumulator + 1, result_accumulator, shift_accumulator)
                }
            }
            // Can't decode the bit array slice into a byte
            _ -> Error(Nil)
        }
        // Invalid LEB128 integer
        _ -> Error(Nil)
    }
}

fn do_fast_decode_unsigned(data: Int, position_accumulator: Int, result_accumulator: Int, shift_accumulator: Int) -> Result(#(Int, Int), Nil)
{
    let byte = int.bitwise_shift_right(data, 8 * position_accumulator)
    let byte = int.bitwise_and(byte, 0xff)

    // Get byte's least significant 8 bits, keeping the most significant bit among them unset, as the current chunk;
    // 0b01111111 = 0x7f
    let current_chunk = int.bitwise_and(byte, 0b01111111)

    // Join the current chunk with result accumulator
    let current_chunk = int.bitwise_shift_left(current_chunk, shift_accumulator)
    let result_accumulator = int.bitwise_or(result_accumulator, current_chunk)

    // Get the next 7 bits chunk
    let next_chunk = int.bitwise_shift_right(byte, 7)

    case next_chunk
    {
        0 -> Ok(#(result_accumulator, position_accumulator + 1)) // No more chunks to process, return the result + bytes read
        _ -> do_fast_decode_unsigned(data, position_accumulator + 1, result_accumulator, shift_accumulator + 7) // Continue
    }
}

fn do_fast_decode_signed(data: Int, position_accumulator: Int, result_accumulator: Int, shift_accumulator: Int) -> Result(#(Int, Int), Nil)
{
    let byte = int.bitwise_shift_right(data, 8 * position_accumulator)
    let byte = int.bitwise_and(byte, 0xff)

    // Get byte's least significant 8 bits, keeping the most significant bit among them unset, as the current chunk;
    // 0b01111111 = 0x7f
    let current_chunk = int.bitwise_and(byte, 0b01111111)

    // Join the current chunk with result accumulator
    let current_chunk = int.bitwise_shift_left(current_chunk, shift_accumulator)
    let result_accumulator = int.bitwise_or(result_accumulator, current_chunk)

    let shift_accumulator = shift_accumulator + 7

    // Get the next 7 bits chunk
    let next_chunk = int.bitwise_shift_right(byte, 7)

    case next_chunk
    {
        0 ->
        {
            // Check the state of the sign bit (second most significant bit) of the current chunk
            // 0b01000000 = 0x40
            let sign = int.bitwise_and(byte, 0b01000000)
            let sign = int.bitwise_shift_right(sign, 6)
            case sign
            {
                1 -> Ok(#(int.bitwise_or(result_accumulator, int.bitwise_shift_left(int.bitwise_not(0), shift_accumulator)), position_accumulator + 1))
                _ -> Ok(#(result_accumulator, position_accumulator + 1))
            }
        }
        _ -> do_fast_decode_signed(data, position_accumulator + 1, result_accumulator, shift_accumulator)
    }
}

/// Encodes an unsigned (positive) integer to a bit array containing its LEB128 representation.
///
/// Returns an error when the given value to encode is negative.
pub fn encode_unsigned(value: Int) -> Result(BitArray, Nil)
{
    case do_encode_unsigned(value, bytes_tree.new())
    {
        Ok(result) -> Ok(bytes_tree.to_bit_array(result))
        Error(e) -> Error(e)
    }
}

/// Encodes an signed (positive or negative) integer to a bit array containing its LEB128 representation.
pub fn encode_signed(value: Int) -> BitArray
{
    do_encode_signed(value, bytes_tree.new())
    |> bytes_tree.to_bit_array
}

/// Decodes a bit array containing some LEB128 integer as an unsigned (positive) integer.
/// 
/// Returns a tuple containing the decoded value in its first position, followed by the count of
/// bytes read in its second position. Returns an error when the given data can't be decoded.
/// 
/// This function is designed to optimize small inputs (whose length is less than or equal to 8 bytes)
/// by treating them as integers; since the input size is close to the word size of a 64-bit CPU,
/// the Erlang runtime will internally treat it as a "native" integer and not as a bignum/boxed integer
/// (which are stored on the heap and referenced via pointers), thus significantly reducing memory
/// consumption and speeding up arithmetic operations. See [erl_arith.c](https://github.com/erlang/otp/blob/55d43cd555e78b9071e514b42834ae31e2081f59/erts/emulator/beam/erl_arith.c#L146C1-L146C11).
pub fn decode_unsigned(data: BitArray) -> Result(#(Int, Int), Nil)
{
    case bit_array.byte_size(data)
    {
        size if size <= 8 -> case bit_array.slice(at: 0, from: <<data:bits, 0x00:size(64)>>, take: 8)
        {
            Ok(<<value:unsigned-little-size(64)>>) -> do_fast_decode_unsigned(value, 0, 0, 0)
            _ -> Error(Nil)
        }
        _ -> do_decode_unsigned(data, 0, 0, 0)
    }
}

/// Decodes a bit array containing some LEB128 integer as an signed (positive or negative) integer.
/// 
/// Returns a tuple containing the decoded value in its first position, followed by the count of
/// bytes read in its second position. Returns an error when the given data can't be decoded.
/// 
/// This function is designed to optimize small inputs (whose length is less than or equal to 8 bytes)
/// by treating them as integers; since the input size is close to the word size of a 64-bit CPU,
/// the Erlang runtime will internally treat it as a "native" integer and not as a bignum/boxed integer
/// (which are stored on the heap and referenced via pointers), thus significantly reducing memory
/// consumption and speeding up arithmetic operations. See [erl_arith.c](https://github.com/erlang/otp/blob/55d43cd555e78b9071e514b42834ae31e2081f59/erts/emulator/beam/erl_arith.c#L146C1-L146C11).
pub fn decode_signed(data: BitArray) -> Result(#(Int, Int), Nil)
{
    case bit_array.byte_size(data)
    {
        size if size <= 8 -> case bit_array.slice(at: 0, from: <<data:bits, 0x00:size(64)>>, take: 8)
        {
            Ok(<<value:signed-little-size(64)>>) -> do_fast_decode_signed(value, 0, 0, 0)
            _ -> Error(Nil)
        }
        _ -> do_decode_signed(data, 0, 0, 0)
    }
}
