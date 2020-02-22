# fixed size set
defmodule Setvar do
  require Record

  Record.defrecord(:setvar,
    is_fixed: false,
    size: 10000,
    domain: IntegerDomain.new(0, 10000),
    values: %MapSet{}
  )

  @type setvar_int() :: record(:setvar, is_fixed: boolean(), size: integer(), values: %MapSet{})
  @type setvar() :: {Setvar, setvar_int()}
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
    case MapSet.member?(values, value) do
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
                   values: MapSet.put(values, value),
                   is_fixed: size == MapSet.size(values) + 1
                 )}
            end
        end
    end
  end

  def split({Setvar, setvar(is_fixed: true)}) do
    :failed
  end

  def split({Setvar, var = setvar(values: v, size: size, domain: domain)}) do
    min = IntegerDomain.min(domain)
    max = IntegerDomain.max(domain)
    new = find(min, max, v)
    fixed = size == MapSet.size(v) + 1

    {{Setvar, setvar(var, values: MapSet.put(v, new), is_fixed: fixed)},
     {Setvar, setvar(var, values: v, domain: IntegerDomain.forbid(new, domain))}}
  end

  defp find(curr, max, v) do
    case MapSet.member?(v, curr) do
      false -> curr
      true -> find(curr + 1, max, v)
    end
  end

  def required({Setvar, setvar(values: v)}) do
    v
  end

  def possible(value, {Setvar, setvar(domain: d)}) do
    IntegerDomain.possible(value, d)
  end

  @spec unify(setvar(), setvar()) :: :failed | setvar()
  def unify(a = {Setvar, v}, {Setvar, v}), do: a

  def unify(
        {Setvar, a = setvar(domain: d1, size: s, values: v1)},
        {Setvar, setvar(domain: d2, size: s, values: v2)}
      ) do
    v = MapSet.union(v1, v2)

    case {MapSet.size(v), s} do
      {a, b} when a > b ->
        :failed

      {equal, equal} ->
        domain = IntegerDomain.unify(d1, d2)
        {Setvar, setvar(a, domain: domain, is_fixed: true, values: v)}

      {_, _} ->
        {Setvar, setvar(a, domain: IntegerDomain.unify(d1, d2), values: v)}
    end
  end

  def unify(_, _), do: :failed

  def is_fixed({Setvar, setvar(is_fixed: v)}), do: v
  def value_if_fixed({Setvar, v = setvar(is_fixed: true)}), do: v
  def value_if_fixed({Setvar, setvar(is_fixed: false)}), do: :undefined
end
