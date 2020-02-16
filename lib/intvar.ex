defmodule Intvar do
  @behaviour Var
  def new(v), do: {Intvar, true, v}
  def new(v, v), do: {Intvar, true, v}
  def new(min, max), do: {Intvar, false, {min, max}}
  def split({Intvar, false, {min, max}}) do
    {{Intvar, false, {min, max - 1}}, {Intvar, true, max}}
  end
  def unify(a = {Intvar, fixed, value}, {Intvar, fixed, value}), do: a
  def unify(a = {Intvar, true, v}, {Intvar, true, v}), do: a
  def unify({Intvar, true, _}, {Intvar, true, _}), do: :failed
  def unify(a = {Intvar, false, _}, b = {Intvar, true, _}), do: unify(b, a)

  def unify(a = {Intvar, true, v}, {Intvar, false, {min, max}}) when min <= v and v <= max do
    a
  end

  def unify({Intvar, true, _}, {Intvar, false, _}) do
    :failed
  end

  def unify({Intvar, false, {min, max1}}, {Intvar, false, {min, max2}}) do
    new(min, min(max1, max2))
  end

  def unify({Intvar, false, {min1, max}}, {Intvar, false, {min2, max}}) do
    new(max(min1, min2), max)
  end

  def unify({Intvar, false, {min, _}}, {Intvar, false, {_, max}}) when min > max do
    :failed
  end

  def unify({Intvar, false, {_, max}}, {Intvar, false, {min, _}}) when min > max do
    :failed
  end

  def unify({Intvar, false, {min1, max1}}, {Intvar, false, {min2, max2}}) do
    new(max(min1, min2), min(max1, max2))
  end

  def is_fixed({Intvar, b, _}), do: b
  def value_if_fixed({Intvar, true, v}), do: v
  def value_if_fixed({Intvar, false, _}), do: :undefined
  def interval({Intvar, true, v}), do: {v, v}
  def interval({Intvar, false, v}), do: v
  def isin({Intvar, true, v}, v), do: true

  def isin({Intvar, false, {min, max}}, v) when min <= v and v <= max do
    true
  end

  def isin(_, _), do: false
end
