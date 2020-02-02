defmodule Problem do
  def new do
    %{:vars => %{}, :varc => 0, :const => []}
  end

  def register_var(p = %{:vars => v, :varc => c}, n) do
    {%{p | :vars => Map.put(v, c, n), :varc => c + 1}, c}
  end

  def register_const(p = %{:const => l}, n) do
    %{p | :const => [n | l]}
  end

  def solve(%{:vars => v, :const => c}) do
    {v, _c} = propagate(c, v, [])

    case Enum.all?(v, fn {_key, value} -> Intvar.is_fixed(value) end) do
      true -> solution(v)
      false -> :todo
    end
  end

  defp solution(v) do
    :maps.map( fn(_key, value) -> Intvar.value_if_fixed(value) end, v)
  end

  def propagate([h | t], v, d) do
    case h.(v) do
      :failed -> :failed
      {:done, v} -> propagate(t, v, d)
      {:not_done, h, v} -> propagate(t, v, [h | d])
    end
  end

  def propagate([], v, d) do
    {v, d}
  end

  def getvar(v, n) do
    Map.get(v, n)
  end

  def setvars(v, new) do
    Map.merge(v, new)
  end
end
