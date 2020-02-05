defmodule Problem do
  def new do
    %{:vars => %{}, :varu => %{}, :const => []}
  end

  def register_var(p = %{:vars => v}, new) do
    name = make_ref()
    {%{p | :vars => Map.put(v, name, new)}, name}
  end

  def register_const(p = %{:const => l}, n) do
    %{p | :const => [n | l]}
  end

  def propagate(p = %{:const => c}), do: do_propagate(p, c)

  defp do_propagate(v, c) do
    case propagate(c, v, []) do
      :failed ->
        :failed

      {p, c} ->
        v = :maps.get(:vars, p)
        vu = :maps.get(:varu, p)

        case Enum.all?(v, fn
               {_key, {:unified, n}} -> Intvar.is_fixed(:maps.get(n, vu))
               {_key, value} -> Intvar.is_fixed(value)
             end) do
          true -> {:done, p}
          false -> {:not_done, %{p | :const => c}}
        end
    end
  end

  defp propagate([h | t], v, d) do
    case h.(v) do
      :failed -> :failed
      {:done, v} -> propagate(t, v, d)
      {:not_done, v, h} -> propagate(t, v, [h | d])
    end
  end

  defp propagate([], v, d), do: {v, d}

  def getvar(%{:vars => v, :varu => u}, n) do
    case :maps.get(n, v) do
      {:unified, uname} -> :maps.get(uname, u)
      v -> v
    end
  end

  def setvars(v, new) do
    Map.merge(v, new)
  end

  # This function does not attempt to GC unused variables in varu
  # the amount of garbage is at most size(vars) at the start of solving anyway
  # should be fine
  def unifyto(p = %{:vars => vars, :varu => varu}, names, new) do
    uname = make_ref()
    pointer = {:unified, uname}
    vars1 = set_lots(vars, names, pointer)
    %{p | :vars => vars1, :varu => Map.put(varu, uname, new)}
  end

  defp set_lots(map, [], _), do: map

  defp set_lots(map, [h | t], v) do
    set_lots(%{map | h => v}, t, v)
  end
end
