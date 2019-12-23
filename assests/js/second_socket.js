import {Socket} from "phoenix"

//create a socket
let socket = new Socket("/socket", {params: {token: window.userToken}})
// connect the socket
socket.connect()

//variable for box
let mess_box = document.querySelector("#messages")

//create the channel
let channel = socket.channel("room:lobby", {})

//join the channel
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

// Register to User
function registerUser(user){
    //register the user
    // console.log("Done")
    channel.push("create_account", user)
    .receive("account_created", resp => console.log("account_created", resp))

}

// Subscribe to user
function subscribe_to_user(userName, subs){
    channel.push("subscribe", {userName: userName, subs: subs})
    .receive("subscribed", resp => console.log("subscribed_to_user", userName))
    console.log({userName: userName, subs: subs})
}

// Send tweet
function tweet(tweet, userName){
    channel.push("send_tweet", {tweet: tweet, userName: userName})
    //.receive("tweeted", resp => console.log("tweet", tweet))
    console.log({tweet: tweet, userName: userName})
    //console.log(subscribe.value)
    channel.push("shout", {tweet: tweet, userName: userName, subs: subscribe.value})
    //console.log(subscribe.value)
}

// Get hashtags
function get_hashtags(hashtag){
    channel.push("search_hashtags", {hashtag: hashtag})
    channel.on("hashtags", params =>{
        console.log(params["hashtags"])
        let list_item = document.createElement("li")
        list_item.innerHTML = `Tweets with hashtag ${hashtag}: ${params["hashtags"]} `
        mess_box.appendChild(list_item)
    })
}

function get_mentions(mention){
    channel.push("search_mentions", {mention: mention})
    channel.on("mentions", params => {
        console.log(params["mentions"])
        let list_item = document.createElement("li")
        list_item.innerHTML = `Tweets with mention ${userName.value}: ${params["mentions"]} `
        mess_box.appendChild(list_item)
    })
}


let userName = document.querySelector("#userName")
let  tweeted = document.querySelector("#tweet")
let subscribe = document.querySelector("#subscribe")
let hashtags = document.querySelector("#search_hashtag")
let mentions = document.querySelector("#mentions")
//event listner for account
userName.addEventListener("keypress", event =>
{
    if (event.keyCode === 13){
        registerUser(userName.value)
        let item = document.createElement("li")
        item.innerHTML = `User ${userName.value} logged in`
        mess_box.appendChild(item)
    }
})

//event listner for tweet
tweeted.addEventListener("keypress", event =>
{
    if(event.keyCode === 13){
        tweet(tweeted.value, userName.value)
        let list_item = document.createElement("li")
        list_item.innerHTML = `User ${userName.value} tweeted ${tweeted.value}`
        mess_box.appendChild(list_item)
    }
})

// event listner for subscriber
subscribe.addEventListener("keypress", event =>
{
    if(event.keyCode === 13){
        subscribe_to_user(userName.value, subscribe.value)
        let list_item = document.createElement("li")
        list_item.innerHTML = `User ${userName.value} subscribed to ${subscribe.value}`
        mess_box.appendChild(list_item)
    }
})

// event listner for hastag

hashtags.addEventListener("keypress", event =>
{
    if(event.keyCode === 13) {
        get_hashtags(hashtags.value)
    }
})

// event listner for mentions
mentions.addEventListener("keypress", event =>
{
    if(event.keyCode === 13){
        get_mentions(mentions.value)
    }
})

document.getElementById("read_feed").onclick = function(){
    
    channel.push("read_feed", {userName: userName.value})
    
}
channel.on("feeds", params =>{
    console.log(params["feeds"])
    let mess_div = document.createElement('div')
    let list_item = document.createElement("li")
    let retweet_button = document.createElement("button")
    console.log(params["feeds"])
    retweet_button.innerText = "Retweet"
    retweet_button.style.display = "inline"
    list_item.innerHTML = `Feed for ${userName.value}: ${params["feeds"]} `
    mess_div.appendChild(list_item)
    mess_div.appendChild(retweet_button)
    mess_box.appendChild(mess_div)
    retweet_button.addEventListener("click", () =>
    tweet("RT : ".concat(params["feeds"].toString()), userName.value))
      
})

channel.on("shout", params => {
    let mess_div = document.createElement('div')
    let list_item = document.createElement("li")
    let retweet_button = document.createElement("button")
    let username = params["userName"]
    let subs = params["subs"]
    let tweet_text = params["tweet"]

    console.log("userName:", userName.value)
    console.log("username: ", username )
    console.log("subs", subs[0])
    if(userName.value == subs[0]){
        retweet_button.innerText = "Retweet"
        retweet_button.style.display = "inline"
        list_item.innerHTML = `${tweet_text}`
        mess_div.appendChild(list_item)
        mess_div.appendChild(retweet_button)
        mess_box.appendChild(mess_div)
        retweet_button.addEventListener("click", () =>
        tweet("RT : ".concat(params["feeds"].toString()), userName.value))
    }
})

document.getElementById("register_user").onclick = function(){
    registerUser(userName.value)
        let item = document.createElement("li")
        item.innerHTML = `User ${userName.value} logged in`
        mess_box.appendChild(item)
}

document.getElementById("user_tweet").onclick = function(){
        tweet(tweeted.value, userName.value)
        let list_item = document.createElement("li")
        list_item.innerHTML = `User ${userName.value} tweeted ${tweeted.value}`
        mess_box.appendChild(list_item)
}

document.getElementById("subscribe_user").onclick = function(){
        subscribe_to_user(userName.value, subscribe.value)
        let list_item = document.createElement("li")
        list_item.innerHTML = `User ${userName.value} subscribed to ${subscribe.value}`
        mess_box.appendChild(list_item) 
}

document.getElementById("hashtag_button").onclick = function(){
    get_hashtags(hashtags.value)
}

document.getElementById("mentions_button").onclick = function(){
    get_mentions(mentions.value)
}

channel.on("send_tweet", params => {
    // let retweetButton = document.createElement("button")
    console.log("++++")
    let list_item = document.createElement("li")
    list_item.innerHTML = `Tweet: ${params.tweet}`
    retweetButton.innerText = "Retweet"
    retweetButton.style.display = "inline"
    retweetButton.addEventListener('click', () =>
    channel.push("retweet", {userName: userName.value, tweet: params.tweet})
    )
    console.log(list_item.innerText)
    mess_box.appendChild(list_item)
})
export default socket