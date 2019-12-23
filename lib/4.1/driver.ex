defmodule Proj4.Driver do
    @server_name String.to_atom("server@127.0.0.1")
    def start_tweeting(pid,send_pid,numUser,numMessages,start_time) do
        Enum.each(pid, fn x-> 
            GenServer.cast(x, :random)
        end)
        wait_till_clients_stopped(pid,send_pid,numUser,numMessages,start_time)
    end

    def wait_till_clients_stopped(pid,send_pid,numUser,numMessages,start_time) do
        list= GenServer.call({:MyServer,@server_name},:get_counter,25000)
        list = Enum.filter(list, fn x-> 
            x >= numMessages
        end)

        if(length(list) == numUser) do
            :global.sync()
            IO.puts "Simulation complete. Check server terminal for statistics"
            send(:global.whereis_name(:runner),{:done,start_time})
        else
            wait_till_clients_stopped(pid,send_pid,numUser,numMessages,start_time)
        end
    end
end