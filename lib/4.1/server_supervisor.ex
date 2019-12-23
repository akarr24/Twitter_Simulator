defmodule Proj4.ServerSupervisor do
    def start() do
        children = [Supervisor.child_spec({Proj4.Server, []}, id: Proj4.Server, restart: :permanent)]
        opts = [strategy: :one_for_one, name: Proj4.ServerSupervisor]
        Supervisor.start_link(children, opts) 
    end
end