defmodule Blitzy.Caller do

  def start(n_workers, url) do
    me = self()
    worker_fun = fn -> Blitzy.Worker.start(url, me) end
    1..n_workers
    |> Enum.map(fn _ -> Task.async(worker_fun) end)
    |> Enum.map(&Task.await(&1, :infinity))
    |> parse_results
  end

  def parse_results(results) do
    {successes, failures} = results |> partition_results

    total_workers = Enum.count(results)
    total_successes = Enum.count(successes)
    total_failures = Enum.count(failures)

    data = successes |> Enum.map(fn {:ok, time} -> time end)
    average_time = average(data)
    longest_time = Enum.max(data)
    shortest_time = Enum.min(data)

    IO.puts """
    Total workers    : #{total_workers}
    Total successes  : #{total_successes}
    Total failures   : #{total_failures}
    Average (msecs)  : #{average_time}
    Longest (msecs)  : #{longest_time}
    Shortest (msecs) : #{shortest_time}
    """
  end

  defp average(list) do
    sum = Enum.sum(list)
    if sum > 0 do
      sum / Enum.count(list)
    else
      0
    end
  end


  defp partition_results(results) do
    results |> Enum.partition(fn x -> case x do
      {:ok, _} -> true
      _        -> false
    end
    end)
  end

end
