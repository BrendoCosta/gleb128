# GLEB128

[![Package Version](https://img.shields.io/hexpm/v/gleb128)](https://hex.pm/packages/gleb128)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleb128/)
[![Package License](https://img.shields.io/hexpm/l/gleb128)](https://hex.pm/packages/gleb128)
[![Package Total Downloads Count](https://img.shields.io/hexpm/dt/gleb128)](https://hex.pm/packages/gleb128)
[![Build Status](https://img.shields.io/github/actions/workflow/status/BrendoCosta/gleb128/test.yml)](https://hex.pm/packages/gleb128)
[![Total Stars Count](https://img.shields.io/github/stars/BrendoCosta/gleb128)](https://hex.pm/packages/gleb128)

## Description

GLEB128 is a small Gleam library that provides functions for encoding and decoding LEB128 (Little Endian Base 128) integers. LEB128 is a variable-length code compression method used to store arbitrarily large integers in a small number of bytes. Notable use cases for LEB128 are in the DWARF debug file format and the WebAssembly's binary format.

## Usage

### Encoding

```gleam
import gleam/io
import gleb128

pub fn main()
{
    let unsigned_encoded = gleb128.encode_unsigned(255)
    let signed_encoded = gleb128.encode_signed(-255)

    io.debug(unsigned_encoded)
    io.debug(signed_encoded)
}
```

Shows the following in output:

```console
Ok(<<255, 1>>)
<<129, 126>>
```

### Decoding

```gleam
import gleam/io
import gleb128

pub fn main()
{
    let unsigned_decoded = gleb128.decode_unsigned(<<255, 1>>)
    let signed_decoded = gleb128.decode_signed(<<129, 126>>)

    io.debug(unsigned_decoded)
    io.debug(signed_decoded)
}
```

Shows the following in output:

```console
Ok(255)
Ok(-255)
```

### Fast decoding

The ``fast_decode_unsigned`` and ``fast_decode_signed`` functions are optimized for decoding small LEB128 integers on 64-bit systems. Those functions will treat and process the data as a native integer when its length is less than or equal to 8 bytes (64 bits); otherwise, they will fallback to the default decoding functions.

On a Ryzen 5 5600G with 32 GB RAM, encoding and then decoding all numbers in the range from 0 to 100000000 with the default ``decode_signed`` took 50.10 seconds and used about 20 GB of memory. Repeating the test using ``fast_decode_signed`` reduced the elapsed time to 40.16 seconds and memory usage to about 14.5 GB. The ``fast_decode_unsigned`` function can be even faster when targeting Erlang, as it can use its stdlib's built-in ``binary:decode_unsigned/2`` function.

## License

GLEB128 source code is avaliable under the [MIT license](/LICENSE).
