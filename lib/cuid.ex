defmodule Cuid do
  @moduledoc """
  Collision-resistant ids.

  Usage:

  ```elixir
  Cuid.generate()
  ``
  """

  @opaque state :: {binary(), :ets.tid()}

  @base 36
  @discrete_values @base * @base * @base * @base
  @max_discrete_value @discrete_values - 1
  @two_discrete_values @discrete_values * @discrete_values
  @max_two_discrete_value @two_discrete_values - 1

  @doc """
  Generates and returns a new CUID.
  """
  @spec generate() :: String.t()
  @spec generate(state) :: String.t()
  def generate({fingerprint, table} \\ global_state()) do
    count = :ets.update_counter(table, :counter, {2, 1, @max_discrete_value, 0})

    IO.iodata_to_binary([
      ?c,
      timestamp(),
      format_counter(count),
      fingerprint,
      random_block()
    ])
  end

  @doc """
  Get the global state.

  If you're generating a lot of IDs in the same process, this can avoid re-fetching the state on each call.
  """
  @spec global_state :: state
  def global_state() do
    :persistent_term.get(__MODULE__)
  end

  @doc """
  Creates a new generator state.
  """
  def new() do
    fingerprint = get_fingerprint()

    tab =
      :ets.new(__MODULE__, [:public, :set, {:read_concurrency, true}, {:write_concurrency, true}])

    :ets.insert(tab, {:counter, 0})

    {fingerprint, tab}
  end

  ## Helpers

  defp format_counter(num) do
    num
    |> Integer.to_charlist(@base)
    |> zero_pad_down()
  end

  defp timestamp do
    microseconds = :os.system_time(:microsecond)

    rem(microseconds, @two_discrete_values)
    |> Integer.to_charlist(@base)
    |> zero_pad_down_big()
  end

  defp random_block do
    @max_two_discrete_value
    |> :rand.uniform()
    |> Integer.to_charlist(@base)
    |> zero_pad_down_big()
  end

  @operator @base * @base

  defp get_fingerprint do
    pid = rem(String.to_integer(System.get_pid()), @operator) * @operator

    hostname = to_charlist(:net_adm.localhost())
    hostid = rem(Enum.sum(hostname) + Enum.count(hostname) + @base, @operator)

    (pid + hostid)
    |> Integer.to_charlist(@base)
    |> zero_pad_down()
  end

  @compile {:inline, zero_pad_down: 1, zero_pad_down_big: 1, downcase_num: 1}

  defp zero_pad_down(charlist) do
    case charlist do
      [a, b, c, d] ->
        [downcase_num(a), downcase_num(b), downcase_num(c), downcase_num(d)]

      [a, b, c] ->
        [?0, downcase_num(a), downcase_num(b), downcase_num(c)]

      [a, b] ->
        ["00", downcase_num(a), downcase_num(b)]

      [a] ->
        ["000", downcase_num(a)]
    end
  end

  defp zero_pad_down_big(charlist) do
    case charlist do
      [a, b, c, d, e, f, g, h] ->
        [
          downcase_num(a),
          downcase_num(b),
          downcase_num(c),
          downcase_num(d),
          downcase_num(e),
          downcase_num(f),
          downcase_num(g),
          downcase_num(h)
        ]

      [a, b, c, d, e, f, g] ->
        [
          ?0,
          downcase_num(a),
          downcase_num(b),
          downcase_num(c),
          downcase_num(d),
          downcase_num(e),
          downcase_num(f),
          downcase_num(g)
        ]

      [a, b, c, d, e, f] ->
        [
          "00",
          downcase_num(a),
          downcase_num(b),
          downcase_num(c),
          downcase_num(d),
          downcase_num(e),
          downcase_num(f)
        ]

      [a, b, c, d, e] ->
        [
          "000",
          downcase_num(a),
          downcase_num(b),
          downcase_num(c),
          downcase_num(d),
          downcase_num(e)
        ]

      [a, b, c, d] ->
        ["0000", downcase_num(a), downcase_num(b), downcase_num(c), downcase_num(d)]

      [a, b, c] ->
        ["00000", downcase_num(a), downcase_num(b), downcase_num(c)]

      [a, b] ->
        ["000000", downcase_num(a), downcase_num(b)]

      [a] ->
        ["0000000", downcase_num(a)]
    end
  end

  @downcase_index ?a - ?A

  defp downcase_num(letter) when letter > ?9, do: letter + @downcase_index
  defp downcase_num(number), do: number
end
