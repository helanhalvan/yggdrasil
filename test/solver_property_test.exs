defmodule SolverTestP do
  use ExUnit.Case, async: true
  use ExUnitProperties

  property "set domain update" do
    check all(list <- list_of(integer(0..100))) do
      v = Setvar.new_intset(100, 0, 100)
      test_sequence(list, v, %{})
    end
  end
  property "domain unify" do
    check all(list <- list_of({boolean(),integer(0..100)})) do
      v = Setvar.new_intset(100, 0, 100)
      v1 = Setvar.new_intset(100, 0, 100)
      test_sequence(list, v, v1, %{})
    end
  end

  defp test_sequence([], _, _, _), do: :ok
  defp test_sequence([{a,h}|t], s1, s2, m) do
    m = Map.put(m, h, false)
    {s1, s2} = case a do
      true -> {s1, Setvar.forbid(h, s2)}
      false -> {Setvar.forbid(h, s1), s2}
    end
    s = Setvar.unify(s1, s2)
    for i <- 0..100 do
      assert Setvar.possible(i, s) == Map.get(m, i, true)
    end
    test_sequence(t, s1, s2, m)
  end

  defp test_sequence([], _, _), do: :ok
  defp test_sequence([h|t], s, m) do
    m = Map.put(m, h, false)
    s = Setvar.forbid(h, s)
    for i <- 0..100 do
      assert Setvar.possible(i, s) == Map.get(m, i, true)
    end
    test_sequence(t, s, m)
  end
end
