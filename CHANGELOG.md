# Changelog

## v2.0.0 - 2024/08/11
- All decoding functions now returns a tuple containing the decoded value in its first position, followed by the count of bytes read in its second position.
- The ``decode_native_signed_integer``, ``decode_native_unsigned_integer`` and ``get_cpu_endianness`` functions are now hidden from the library's public API;
- Attempting to decode an invalid LEB128 integer will now return ``Error("Invalid LEB128 integer")`` instead of ``Error("Can't get the bit array slice")``;
- The code coverage of unit tests has been improved;
- Updated ``README.md`` usage guide;
- Added ``CHANGELOG.md``.

## v1.0.0 - 2024/07/19
- Initial version.