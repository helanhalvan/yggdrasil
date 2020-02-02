defmodule Intvar do
  def new(v) do
    {:intvar, :true, v}
  end
  def new(v, v) do
    {:intvar, :true, v}
  end
  def new(min, max) do
    {:intvar, :false, {min, max}}
  end
  def is_fixed({:intvar, b, _}) do
    b
  end
  def value_if_fixed({:intvar, :true, v}) do
    v
  end
  def value_if_fixed({:intvar, :false, _}) do
    :undef
  end
  def interval({:intvar, :true, v}) do
    {v, v}
  end
  def interval({:intvar, :false, v}) do
    v
  end
  def isin({:intvar, :true, v}, v) do
    :true
  end
  def isin({:intvar, :false, {min, max}}, v) when min < v and v < max do
    :true
  end
  def isin(_, _) do
    false
  end
end
