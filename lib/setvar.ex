defmodule Setvar do
  require Record

  Record.defrecord(:setvar,
    is_fixed: false,
    minsize: 0,
    maxsize: :infinity,
    domain: {0, :infinity},
    values: %{}
  )

  @behaviour Var
  def new_intset(minsize, maxsize, mindomain, maxdomain) do
    {Setvar,
     setvar(
       minsize: minsize,
       maxsize: maxsize,
       domain: {mindomain, maxdomain, []}
     )}
  end

  # removes value from possible values for the set
  def forbid(value, {Setvar, setvar(domain: d)}) do
    d = do_forbid(value, d)
    {Setvar, setvar(domain: d)}
  end

  def possible(value, {Setvar, setvar(domain: d)}) do
    do_possible(value, d)
  end

  defp do_possible(value, {mindomain, maxdomain, _})
       when value < mindomain or maxdomain < value do
    false
  end

  defp do_possible(value, {_, _, d}) do
    do_possible(value, d)
  end

  defp do_possible(_value, []), do: true
  defp do_possible(value, [value]), do: false

  defp do_possible(value, {{_, lowermax, _}, {uppermin, _, _}})
       when lowermax < value and value < uppermin,
       do: false
  defp do_possible(value, {{_, lowermax, d}, _}) when value <= lowermax do
     do_possible(value, d)
  end
  defp do_possible(value, {_, {uppermin, _, d}}) when value >= uppermin do
     do_possible(value, d)
  end

  defp do_forbid(value, d = {mindomain, maxdomain, _})
       when value < mindomain or maxdomain < value do
    d
  end

  defp do_forbid(value, {mindomain, maxdomain, []}) do
    {mindomain, maxdomain, [value]}
  end

  defp do_forbid(value, d = {_mindomain, _maxdomain, [value]}) do
    d
  end

  defp do_forbid(new, {mindomain, maxdomain, [old]}) when new + 1 == old do
    {mindomain, maxdomain, {{mindomain, new - 1, []}, {old + 1, maxdomain, []}}}
  end

  defp do_forbid(new, {mindomain, maxdomain, [old]}) when old + 1 == new do
    {mindomain, maxdomain, {{mindomain, old - 1, []}, {new + 1, maxdomain, []}}}
  end

  def unify(a = {Setvar, v}, {Setvar, v}), do: a

  def is_fixed({Setvar, setvar(is_fixed: b)}), do: b
  def value_if_fixed({Setvar, v = setvar(is_fixed: true)}), do: v
  def value_if_fixed({Setvar, setvar(is_fixed: false)}), do: :undefined
end
