defmodule Intvar do
  def new(v), do: {:intvar, :true, v}
  def new(v, v), do: {:intvar, :true, v}
  def new(min, max), do: {:intvar, :false, {min, max}}
  def is_fixed({:intvar, b, _}), do: b
  def value_if_fixed({:intvar, :true, v}), do: v
  def value_if_fixed({:intvar, :false, _}), do: :undef
  def interval({:intvar, :true, v}), do: {v, v}
  def interval({:intvar, :false, v}), do: v
  def isin({:intvar, :true, v}, v), do: :true
  def isin({:intvar, :false, {min, max}}, v) when min <= v and v <= max do
    :true
  end
  def isin(_, _), do: false
end
