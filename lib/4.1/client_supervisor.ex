defmodule Proj4.ClientSupervisor do
  def start(numUsers,numMessage) do
	list = Enum.to_list(1..numUsers)
  children =
    Enum.map(list, fn x ->
    Supervisor.child_spec({Proj4.ClientNode, []}, id: x, restart: :permanent)
    end)
	
	opts = [strategy: :one_for_one, name: Proj4.ClientSupervisor]
	Supervisor.start_link(children,opts)
  result = Supervisor.which_children(Proj4.ClientSupervisor)
  Enum.map(result, fn {_, child, _, _} -> child end)
  end
end