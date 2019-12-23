defmodule Proj4.NodeSupervisor do
    def create_workers(numUsers) do
        list = Enum.to_list(1..numUsers)
        children =
          Enum.map(list, fn x ->
            Supervisor.child_spec({Proj4.Node, []}, id: x, restart: :permanent)
          end)
        opts = [strategy: :one_for_one, name: Proj4.NodeSupervisor]
        Supervisor.start_link(children, opts)
  
        result = Supervisor.which_children(Proj4.NodeSupervisor)
        Enum.map(result, fn {_, child, _, _} -> child end)
      end
end