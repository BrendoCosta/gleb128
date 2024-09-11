// SPDX-License-Identifier: MIT

import { Result, Ok, Error } from "../prelude.mjs";
import { Big, Little } from "./gleb128/internal/native.mjs";

export function get_cpu_endianness()
{
    let as_integer = new Uint32Array([0x11223344]);
    let as_byte = new Uint8Array(as_integer.buffer);

    if (as_byte[0] === 0x44)
    {
        return new Ok(new Little());
    }
    else if (as_byte[0] === 0x11)
    {
        return new Ok(new Big());
    }
    else
    {
        return new Error("Can't determine CPU's endianness. Maybe the CPU uses a mixed-endian format?");
    }
}

export function decode_native_unsigned_integer(data, endianness)
{
    let result = 0n;
    let bytes = [...Array(data.length).keys()].map(i => data.byteAt(i));

    if (endianness instanceof Big)
    {
        // Removes leading zeroes on the left
        while (bytes.slice(0, 1) == [0x00])
        {
            bytes.pop();
        }

        for (let i = 0; i < bytes.length; i++)
        {
            result = (result << 8n) | BigInt(bytes[i]);
        }
    }
    else if (endianness instanceof Little)
    {
        // Removes leading zeroes on the right
        while (bytes.slice(-1) == [0x00])
        {
            bytes.pop();
        }

        for (let i = 0; i < bytes.length; i++)
        {
            result = (result << 8n) | BigInt(bytes[bytes.length - i - 1]);
        }
    }
    else
    {
        result = 0;
    }
    return Number(result);
}

export function decode_native_signed_integer(data, endianness)
{
    let result = 0n;
    let bytes = [...Array(data.length).keys()].map(i => data.byteAt(i));

    if (endianness instanceof Big)
    {
        // Removes leading zeroes on the left
        while (bytes.slice(0, 1) == [0x00])
        {
            bytes.pop();
        }

        for (let i = 0; i < bytes.length; i++)
        {
            result = (result << 8n) | BigInt(bytes[i]);
        }
    }
    else if (endianness instanceof Little)
    {
        // Removes leading zeroes on the right
        while (bytes.slice(-1) == [0x00])
        {
            bytes.pop();
        }

        for (let i = 0; i < bytes.length; i++)
        {
            result = (result << 8n) | BigInt(bytes[bytes.length - i - 1]);
        }
    }
    else
    {
        result = 0;
    }

    return Number(BigInt.asIntN(bytes.length * 8, result));
}