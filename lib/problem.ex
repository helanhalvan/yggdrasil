defmodule Problem do
  @type const :: (problem -> :failed | {problem, [const]})
  @opaque name :: reference()
  @opaque problem :: %{
            :const => [const],
            :vars => %{optional(name) => Var.variable() | {:unified, name}},
            :varu => %{optional(name) => {Var.variable(), [name]}}
          }

  @spec new :: problem
  def new do
    %{:vars => %{}, :varu => %{}, :const => []}
  end

  @spec register_var(problem, any) :: {problem, name}
  def register_var(p = %{:vars => v}, new) do
    name = make_ref()
    {%{p | :vars => Map.put(v, name, new)}, name}
  end

  @spec register_const(problem, any) :: problem
  def register_const(p = %{:const => l}, n) do
    %{p | :const => [n | l]}
  end

  @spec propagate(problem) ::
          :failed | :no_constraints | {:done, problem} | {:not_done, problem}
  def propagate(%{:const => []}), do: :no_constraints
  def propagate(p = %{:const => c}), do: do_propagate(p, c)

  defp do_propagate(p, c) do
    case propagate(c, p, []) do
      :failed ->
        :failed

      {p, c} ->
        p = %{p | :const => c}

        done =
          case c do
            [] -> :done
            _ -> :not_done
          end

        {done, p}
    end
  end

  defp propagate([h | t], p, d) do
    case h.(p) do
      :failed -> :failed
      {p, []} -> propagate(t, p, d)
      {p, c} -> propagate(t, p, c ++ d)
    end
  end

  defp propagate([], p, d), do: {p, d}

  @spec get_var(problem, name) :: any
  def get_var(%{:vars => v, :varu => u}, n) do
    case :maps.get(n, v) do
      {:unified, uname} ->
        {a, _} = :maps.get(uname, u)
        a

      v ->
        v
    end
  end

  @spec get_vars(problem) :: [{name, any}]
  def get_vars(%{:vars => v, :varu => u}) do
    vlist = Map.to_list(v)

    vlist =
      :lists.filter(
        fn
          {_, {:unified, _}} -> false
          _ -> true
        end,
        vlist
      )

    ulist = Map.to_list(u)
    ulist = :lists.map(fn {n, {v, _}} -> {n, v} end, ulist)
    vlist ++ ulist
  end

  @spec set_var(problem, name, any) :: problem
  def set_var(p = %{:vars => vars, :varu => varu}, name, value) do
    case :maps.get(name, vars, :undef) do
      {:unified, name} ->
        {_, names} = :maps.get(name, varu)
        %{p | :varu => %{varu | name => {value, names}}}

      :undef ->
        {_, names} = :maps.get(name, varu)
        %{p | :varu => %{varu | name => {value, names}}}

      _ ->
        %{p | :vars => %{vars | name => value}}
    end
  end

  # pretty format for a solved problem
  @spec solution(problem) :: %{name => Var.variable()}
  def solution(p) do
    vars = :maps.get(:vars, p)
    varu = :maps.get(:varu, p)

    :maps.map(
      fn
        _key, {:unified, a} ->
          {var, _} = :maps.get(a, varu)
          Var.value_if_fixed(var)

        _key, value ->
          Var.value_if_fixed(value)
      end,
      vars
    )
  end

  # unfiying already unfied variables is not handled nicely
  @spec unifyto(problem, [name], any) :: problem
  def unifyto(p = %{:vars => vars, :varu => varu}, names, new) do
    uname = make_ref()
    pointer = {:unified, uname}
    {vars, varu} = set_all(names, vars, varu, pointer)
    varu = Map.put(varu, uname, {new, names})
    %{p | :vars => vars, :varu => varu}
  end

  defp set_all([], vars, varu, _), do: {vars, varu}

  defp set_all([h | t], vars, varu, pointer) do
    case Map.get(vars, h, :undef) do
      :undef ->
        case :maps.take(h, varu) do
          {{_, names}, varu} ->
            set_all(names ++ t, vars, varu, pointer)
        end
      _ -> set_all(t, %{vars | h => pointer }, varu, pointer)
    end
  end
end
