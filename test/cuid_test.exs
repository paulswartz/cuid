defmodule CuidTest do
  use ExUnit.Case, async: true
  require Cuid

  test "generate string" do
    assert is_binary(Cuid.generate())
  end

  test "format" do
    for _ <- 0..500_000 do
      c = Cuid.generate()
      assert <<"c", _::binary-24>> = c
    end
  end

  test "collision" do
    number_of_iterations = 200_000

    result =
      stream()
      |> Stream.take(number_of_iterations)
      |> MapSet.new()

    assert MapSet.size(result) == number_of_iterations
  end

  test "multi-process collision" do
    number_of_iterations = 100_000
    task_count = 16

    tasks =
      for _ <- 1..task_count do
        Task.async(fn ->
          stream()
          |> Stream.take(number_of_iterations)
          |> MapSet.new()
        end)
      end

    result_set =
      Enum.reduce(tasks, MapSet.new(), fn task, set ->
        task
        |> Task.await()
        |> MapSet.union(set)
      end)

    assert MapSet.size(result_set) == number_of_iterations * task_count
  end

  defp stream do
    Stream.repeatedly(&Cuid.generate/0)
  end
end
