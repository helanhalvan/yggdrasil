# fixed size set
defmodule Setvar do
  require Record

  Record.defrecord(:setvar,
    is_fixed: false,
    size: 10000,
    domain: {0, 10000},
    values: %{}
  )

  @behaviour Var
  def new_intset(size, mindomain, maxdomain) do
    {Setvar,
     setvar(
       size: size,
       domain: IntegerDomain.new(mindomain, maxdomain)
     )}
  end

  # removes value from possible values for the set
  def forbid(value, {Setvar, a = setvar(domain: d)}) do
    d = IntegerDomain.forbid(value, d)
    {Setvar, setvar(a, domain: d)}
  end

  def require(value, {Setvar, a = setvar(size: size, domain: d, is_fixed: fixed, values: values)}) do
    case Map.has_key?(values, value) do
      true ->
        {Setvar, a}

      false ->
        case fixed do
          true ->
            :failed

          false ->
            case IntegerDomain.possible(value, d) do
              false ->
                :failed

              true ->
                {Setvar,
                 setvar(a,
                   values: Map.put(values, value, true),
                   is_fixed: size == Kernel.map_size(values) + 1
                 )}
            end
        end
    end
  end

  def required({Setvar, setvar(values: v)}) do
    v
  end

  def possible(value, {Setvar, setvar(domain: d)}) do
    IntegerDomain.possible(value, d)
  end

  def unify(a = {Setvar, v}, {Setvar, v}), do: a

  def unify(
        {Setvar, a = setvar(domain: d1, size: s, values: v1)},
        {Setvar, setvar(domain: d2, size: s, values: v2)}
      ) do
    v = Map.merge(v1, v2)

    case {Kernel.map_size(v), s} do
      {a, b} when a > b -> :failed
      {a, a} -> {Setvar, setvar(a, domain: IntegerDomain.unify(d1, d2), is_fixed: true)}
      {_, _} -> {Setvar, setvar(a, domain: IntegerDomain.unify(d1, d2))}
    end
  end

  def unify(_, _), do: :failed

  def is_fixed({Setvar, setvar(is_fixed: v)}), do: v
  def value_if_fixed({Setvar, v = setvar(is_fixed: true)}), do: v
  def value_if_fixed({Setvar, setvar(is_fixed: false)}), do: :undefined
end
