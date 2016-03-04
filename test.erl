-module(test).
-export([make_ring/1, parse/1, test_inserts/2]).

make_ring(N) ->
  P0 = node:join(0),
  T = lists:foldl(fun (X, Acc) -> timer:sleep(5000), H = node:join(X, P0), [H|Acc] end, [], lists:seq(1, N-1)),
  T ++ [P0].

test_inserts(Filename, N) ->
  [H | _] = make_ring(N),
  timer:sleep(10000),
  if
    Filename =:= def ->
      File = "insert.txt";
    Filename ->
      File = Filename
  end,
  L = parse(File),
  [node:store(Key, Val, H) || {Key, Val} <- L].


parse(Filename) ->
  {ok, Data} = file:read_file(Filename),
  D = binary_to_list(Data),
  Xs = string:tokens(D,",\n"),
  {Keys, Values} = split_it(Xs),
  lists:zip(Keys, Values).

split_it(L) -> split_it(L, [], []).

split_it([], Keys, Values) ->
  {Keys, Values};
split_it([X, Y|Xs], Keys, Values) ->
  {K, _} = string:to_integer(Y),
  split_it(Xs, [K|Keys], [X|Values]).

