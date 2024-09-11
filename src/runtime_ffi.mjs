// SPDX-License-Identifier: MIT

import { JavaScript } from "./gleb128/internal/runtime.mjs";

export function get_current_runtime()
{
    new JavaScript();
}