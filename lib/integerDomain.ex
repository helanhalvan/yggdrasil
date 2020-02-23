defmodule IntegerDomain do
  @type intdomain() :: {integer(), integer(), %{}} | {}
  @spec new :: intdomain()
  def new() do
    {0, 10000, %{}}
  end

  @spec new(integer(), integer()) :: intdomain()
  def new(minsize, maxsize) do
    {minsize, maxsize, %{}}
  end

  @spec possible(integer(), intdomain()) :: any
  def possible(value, {min, max, d}) when min <= value and value <= max do
    Map.get(d, value, true)
  end

  def possible(_, _) do
    false
  end

  def forbid(value, d = {mindomain, maxdomain, _})
      when value < mindomain or maxdomain < value do
    d
  end

  def forbid(value, {value, maxdomain, d}) do
    {value + 1, maxdomain, d}
  end

  def forbid(value, {mindomain, value, d}) do
    {mindomain, value - 1, d}
  end

  def forbid(value, {mindomain, maxdomain, d}) do
    {mindomain, maxdomain, Map.put(d, value, false)}
  end

  @spec unify(intdomain(), intdomain()) :: {} | intdomain()
  def unify({min1, max1, _}, {min2, max2, _}) when min1 > max2 or min2 > max1 do
    {}
  end
  def unify({min1, max1, d1}, {min2, max2, d2}) do
    {max(min1, min2), min(max1, max2), Map.merge(d1, d2)}
  end
  def min({min, _max, _d}) do
    min
  end
  def max({_min, max, _d}) do
    max
  end
end
