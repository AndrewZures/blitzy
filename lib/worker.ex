defmodule Blitzy.Worker do
  use Timex
  require Logger

  def start(url, caller, func \\ &HTTPoison.get/1) do
    IO.puts "checking #{url} - Running on #node-#{node}"
    {timestamp, response} = Duration.measure(fn -> func.(url) end)
    send(caller, handle_response({Duration.to_milliseconds(timestamp), response}))
  end

  defp handle_response({msecs, {:ok, %HTTPoison.Response{status_code: code}}}) when code >= 200 and code <= 304 do
    # Logger.info "worker [#{node}-#{inspect self()}] completed in #{msecs} msecs"
    {:ok, msecs}
  end

  defp handle_response({_msecs, {:error, reason}}) do
    # Logger.info "worker [#{node}-#{inspect self()}] error to #{inspect reason}"
    {:error, reason}
  end

  defp handle_response({_msecs, _}) do
    # Logger.info "worker [#{node}-#{inspect self()}] errored out"
    {:error, :unknown}
  end

end
