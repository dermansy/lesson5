-module(lesson5_task2).
-export([create/1, insert/3, insert/4, lookup/2, delete_obsolete/1]).

-record(cache, {key, value, expires}).

create(Name) ->
    ets:new(Name, [named_table, public, set]).

insert(Name, Key, Value) ->
    insert(Name, Key, Value, infinity).

insert(Name, Key, Value, Expiry) ->
    ExpirationTime = case Expiry of
        infinity -> infinity;
        _ -> calendar:universal_time_to_seconds(calendar:universal_time()) + Expiry
    end,
    ets:insert(Name, #cache{key = Key, value = Value, expires = ExpirationTime}).

lookup(Name, Key) ->
    case ets:lookup(Name, Key) of
        [#cache{value = Value, expires = infinity}] -> Value;
        [#cache{value = Value, expires = Expires}] ->
            Now = calendar:universal_time_to_seconds(calendar:universal_time()),
            if Expires > Now -> Value;
               true -> undefined
            end;
        _ -> undefined
    end.

delete_obsolete(Name) ->
    Now = calendar:universal_time_to_seconds(calendar:universal_time()),
    ObsoleteKeys = [Key || #cache{key = Key, expires = Expires} <- ets:tab2list(Name), Expires =/= infinity, Expires =< Now],
    lists:foreach(fun(Key) -> ets:delete(Name, Key) end, ObsoleteKeys).
