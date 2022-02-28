defmodule Cuid.TableOwner do
  @moduledoc """
  GenServer process to own the ETS table used for the Cuid counter.
  """
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    state = Cuid.new()

    :persistent_term.put(Cuid, state)

    {:ok, state}
  end
end
