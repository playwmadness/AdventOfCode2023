defmodule Solution do

  def run([]), do: 0
  def run([x]), do: x
  def run(list) do
    subseq = 
      Enum.drop(list, 1)
      |> Enum.zip(list)
      |> Enum.map(fn {l, r} -> l - r end)
    last = List.last(list)
    if Enum.any?(subseq) do
      last + run(subseq)
    else
      last
    end
  end

  def process_line(l) do
    String.trim_trailing(l)
    |> String.split
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(fn {x, _} -> x end)
  end

end

[path] = System.argv

input =
  File.stream!(path)
  |> Stream.map(&Solution.process_line/1)
  |> Enum.to_list

res1 =
  input
  |> Enum.map(&Solution.run/1)
  |> Enum.sum

res2 = 
  input
  |> Enum.map(&Enum.reverse/1)
  |> Enum.map(&Solution.run/1)
  |> Enum.sum

IO.write "Result 1: "
IO.puts res1

IO.write "Result 2: "
IO.puts res2
