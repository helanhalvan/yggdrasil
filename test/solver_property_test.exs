defmodule SolverTestP do
  use ExUnit.Case, async: true
  use ExUnitProperties

  property "set domain update" do
    check all(list <- list_of(integer(0..100))) do
      v = Setvar.new_intset(0, :infinity, 0, :infinity)
      possible = %{}
      test_sequence(list, v, %{})
    end
  end
  defp test_sequence([], _, _), do: :ok
  defp test_sequence([h|t], s, m) do
    assert Setvar.possible(h, s) == Map.get(m, h, true)
    m = Map.put(m, h, false)
    s = Setvar.forbid(h, s)
    assert Setvar.possible(h, s) == false
    test_sequence(t, s, m)
  end
end
