// SPDX-License-Identifier: MIT

pub type Runtime
{
    Erlang
    JavaScript
}

@external(erlang, "runtime_ffi", "get_current_runtime")
@external(javascript, "../../runtime_ffi.mjs", "get_current_runtime")
pub fn get_current_runtime() -> Runtime