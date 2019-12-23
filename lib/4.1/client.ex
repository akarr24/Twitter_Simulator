defmodule Proj4.ClientNode do
    use GenServer

    @server_name String.to_atom("server@127.0.0.1")

    def start_link(node) do
        {:ok, pid} = GenServer.start_link(__MODULE__, node)
        {:ok,pid}
      end
    
      def init(_args) do
        {:ok, 0}
      end

      def create_account(pid,numUser,numMessages) do
        Enum.map(pid, fn x -> 
          GenServer.call({:MyServer,@server_name}, {:create_account, x})
        end)
        
        Enum.map(pid, fn x ->
          list = Enum.to_list(2..numUser)
          number_of_followers = Enum.random(list)
          followers = Enum.take_random(pid -- [x],number_of_followers)
          GenServer.call({:MyServer,@server_name}, {:subscribe, x,followers})
        end)
        list = hashtags()
        GenServer.call({:MyServer,@server_name},{:set_hashtags_table,list})
        GenServer.call({:MyServer,@server_name},{:set_mentions_table,pid}) 
      end

      

      def handle_cast(:random,state) do
        list = Enum.to_list(1..7)
        num = Enum.random(list)
        case num do
          1 -> 
            send_tweet()
          2 ->
            send_tweet_with_hashtag()
          3 ->
            send_tweet_with_mentions()
          4 ->
            read_feed()
          5 ->
            retweet()
          6 ->
            query_random_hashtag()
          7 ->
            query_random_mention()
        end
        GenServer.cast(self(),:random)
        {:noreply, state}
      end

      def get_random_hashtag() do
        Enum.random(hashtags())
      end

      def send_tweet() do
        tweet = get_random_tweet()
        GenServer.cast({:MyServer,@server_name},{:send_tweet,self(),tweet})
      end

      def send_tweet_with_hashtag() do
        tweet = get_random_tweet()
        hashtag = get_random_hashtag()
        tweet = tweet <> hashtag
        GenServer.cast({:MyServer,@server_name},{:send_tweet,self(),tweet})
      end

      def query_random_mention() do
        users = GenServer.call({:MyServer,@server_name},{:get_users},25000)
        users = users -- [self()]
        mention = Enum.random(users)
        feed = GenServer.call({:MyServer,@server_name},{:get_mentions,mention},25000)
        if(length(feed) != 0) do
          IO.inspect feed
        end
      end

      def send_tweet_with_mentions() do
        tweet = get_random_tweet()
        users = GenServer.call({:MyServer,@server_name},{:get_users},25000)
        users = users -- [self()]
        mention = Enum.random(users)
        tweet = tweet <> "@" <> inspect(mention)
        GenServer.cast({:MyServer, @server_name}, {:send_tweet_with_mention, self(),tweet,mention})
      end

      def read_feed() do
        feed = GenServer.call({:MyServer, @server_name}, {:get_feed, self()},25000)
        if(length(feed) != 0) do
          # IO.inspect feed  
        end
      end

      def query_random_hashtag() do
        hashtag = get_random_hashtag()
        tweets_with_hashtags = GenServer.call({:MyServer, @server_name},{:get_hashtags,hashtag},25000)
        if(length(tweets_with_hashtags) != 0) do
          # IO.inspect tweets_with_hashtags
        end
      end

      def retweet() do
        feed = GenServer.call({:MyServer, @server_name}, {:get_feed, self()},25000)
        if(length(feed) != 0) do
          tweet = Enum.random(feed)
          tweet = "RT " <> tweet
          if(length(String.split(tweet,"@")) == 1) do
            GenServer.cast({:MyServer, @server_name}, {:send_tweet, self(), tweet})
          end
        end 
      end

      def tweet_list() do
        list = ["Han shot first", "Please dont call me arrogant, but Im European champion and I think Im a special one" ,"Frankly, my dear, I dont give a damn",
        "I am the one who knocks","Real Gs move in silence like lasagna","Madness, as you know, is like gravity, all it takes is a little push","Hes a silent guardian. A watchful protector",
        "Vada with Viswajith","Raghunath bro","Bohot Hard"]
        list
      end
  
      def get_random_tweet() do
        Enum.random(tweet_list())
      end

      def hashtags() do
        list = ["#COP5615 is great","#GGWP","#Go Gators","#MBDTF","#KTBFFH","#Blessed","#II360","#2065","#TPAB","#CalChuchesta","#MeToo","#Area51"]
      end
      
      def mentions() do
        list = ["animuku","aditya","smratirani","smartrrk"]
      end
end