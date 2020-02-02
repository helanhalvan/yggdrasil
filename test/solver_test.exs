defmodule SolverTest do
  use ExUnit.Case
  doctest Solver

  test "equals problem" do
    p = Problem.new()
    x = Intvar.new(1, 5)
    y = Intvar.new(5, 10)
    {p, xn} = Problem.register_var(p, x)
    {p, yn} = Problem.register_var(p, y)
    c = Equals.new([xn, yn])
    p = Problem.register_const(p, c)
    %{ ^xn => 5, ^yn => 5} = Problem.solve(p)
  end
end
