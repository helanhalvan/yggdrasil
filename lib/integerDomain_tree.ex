defmodule IntegerDomain_tree do
  def new() do
    {0, 10000, []}
  end

  def new(minsize, maxsize) do
    {minsize, maxsize, []}
  end

  def possible(_value, {}), do: false
  def possible(_value, []), do: true
  def possible(value, [value]), do: false
  def possible(_, [_]), do: true

  def possible(value, {min, max, d}) when min <= value and value <= max do
    possible(value, d)
  end

  def possible(_value, {_, _, _}), do: false

  def possible(value, {min, max, d, _, _, _}) when min <= value and value <= max do
    possible(value, d)
  end

  def possible(value, {_, _, _, min, max, d}) when min <= value and value <= max do
    possible(value, d)
  end

  def possible(_value, {_, _, _, _, _, _}), do: false

  def forbid(value, d = {mindomain, maxdomain, _})
      when value < mindomain or maxdomain < value do
    d
  end

  def forbid(new, {new, new, _}) do
    {}
  end

  def forbid(value, {value, maxdomain, d}) do
    {value + 1, maxdomain, d}
  end

  def forbid(value, {mindomain, value, d}) do
    {mindomain, value - 1, d}
  end

  def forbid(value, {mindomain, maxdomain, []}) do
    {mindomain, maxdomain, [value]}
  end

  def forbid(value, d = {_mindomain, _maxdomain, [value]}) do
    d
  end

  def forbid(new, {min, max, [old]}) do
    split(min, max, new, old)
  end

  # GC empty domains
  def forbid(new, {_, _, {}, min, max, d}) do
    forbid(new, {min, max, d})
  end

  def forbid(new, {min, max, d, _, _, {}}) do
    forbid(new, {min, max, d})
  end

  def forbid(new, {new, new, _, min, max, d}) do
    {min, max, d}
  end

  def forbid(new, {min, max, d, new, new, _}) do
    {min, max, d}
  end

  def forbid(new, {min1, max1, [], min2, max2, d2}) when min1 < new and new < max1 do
    {min1, max1, [new], min2, max2, d2}
  end

  def forbid(new, {min1, max1, d1, min2, max2, []}) when min2 < new and new < max2 do
    {min1, max1, d1, min2, max2, [new]}
  end

  def forbid(new, {new, max1, d1, min2, max2, d2}) do
    {new + 1, max1, d1, min2, max2, d2}
  end

  def forbid(new, {min1, new, d1, min2, max2, d2}) do
    {min1, new - 1, d1, min2, max2, d2}
  end

  def forbid(new, {min1, max1, d1, min2, new, d2}) do
    {min1, max1, d1, min2, new - 1, d2}
  end

  def forbid(new, {min1, max1, d1, new, max2, d2}) do
    {min1, max1, d1, new + 1, max2, d2}
  end
  def forbid(same, {same, same, _, min, max, d}) do
    {min, max, d}
  end
  def forbid(same, {min, max, d, same, same, _}) do
    {min, max, d}
  end

  def forbid(new, {min1, max1, [old], min2, max2, d2}) when min1 < new and new < max1 do
    case split(min1, max1, old, new) do
      {min1, max1, d1} -> {min1, max1, d1, min2, max2, d2}
      {} -> {min2, max2, d2}
      d1 -> {min1, max1, d1, min2, max2, d2}
    end
  end

  def forbid(new, {min1, max1, d1, min2, max2, [old]}) when min2 < new and new < max2 do
    case split(min2, max2, old, new) do
      {min2, max2, d2} -> {min1, max1, d1, min2, max2, d2}
      {} -> {min1, max1, d1}
      d2 -> {min1, max1, d1, min2, max2, d2}
    end
  end

  def forbid(new, {min1, max1, d1, min2, max2, d2}) when min2 < new and new < max2 do
    {min1, max1, d1, min2, max2, forbid(new, d2)}
  end

  def forbid(new, {min1, max1, d1, min2, max2, d2}) when min1 < new and new < max1 do
    {min1, max1, forbid(new, d1), min2, max2, d2}
  end

  def forbid(_, d) do
    d
  end

  defp split(same, same, same, _) do
    {}
  end
  defp split(same, same, _, same) do
    {}
  end
  defp split(min, max, same, same) do
    {min, max, [same]}
  end
  defp split(min, max, small, large) when small > large do
    split(min, max, large, small)
  end
  defp split(min, max, small, large) when small + 1 == large do
   {min, small - 1, [], large + 1, max, []}
  end
  defp split(min, max, small, large) do
    avg = (min+max)/2
    case abs(avg - small) > abs(avg - large) do
      true -> {min, large-1, [small], large+1, max, []}
      false -> {min, small-1, [], small+1, max, [large]}
    end
  end

  def unify(d, d), do: d
  def unify({}, _), do: {}
  def unify(_, {}), do: {}
  def unify([], d), do: d
  def unify(d, []), do: d
  def unify(a = {_, _, _, _, _, _}, b = {_, _, _}), do: unify(b, a)
  def unify({min1, max1, _}, {min2, max2, _}) when min1 > max2 or min2 > max1 do
    {}
  end
  def unify({min1, max1, [f1]}, {min2, max2, [f2]}) do
    split(max(min1, min2), min(max1, max2), f1, f2)
  end
  def unify({min1, max1, d1}, {min2, max2, d2}) do
    {max(min1, min2), min(max1, max2), unify(d1, d2)}
  end
  def unify({min1, max1, _}, {min2, _, _, _, max2, _}) when min1 > max2 or min2 > max1 do
    {}
  end
  def unify(d1 = {_, max1, _}, {min2, max2, d2, _, _, _}) when max1 <= max2 do
    unify(d1, {min2, max2, d2})
  end
  def unify(d1 = {min1, _, _}, {_, _, _, min2, max2, d2}) when min1 >= min2 do
    unify(d1, {min2, max2, d2})
  end
  def unify({min1, max1, []}, {min2, max2, d1, min3, max3, d2}) do
    min = max(min1, min2)
    max = min(max1, max3)
    {min, max2, d1, min3, max, d2}
  end
  def unify({min1, max1, [f1]}, {min2, max2, [], min3, max3, [f3]}) when min2 <= f1 and f1 <= max2 do
    min = max(min1, min2)
    max = min(max1, max3)
    {min, max2, [f1], min3, max, [f3]}
  end
  def unify({min1, max1, [f1]}, {min2, max2, [f2], min3, max3, []}) when min3 <= f1 and f1 <= max3 do
    min = max(min1, min2)
    max = min(max1, max3)
    {min, max2, [f2], min3, max, [f1]}
  end
  def unify({min1, max1, [f1]}, {min2, max2, [], min3, max3, [f3]}) do
    min = max(min1, min2)
    max = min(max1, max3)
    case split(min3, max, f1, f3) do
      {} -> {min, max2, []}
      {min3, max3, d3} -> {min, max2, [], min3, max3, d3}
      d -> {min, max2, [], min3, max, d}
    end
  end
  def unify({min1, max1, [f1]}, {min2, max2, [f3], min3, max3, []}) do
    min = max(min1, min2)
    max = min(max1, max3)
    case split(min, max2, f1, f3) do
      {} -> {min3, max, []}
      {min3, max3, d3} -> {min3, max3, d3, min3, max, []}
      d -> {min, max2, d, min3, max, []}
    end
  end
  def unify({min1, max1, [f1]}, {min2, max2, [f2], min3, max3, [f3]}) do
    min = max(min1, min2)
    max = min(max1, max3)
    case {split(min, max2, f1, f2), split(min3, max, f1, f3)} do
      {{min1, max1, d1}, {min2, max2, d2}} -> {min1, max1, d1, min2, max2, d2}
      {{}, d} -> d
      {d, {}} -> d
    end
  end
  def unify({min1, max1, d1}, {min2, max2, d2, min3, max3, d3}) do
    min = max(min1, min2)
    max = min(max1, max3)
    {min, max2, unify(d1, d2), min3, max, unify(d1, d3)}
  end

  def unify({min, _, _, _, _, _}, {_, _, _, _, max, _}) when min > max do
    {}
  end
  def unify({_, _, _, _, max, _}, {min, _, _, _, _, _}) when min > max do
    {}
  end
  def unify(d1 = {min, _, _, _, _, _}, {_, max, _, min2, max2, d2}) when min > max do
    unify(d1, {min2, max2, d2})
  end
  def unify({_, max, _, min2, max2, d2}, d1 = {min, _, _, _, _, _}) when min > max do
    unify(d1, {min2, max2, d2})
  end

end
