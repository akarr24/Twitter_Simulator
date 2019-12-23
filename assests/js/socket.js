// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"
var userName
var cList = []
var sList = []
let num_of_clients = 100
let userNameList = []



register()
subscribe()
start_tweeting()

function register(){
  for(var i = 0; i < num_of_clients; i++){
    userName = "client:"+i
    let socket = new Socket("/socket", {params: {token: window.userToken}})
    userNameList[i] = userName   
    socket.connect()  
    sList[i] = socket
    let channel = socket.channel("room:lobby", {})
    cList[i] = channel
    channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
  channel.push("create_account", userNameList[i])
  }
}

function subscribe(){
  var subscriberList = []
  var i = 0
  var j = 0
  for(i = 0; i < num_of_clients; i++){
    subscriberList = []
      for(j = 0; j < 2; j++){
      var random_user  = userNameList[Math.floor(Math.random() * userNameList.length)]
      subscriberList.push(random_user)
      }
    sList[i].push(subscriberList)
    cList[i].push("subscribe_simulator", {userName : userNameList[i], subs : subscriberList })
  }
}

  function start_tweeting()
  {
    let actions = ["send_tweet","read_feed"]
    console.log("Started tweeting")
    while(true)
    {
      for(var i = 0 ;i<num_of_clients;i++)
      {
        var action = actions[Math.floor(Math.random() * actions.length)]

        if(action === "send_tweet")
        {
          console.log("sending tweets")
          let tweetText = "tweeting something"
          console.log(tweetText)
          cList[i].push("send_tweet_simulator", {tweet: tweetText,
          userName: userNameList[i]},)
        }
        else
        {
            console.log("reading feed")
            cList[i].push("read_feed",{
            userName: userNameList[i]},)
        }
      }
    }
  }
export default socket
