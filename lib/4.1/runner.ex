defmodule Proj4.Runner do
@server_name String.to_atom("server@127.0.0.1")

def start(_type,cli_args) do
   if(Enum.at(cli_args,0) == "server" ) do
      Node.start (@server_name)
      Node.set_cookie :proj4
      Proj4.ServerSupervisor.start()
      :global.sync()
      :global.register_name(:runner,self())
      Proj4.Runner.wait_till_stopping_condition_reached()

    else
      numUser = String.to_integer(Enum.at(cli_args,0))
      numMessages = String.to_integer(Enum.at(cli_args, 1))
      simulator_name = "simulator@127.0.0.1"
      Node.start (String.to_atom(simulator_name))
      Node.set_cookie :proj4
      IO.inspect {Node.self, Node.get_cookie} 
      Node.connect(@server_name)
      :global.sync()
      pid = Proj4.ClientSupervisor.start(numUser, numMessages)
      GenServer.call({:MyServer,@server_name},{:set_state,pid,numUser,numMessages})
      Proj4.ClientNode.create_account(pid,numUser,numMessages)
      start_time = System.monotonic_time(:millisecond)
      Proj4.Driver.start_tweeting(pid,self(),numUser,numMessages,start_time)
    end
  end

  def wait_till_stopping_condition_reached() do
    receive do
      {:done,start_time} ->
        end_time = System.monotonic_time(:millisecond)
        total_time = end_time - start_time
        counter = GenServer.call({:MyServer,@server_name},:get_counter_value)
        IO.inspect(counter, label: "Number of activities")
        IO.inspect(counter / total_time, label: "Activities performed per millisecond")
    end
    wait_till_stopping_condition_reached()
  end

  def main() do
    cli_args = System.argv()
    Proj4.Runner.start(cli_args,cli_args)
  end
end
