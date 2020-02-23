-module(setvar).

-export([new/3, forbid/2, require/2, split/1, possible/2, unify/2,
         is_fixed/1, value_if_fixed/1, disjoint/2]).

-behaviour('Elixir.Var').

-record(setvar,
        {is_fixed = false  :: boolean(), size = 10000  :: integer(),
         domain = 'Elixir.IntegerDomain':new(0, 10000)  ::
           'Elixir.IntegerDomain':intdomain(),
         values = sets:new()  :: sets:set()}).

new(Size, Min, Max) ->
  #setvar{size = Size, domain = 'Elixir.IntegerDomain':new(Min, Max)}.

forbid(N, V = #setvar{domain = D}) ->
  D1 = 'Elixir.IntegerDomain':forbid(N, D), V#setvar{domain = D1}.

require(N, Var = #setvar{size = S, domain = D, is_fixed = F, values = V}) ->
  case sets:is_element(N, V) of
    true -> Var;
    false ->
      case F of
        true -> failed;
        false ->
          case 'Elixir.IntegerDomain':possible(N, D) of
            false -> failed;
            true -> Var#setvar{is_fixed = S == sets:size(V) + 1, values = sets:add_element(N, V)}
          end
      end
  end.

disjoint(#setvar{ values = V1}, #setvar{ values = V2}) ->
  sets:is_disjoint(V1, V2).

split(#setvar{is_fixed = true}) -> failed;
split(Var = #setvar{size = S, domain = D, values = V}) ->
  Min = 'Elixir.IntegerDomain':min(D),
  Max = 'Elixir.IntegerDomain':max(D),
  case find(Min, Max, V) of
    failed -> failed;
    New ->
      Fixed = S == sets:size(V) + 1,
      {Var#setvar{values = sets:add_element(New, V), is_fixed = Fixed},
       Var#setvar{domain = 'Elixir.IntegerDomain':forbid(New, D)}}
  end.

find(C, C, _) -> failed;
find(C, M, V) ->
  case sets:is_element(C, V) of
    false -> C;
    true -> find(C + 1, M, V)
  end.

possible(V, #setvar{domain = D}) -> 'Elixir.IntegerDomain':possible(V, D).

unify(A, A) -> A;
unify(A = #setvar{domain = D1, size = S, values = V2},
      #setvar{domain = D2, size = S, values = V1}) ->
  V = sets:union(V1, V2),
  case sets:size(V) of
    VS when VS > S -> failed;
    S2 ->
      case 'Elixir.IntegerDomain':unify(D1, D2) of
        {} -> failed;
        D -> A#setvar{domain = D, is_fixed = S2 == S, values = V}
      end
  end;
unify(_, _) -> failed.

is_fixed(#setvar{is_fixed = F}) -> F.

value_if_fixed(#setvar{is_fixed = false}) -> undefined;
value_if_fixed(#setvar{values = V}) -> sets:to_list(V).

