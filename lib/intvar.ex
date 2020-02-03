defmodule Intvar do
  def new(v), do: {:intvar, true, v}
  def new(v, v), do: {:intvar, true, v}
  def new(min, max), do: {:intvar, false, {min, max}}

  def unify(a = {:intvar, fixed, value}, {:intvar, fixed, value}), do: a
  def unify(a = {:intvar, true, v}, {:intvar, true, v}), do: a
  def unify({:intvar, true, _}, {:intvar, true, _}), do: :failed
  def unify(a = {:intvar, false, _}, b = {:intvar, true, _}), do: unify(b, a)

  def unify(a = {:intvar, true, v}, {:intvar, false, {min, max}}) when min <= v and v <= max do
    a
  end

  def unify({:intvar, true, _}, {:intvar, false, _}) do
    :failed
  end

  def unify({:intvar, false, {min, max1}}, {:intvar, false, {min, max2}}) do
    {:intvar, false, {min, min(max1, max2)}}
  end

  def unify({:intvar, false, {min1, max}}, {:intvar, false, {min2, max}}) do
    {:intvar, false, {max(min1, min2), max}}
  end

  def unify({:intvar, false, {min, _}}, {:intvar, false, {_, max}}) when min > max do
    :failed
  end

  def unify({:intvar, false, {_, max}}, {:intvar, false, {min, _}}) when min > max do
    :failed
  end

  def unify({:intvar, false, {min1, max1}}, {:intvar, false, {min2, max2}}) do
    {:intvar, false, {max(min1, min2), min(max1, max2)}}
  end

  def is_fixed({:intvar, b, _}), do: b
  def value_if_fixed({:intvar, true, v}), do: v
  def value_if_fixed({:intvar, false, _}), do: :undef
  def interval({:intvar, true, v}), do: {v, v}
  def interval({:intvar, false, v}), do: v
  def isin({:intvar, true, v}, v), do: true

  def isin({:intvar, false, {min, max}}, v) when min <= v and v <= max do
    true
  end

  def isin(_, _), do: false
end
