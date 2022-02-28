Benchee.run(
  %{
    "generate" => fn {mod, fun, args} -> apply(mod, fun, args) end
  },
  inputs: %{
    new: {Cuid, :generate, 1},
    new_global: {Cuid, :generate, 0}
  },
  parallel: 4,
  time: 5,
  before_scenario: fn {mod, fun, arity} ->
    state =
      cond do
        function_exported?(mod, :global_state, 0) ->
          mod.global_state()

        true ->
          {:ok, pid} = mod.start_link()
          pid
      end

    if arity == 1 do
      {mod, fun, [state]}
    else
      {mod, fun, []}
    end
  end
)
