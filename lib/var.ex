defmodule Var do
  # a variable should be implemented as records with the record name being the implementing module
  @type variable :: tuple()

  @callback unify(variable(), variable()) :: variable()
  @callback is_fixed(variable()) :: boolean()
  @callback value_if_fixed(variable()) :: term() | :undefined
  def unify(t1, t2) do
    impl = elem(t1, 0)
    ^impl = elem(t2, 0)
    impl.unify(t1, t2)
  end
  def is_fixed(t) do
    impl = elem(t, 0)
    impl.is_fixed(t)
  end
  def value_if_fixed(t) do
    impl = elem(t, 0)
    impl.value_if_fixed(t)
  end
end
