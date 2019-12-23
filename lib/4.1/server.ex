defmodule Proj4.Server do
    use GenServer

    def start_link(args) do
      {:ok,pid} = GenServer.start_link(__MODULE__, args, name: :server)
      {:ok,pid}
    end

    # def handle_call(:get_counter,_from,state) do
    #   state = state
    #   list = Enum.map(pid, fn x->
    #     [{_,_,tweet_counter}] = :ets.lookup(:accounts,x)
    #     tweet_counter
    #   end)
    #   {:reply,list,state}
    # end

    def init(_state) do
      :ets.new(:accounts,[:set,:public,:named_table])
      :ets.new(:followers,[:set,:public,:named_table])
      :ets.new(:following,[:set,:public,:named_table])
			:ets.new(:tweets,[:set,:public,:named_table])
			:ets.new(:feed,[:set,:public,:named_table])
      :ets.new(:hashtags,[:set,:public,:named_table])
      :ets.new(:mentions,[:set,:public,:named_table])
      IO.puts "Created tables"
      {:ok, {}}
    end

    # def handle_call(:get_counter_value,_from,state) do
    #   {:reply,counter,state}
    # end
    
    # def handle_call({:set_state,pid,numUsers,numMessages},_from,state) do
    #   {:reply,state,{pid,numUsers,numMessages,0}}
    # end

    def handle_call({:get_value,client_pid,socket},_from,state) do
      [{_,list}] = :ets.lookup(:following,client_pid)
      {:reply,list,state}
    end

    def handle_call({:set_hashtags_table,list},_from,state) do
      Enum.each(list, fn x ->
        :ets.insert(:hashtags,{x,[]})
      end)
      {:reply,state,state}
    end

    def handle_call({:set_mentions_table,pid},_from,state) do
      Enum.each(pid, fn x ->
        # IO.inspect x
        :ets.insert(:mentions,{x,[]})
      end)
      {:reply,state,state}
    end

    def handle_call({:create_account, client_pid,socket},_from,state) do
      :ets.insert(:accounts,{client_pid,1,0})
      :ets.insert(:tweets,{client_pid,[]})
      :ets.insert(:feed,{client_pid,[]})
      :ets.insert(:following,{client_pid,[]})
      {:reply,state,state}
    end

    def handle_call({:subscribe,client_pid,followers,socket},_from,state) do
      :ets.insert(:followers,{client_pid,followers})
      [{_,following_list}] = :ets.lookup(:following,followers)
      following_list = following_list ++ [client_pid]
      :ets.insert(:following,{followers,following_list})
      {:reply,state,state}
    end

    def handle_cast({:send_tweet_with_mention,client_pid,tweet,mention_pid},state) do
      [{_,_,tweet_counter}] = :ets.lookup(:accounts,client_pid)
      [{_,tweet_list}] = :ets.lookup(:tweets,client_pid)
      tweet_list = tweet_list ++ [tweet]
        # IO.inspect tweet
      :ets.insert(:tweets,{client_pid,tweet_list})
      [{_,following_list}] = :ets.lookup(:following,client_pid)
      Enum.each(following_list, fn x-> 
        [{_,feed}] = :ets.lookup(:feed,x)
        feed = feed ++ [tweet]
        :ets.insert(:feed,{x,feed})
      end)
      [{me,list}] = :ets.lookup(:mentions,mention_pid)
      list = list ++ [tweet]
      :ets.insert(:mentions,{mention_pid,list})
      tweet_counter = tweet_counter + 1
      :ets.insert(:accounts,{client_pid,1,tweet_counter})
      {:noreply,state}
    end

    def handle_cast({:send_tweet,client_pid,tweet,socket},state) do
      [{_,tweet_list}] = :ets.lookup(:tweets,client_pid)
      tweet_list = tweet_list ++ [tweet]
      :ets.insert(:tweets,{client_pid,tweet_list}) 
      [{_,following_list}] = :ets.lookup(:following,client_pid)
      Enum.each(following_list, fn x-> 
        [{_,feed}] = :ets.lookup(:feed,x)
        feed = feed ++ [tweet]
        :ets.insert(:feed,{x,feed})
      end)
      add_hashtags(tweet)
      add_mentions(tweet)
      {:noreply,state}
    end

    def handle_call({:get_mentions,mention,socket},_from,state) do
      [{_,list}] = :ets.lookup(:mentions,mention)
      {:reply,list,state}
    end

    def add_hashtags(tweet) do
      if(length(String.split(tweet,"#")) != 1) do
        [_,hashtag] = String.split(tweet,"#")
        hashtag = "#"<>hashtag
        # IO.inspect hashtag
        [{me,list}] = :ets.lookup(:hashtags,hashtag)
        list = list ++ [tweet]
        :ets.insert(:hashtags,{hashtag,list})
      end
    end

    def add_mentions(tweet) do
      if(length(String.split(tweet,"@")) != 1) do
        [_,mention] = String.split(tweet,"@")
        # IO.inspect hashtag
        [{me,list}] = :ets.lookup(:mentions,mention)
        list = list ++ [tweet]
        :ets.insert(:mentions,{mention,list})
      end
    end


    def handle_call({:get_feed, client_pid,socket}, _from, state) do
      [{_, feed}] = :ets.lookup(:feed, client_pid)
      # IO.inspect feed
      {:reply, feed, state}
    end

    def handle_call({:get_hashtags, hashtag, socket}, _from, state) do
      [{_, feed}] = :ets.lookup(:hashtags, hashtag)
      {:reply, feed, state}
    end

     def handle_call({:get_mentions, mention, socket}, _from, state) do
      [{_, feed}] = :ets.lookup(:mentions, mention)
      {:reply, feed, state}
    end

    # def handle_call({:get_users},_from,state) do
    #   {:reply,pid,state}
    # end

    def test() do
      IO.puts "Hello"
    end

    def handle_call(:test, _from, state) do
      {:ok, state, state}
    end

    def register_account(pid) do
      [{me,_,_}] = :ets.lookup(:accounts,pid)
      if(me == pid) do
        true
      else
        false
      end
    end

    def user_logged_in(pid) do
      [{_,connected,_}] = :ets.lookup(:accounts,pid)
      if(connected == 1) do
        true
      else
        false
      end
    end

    def logout(pid) do
      [{_,connected,_}] = :ets.lookup(:accounts,pid)
      connected = 0
      :ets.insert(:accounts,{pid,connected,0})
    end

    def isLoggedOut(pid) do
      [{_,connected,_}] = :ets.lookup(:accounts,pid)
      if(connected == 0) do
        true
      else
        false
      end
    end

    def handle_call({:get_tweets,client_pid},_from,state) do
      [{_,tweets}] = :ets.lookup(:tweets,client_pid)
      {:reply,tweets,state}
    end

    def handle_call({:get_following,client_pid},_from,state) do
      [{_,following}] = :ets.lookup(:following,client_pid)
      {:reply,following,state}
    end

    #use this for simulator subscribe
    
    def handle_call({:subscribe_simulator,client_pid,followers,socket},_from,state) do
      :ets.insert(:followers,{client_pid,followers})
      Enum.map(followers , fn x ->
        [{_,following_list}] = :ets.lookup(:following,x)
        following_list = following_list ++ [client_pid]
        :ets.insert(:following,{x,following_list})
      end)
      {:reply,state,state}
    end

    #use this for simulator send tweets

    def handle_cast({:send_tweet_simulator,client_pid,tweet,socket},state) do
      [{_,_,tweet_counter}] = :ets.lookup(:accounts,client_pid)
      [{_,tweet_list}] = :ets.lookup(:tweets,client_pid)
      tweet_list = tweet_list ++ [tweet]
      :ets.insert(:tweets,{client_pid,tweet_list}) 
      [{_,following_list}] = :ets.lookup(:following,client_pid)
      Enum.each(following_list, fn x-> 
        [{_,feed}] = :ets.lookup(:feed,x)
        feed = feed ++ [tweet]
        :ets.insert(:feed,{x,feed})
      end)
      # add_hashtags(tweet)
      {:noreply,state}
    end
end   
