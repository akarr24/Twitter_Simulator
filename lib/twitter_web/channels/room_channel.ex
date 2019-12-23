defmodule TwitterWeb.RoomChannel do
    use Phoenix.Channel

    def join("room:lobby", _params, socket) do
        {:ok, socket}
    end

    def handle_in("create_account", userName, socket) do
        GenServer.call(:server, {:create_account, userName, socket})
        list = Proj4.ClientNode.hashtags()
        GenServer.call(:server,{:set_hashtags_table,list})
        list = Proj4.ClientNode.mentions()
        GenServer.call(:server,{:set_mentions_table,list})
        push socket, "account_created", %{"userName" => userName }   
        {:reply, :account_created, socket}
    end

    def handle_in("send_tweet", params, socket) do
        tweet = params["tweet"]
        userName = params["userName"]
        GenServer.cast(:server,{:send_tweet,userName,tweet,socket})
        push socket,"tweeted",%{"tweet" => tweet}
        {:reply,:tweeted,socket}
    end

    def handle_in("send_tweet_simulator", params, socket) do
        tweet = params["tweet"]
        userName = params["userName"]
        GenServer.cast(:server,{:send_tweet_simulator,userName,tweet,socket})
        push socket,"tweeted",%{"tweet" => tweet}
        {:reply,:tweeted,socket}
    end

    def handle_in("subscribe", params, socket) do
        userName = params["userName"]
        subs = params["subs"]
        GenServer.call(:server, {:subscribe, userName, subs, socket})
        push socket, "subscribed", %{"userName" => userName}
        {:reply, :subscribed, socket}
    end

    def handle_in("subscribe_simulator", params, socket) do
        userName = params["userName"]
        subs = params["subs"]
        GenServer.call(:server, {:subscribe_simulator, userName, subs, socket})
        push socket, "subscribed", %{"userName" => userName}
        {:reply, :subscribed, socket}
    end

    def handle_in("read_feed", params, socket) do
        userName = params["userName"]
        feed = GenServer.call(:server, {:get_feed, userName,socket})
        IO.inspect feed
        push socket, "feeds", %{"feeds" => feed}
        {:reply, :feeds, socket}
    end

    def handle_in("search_hashtags", params, socket) do
        hashtags = params["hashtag"]
        #IO.inspect hashtags
        retrived = GenServer.call(:server, {:get_hashtags, hashtags, socket})
        push socket, "hashtags", %{"hashtags" => retrived}
        {:reply, :hashtags, socket}

    end

    def handle_in("search_mentions", params, socket) do
        mentions = params["mention"]
        get_met = GenServer.call(:server, {:get_mentions, mentions, socket})
        push socket, "mentions", %{"mentions" => get_met}
        {:reply, :mentions, socket}
    end


    # def handle_info(tweet, socket) do
    #     push socket, "twitter_feed", tweet
    #     {:noreply, socket}
    # end

    def handle_in("shout", params, socket) do
        username = params["userName"]
        list = GenServer.call(:server, {:get_value,username,socket})
        params = Map.put(params,"subs",list)
        broadcast(socket, "shout", params )
        {:noreply, socket}
    end
    def handle_in("send_tweet", %{"tweet" => tweet}, socket) do
        #tweet = params["tweet"]
        push socket, "send_tweet", %{tweet: tweet} 
        {:noreply, socket}
      end

end