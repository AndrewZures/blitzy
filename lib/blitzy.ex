defmodule Blitzy do
  def start(_type, _args) do
    Blitzy.Supervisor.start_link(:ok)
  end
end
