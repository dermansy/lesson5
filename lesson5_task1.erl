-module(lesson5_task1).
-export([compare/0]).

compare() ->
    Mechanisms = [ets, mnesia, maps],
    Operations = [insert, update, delete, read],
    Results = [{Mechanism, Op, timer:tc(fun() -> perform_test(Mechanism, Op) end)} || 
                Mechanism <- Mechanisms, Op <- Operations],
    io:format("~p~n", [Results]).

perform_test(ets, insert) ->
    {ok, Table} = ets:new(test, [named_table]),
    lists:foreach(fun(N) -> ets:insert(Table, {N, N * 2}) end, lists:seq(1, 1000)),
    ok;
perform_test(ets, update) ->
    lists:foreach(fun(N) -> ets:insert(test, {N, N * 3}) end, lists:seq(1, 1000)),
    ok;
perform_test(ets, delete) ->
    lists:foreach(fun(N) -> ets:delete(test, N) end, lists:seq(1, 1000)),
    ok;
perform_test(ets, read) ->
    lists:foreach(fun(N) -> ets:lookup(test, N) end, lists:seq(1, 1000)),
    ok;

perform_test(mnesia, insert) ->
    mnesia:start(),
    mnesia:create_table(test, [{attributes, [key, value]}]),
    mnesia:transaction(fun() ->
        lists:foreach(fun(N) -> mnesia:write({test, N, N * 2}) end, lists:seq(1, 1000))
    end),
    ok;
perform_test(mnesia, update) ->
    mnesia:transaction(fun() ->
        lists:foreach(fun(N) -> mnesia:write({test, N, N * 3}) end, lists:seq(1, 1000))
    end),
    ok;
perform_test(mnesia, delete) ->
    mnesia:transaction(fun() ->
        lists:foreach(fun(N) -> mnesia:delete({test, N}) end, lists:seq(1, 1000))
    end),
    ok;
perform_test(mnesia, read) ->
    mnesia:transaction(fun() ->
        lists:foreach(fun(N) -> mnesia:read({test, N}) end, lists:seq(1, 1000))
    end),
    ok;

perform_test(maps, insert) ->
    Map = lists:foldl(fun(N, Acc) -> maps:put(N, N * 2, Acc) end, #{}, lists:seq(1, 1000)),
    Map;
perform_test(maps, update) ->
    Map = lists:foldl(fun(N, Acc) -> maps:put(N, N * 3, Acc) end, #{}, lists:seq(1, 1000)),
    Map;
perform_test(maps, delete) ->
    Map = lists:foldl(fun(N, Acc) -> maps:remove(N, Acc) end, #{}, lists:seq(1, 1000)),
    Map;
perform_test(maps, read) ->
    lists:foreach(fun(N) -> maps:get(N, #{1 => 2, 3 => 4}) end, lists:seq(1, 1000)),
    ok.
