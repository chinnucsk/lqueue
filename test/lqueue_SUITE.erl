-module(lqueue_SUITE).

-include_lib("common_test/include/ct.hrl").

%% ct.
-export([all/0,
         groups/0,
         init_per_test_suite/1,
         end_per_test_suite/1,
         init_per_group/2,
         end_per_group/2]).

%% Tests.
-export([creation/1,
         inspection/1,
         conversion/1,
         in_out/1,
         in_out2/1,
         reverse/1,
         join/1]).

%% ct.
all() ->
    [creation,
     inspection,
     conversion,
     in_out,
     in_out2,
     reverse,
     join].

groups() ->
    [].

init_per_test_suite(Config) ->
    Config.

end_per_test_suite(_Config) ->
    ok.

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, Config) ->
    Config.

%% tests
creation(_Config) ->
    badarg = try
                 lqueue:new(0)
             catch
                 error:E1 ->
                     E1
             end,
    badarg = try
                 lqueue:new(-1)
             catch
                 error:E2 ->
                     E2
           end,
    lqueue:new(1),
    ok.

inspection(_Config) ->
    %% empty lqueue, max == 1
    LQ0 = lqueue:new(1),
    true = lqueue:is_lqueue(LQ0),
    true = lqueue:is_empty(LQ0),
    false = lqueue:is_full(LQ0),
    1 = lqueue:max_len(LQ0),
    0 = lqueue:len(LQ0),
    false = lqueue:member(0, LQ0),
    %% 1 element, max == 1
    LQ1 = lqueue:in(atom, LQ0),
    true = lqueue:is_lqueue(LQ1),
    false = lqueue:is_empty(LQ1),
    true = lqueue:is_full(LQ1),
    1 = lqueue:max_len(LQ1),
    1 = lqueue:len(LQ1),
    true = lqueue:member(atom, LQ1),
    %% 1 element, max == 1
    LQ2 = lqueue:in(-1, LQ1),
    true = lqueue:is_lqueue(LQ2),
    false = lqueue:is_empty(LQ2),
    true = lqueue:is_full(LQ2),
    1 = lqueue:max_len(LQ2),
    1 = lqueue:len(LQ2),
    true = lqueue:member(-1, LQ2),
    %% 1 element, max == 2
    LQ3 = lqueue:new(2),
    LQ4 = lqueue:in("abc", LQ3),
    false = lqueue:is_empty(LQ4),
    false = lqueue:is_full(LQ4),
    2 = lqueue:max_len(LQ4),
    1 = lqueue:len(LQ4),
    true = lqueue:member("abc", LQ4),
    false = lqueue:member(1000, LQ4),
    LQ5 = {0, 10, [], not_list},
    false = lqueue:is_lqueue(LQ5),
    badarg = try
                 lqueue:is_empty(LQ5)
             catch
                 error:E1 ->
                     E1
             end,
    badarg = try
                 lqueue:is_full(LQ5)
             catch
                 error:E2 ->
                     E2
             end,
    badarg = try
                 lqueue:max_len(LQ5)
             catch
                 error:E3 ->
                     E3
             end,
    badarg = try
                 lqueue:len(LQ5)
             catch
                 error:E4 ->
                     E4
             end,
    badarg = try
                 lqueue:member(x, LQ5)
             catch
                 error:E5 ->
                     E5
             end,
    ok.

conversion(_Config) ->
    LQ0 = lqueue:new(1),
    [] = lqueue:to_list(LQ0),
    LQ1 = lqueue:in(5, LQ0),
    [5] = lqueue:to_list(LQ1),
    LQ2 = lqueue:in(10, LQ1),
    [10] = lqueue:to_list(LQ2),
    LQ3 = lqueue:from_list([1,2,3], 3),
    [1, 2, 3] = lqueue:to_list(lqueue:from_list(lqueue:to_list(LQ3), 3)),
    LQ4 = lqueue:from_list([["abc"], ["def"]], 10),
    [["abc"], ["def"]] = lqueue:to_list(LQ4),
    LQ5 = lqueue:from_list([], 10),
    [] = lqueue:to_list(LQ5),
    LQ6 = {0, 0, [a, b, c], []},
    badarg = try
                 lqueue:to_list(LQ6)
             catch
                 error:E1 ->
                     E1
             end,
    badarg = try
                 lqueue:from_list([1,2], 1)
             catch
                 error:E2 ->
                     E2
             end,
    ok.

in_out(_Config) ->
    LQ0 = lqueue:new(3),
    LQ1 = lqueue:in(10, LQ0),
    LQ2 = lqueue:in(20, LQ1),
    LQ3 = lqueue:in(30, LQ2),
    [10, 20, 30] = lqueue:to_list(LQ3),
    LQ4 = lqueue:in(40, LQ3),
    [20, 30, 40] = lqueue:to_list(LQ4),
    LQ5 = lqueue:in(50, LQ4),
    [30, 40, 50] = lqueue:to_list(LQ5),
    LQ6 = lqueue:in_r(60, LQ5),
    [60, 30, 40] = lqueue:to_list(LQ6),
    LQ7 = lqueue:in_r(70, LQ6),
    [70, 60, 30] = lqueue:to_list(LQ7),
    {{value, 70}, LQ8} = lqueue:out(LQ7),
    {{value, 60}, LQ9} = lqueue:out(LQ8),
    {{value, 30}, LQ10} = lqueue:out(LQ9),
    {empty, _} = lqueue:out(LQ10),
    {empty, _} = lqueue:out_r(LQ10),
    LQ11 = lqueue:in(80, LQ10),
    LQ12 = lqueue:in(90, LQ11),
    {{value, 90}, LQ13} = lqueue:out_r(LQ12),
    {{value, 80}, LQ14} = lqueue:out_r(LQ13),
    LQ15 = lqueue:in_r(atom1, LQ14),
    LQ16 = lqueue:in_r(atom2, LQ15),
    LQ17 = lqueue:in_r(atom3, LQ16),
    LQ18 = lqueue:in_r(atom4, LQ17),
    [atom4, atom3, atom2] = lqueue:to_list(LQ18),
    {{value, atom4}, LQ19} = lqueue:out(LQ18),
    {{value, atom3}, LQ20} = lqueue:out(LQ19),
    {{value, atom2}, LQ21} = lqueue:out(LQ20),
    {empty, _} = lqueue:out(LQ21),
    {{value, atom2}, LQ22} = lqueue:out_r(LQ18),
    {{value, atom3}, LQ23} = lqueue:out_r(LQ22),
    {{value, atom4}, LQ24} = lqueue:out_r(LQ23),
    {empty, _} = lqueue:out_r(LQ24),
    LQ25 = {not_lqueue},
    badarg = try
                 lqueue:in("ABC", LQ25)
             catch
                 error:E1 ->
                     E1
             end,
    badarg = try
                 lqueue:in_r(x, LQ25)
             catch
                 error:E2 ->
                     E2
             end,
    badarg = try
                 lqueue:out(LQ25)
             catch
                 error:E3 ->
                     E3
             end,
    badarg = try
                 lqueue:out_r(LQ25)
             catch
                 error:E4 ->
                     E4
             end,
    ok.

in_out2(_Config) ->
    LQ0 = lqueue:new(2),
    LQ1 = lqueue:in(a1, LQ0),
    LQ2 = lqueue:in(a2, LQ1),
    a1 = lqueue:get(LQ2),
    a2 = lqueue:get_r(LQ2),
    {value, a1} = lqueue:peek(LQ2),
    {value, a2} = lqueue:peek_r(LQ2),
    LQ3 = lqueue:drop_r(LQ2),
    1 = lqueue:len(LQ3),
    a1 = lqueue:get_r(LQ3),
    LQ4 = lqueue:drop(LQ3),
    0 = lqueue:len(LQ4),
    empty = lqueue:peek(LQ4),
    LQ5 = lqueue:new(3),
    LQ6 = lqueue:in(1, LQ5),
    1 = lqueue:get(LQ6),
    LQ7 = lqueue:in(2, LQ6),
    1 = lqueue:get(LQ7),
    LQ8 = lqueue:in(3, LQ7),
    1 = lqueue:get(LQ8),
    3 = lqueue:get_r(LQ8),
    LQ9 = lqueue:in(4, LQ8),
    2 = lqueue:get(LQ9),
    4 = lqueue:get_r(LQ9),
    empty = try
                lqueue:drop(LQ4)
            catch
                error:E1 ->
                    E1
            end,
    empty = try
               lqueue:drop_r(LQ4)
            catch
                error:E2 ->
                    E2
            end,
    ok.

reverse(_Config) ->
    LQ0 = lqueue:new(1),
    [] = lqueue:to_list(lqueue:reverse(LQ0)),
    LQ1 = lqueue:from_list([1, 2, 3], 3),
    [1, 2, 3] = lqueue:to_list(lqueue:reverse(lqueue:reverse(LQ1))),
    LQ2 = {0, 1, not_list, []},
    badarg = try
                 lqueue:reverse(LQ2)
             catch
                 error:E ->
                     E
             end,
    ok.

join(_Config) ->
    LQ0 = lqueue:from_list([a, b], 3),
    LQ1 = lqueue:from_list([c, d], 2),
    LQ2 = lqueue:join(LQ0, LQ1),
    [a, b, c, d] = lqueue:to_list(LQ2),
    4 = lqueue:len(LQ2),
    5 = lqueue:max_len(LQ2),
    LQ3 = lqueue:new(1),
    LQ4 = lqueue:new(1),
    LQ5 = lqueue:join(LQ3, LQ4),
    [] = lqueue:to_list(LQ5),
    0 = lqueue:len(LQ5),
    2 = lqueue:max_len(LQ5),
    LQ6 = {0, 0, [], []},
    badarg = try
                 lqueue:join(LQ5, LQ6)
             catch
                 error:E ->
                     E
             end,
    ok.
