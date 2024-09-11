-module(runtime_ffi).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch]).

-export([get_current_runtime/0]).
-export_type([runtime/0]).

-type runtime() :: erlang | java_script.

-spec get_current_runtime() -> runtime().
get_current_runtime() ->
    erlang.
