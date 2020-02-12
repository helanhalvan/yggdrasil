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
       domain: IntegerDomain.new(mindomain, maxdomain)
     )}
  end

  # removes value from possible values for the set
  def forbid(value, {Setvar, setvar(domain: d)}) do
    d = IntegerDomain.forbid(value, d)
    {Setvar, setvar(domain: d)}
  end

  def possible(value, {Setvar, setvar(domain: d)}) do
    IntegerDomain.possible(value, d)
  end

  def unify(a = {Setvar, v}, {Setvar, v}), do: a

  def is_fixed({Setvar, setvar(is_fixed: b)}), do: b
  def value_if_fixed({Setvar, v = setvar(is_fixed: true)}), do: v
  def value_if_fixed({Setvar, setvar(is_fixed: false)}), do: :undefined
end
