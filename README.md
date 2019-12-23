# Twitter

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## Link to demo video:
https://youtu.be/yYx9fQfTnaA

## Running Simulator:
• Go to assets > js > app.js and uncomment the line import socket from “./socket” if not already uncommented, and comment the line import socket from “./second_socket”
• The simulator is set to run on 100 websockets by default. Change the value num_of_clients to change the number of websockets.
• Go the terminal, making sure you’re in the right directory run the command mix phx.server.
• Open a browser and run localhost:4000 to start the simulator.

## Running Individual client:
• Go to assets > js > app.js and uncomment the line import socket from “./second_socket” if not already uncommented, and comment the line import socket from “./socket”
• From the terminal, run the command phx.server. Once the server starts follow the next step.
• Multiple clients can be open by opening multiple localhosts.
• The client webpage provides functionalities like Login, Tweet, Subscribe, Search hashtags, and search mentions. The feed for the user is dynamically generated.
• To login, type the account name in the login box and press register button.
• To tweet, enter the string in the tweet field and press the tweet button.
• To subscribe to user, enter the user name in the subscribe text field and click subscribe button.
• To query a hashtag, enter the hashtag string in the hashtag input field and enter the query hashtag button.
• To find your mentions, enter your user name in the mentions input text field and enter the query mentions button.


## Simulator Mode:
In simulator mode, we simulate the working of twitter environment. Just like in our previous projects, we create 100 clients each with its own websocket to communicate with the server. Each websocket is used to emulate a single user in the twitter ecosystem. The users are registered and assigned subscriber randomly. Each user in the system perform operations like tweeting, querying hashtags, subscribing to other users, and searching for mentions selecting each action randomly.

## Client Mode:
We run the client mode on localhost:4000 in our browser. We create a single-socket connection between the server and the client. Multiple clients can be invoked by running localhost:4000 on multiple tabs though there operate on same channel. The user first enters his username for login purpose. One logged-in, the user can perform activities like tweeting, subscribing to other users, searching hashtags, and searching for his mentions. The dynamically generated feed shows the user tweets from users he has subscribed to. The pictures from the next page describes the features and functionalities of our application.
