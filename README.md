# AI Tester
Fifth portfolio project for the iOS Developer Nanodegree Program at Udacity.

## App Description
Virtual assistants are becoming nowadays extremely popular. Chatbots are used everyday for customer support, shopping, education, entertainment and many other purposes.

This app is designed for developers who build conversational interfaces based on the api.ai technology. Api.ai (https://api.ai) is a popular platform for creating artificial intelligence agents which can be easily integrated into apps, webpages and physical devices. 

The “AI Tester” iPad app allows simultaneous testing and comparing of several artificial intelligence agents.


## Screenshots
Agents screen
![alt text](https://farm2.staticflickr.com/1712/25874373724_32ff923352_z.jpg "Agents screen")

Tests screen
![alt text](https://farm2.staticflickr.com/1572/26479248685_29f71d7eb5_z.jpg "Tests screen")

Chat with AI agents screen
![alt text](https://farm2.staticflickr.com/1647/25874373694_99dd15f34b_z.jpg "Chat with AI agents screen")


## Demo test and agents
The “AI Tester” app contains one demo test and three demo agents. Since these are only demo agents, they were trained with a limited corpora of knowledge. Nevertheless, you can greet them and ask basic questions.

You are also highly welcome to create and train your own agents for free at https://api.ai and add them to the “AI Tester” by using only the agent’s “Client access token”.

## How to use the app

1. Sign up for free at http://www.api.ai
2. Create and train there your artificial intelligence agent.
3. On the agents settings screen copy to clipboard the agent’s “Client access token”
4. Open the “AI Tester” app on iPad, go to the “Agents” tab, add your new agent and paste the “Client access token” for it. Add as many agents as you wish.
5. Go to the “Tests” tab and add a test.
6. Choose in picker view the agents  which you would like to test side by side. It is not compulsory to choose a different agent for each column. If you choose the same agent for two or more columns you will be able to see how this agent may react in different ways to the same request.
7. Tap the “Run test” button. A window with three chats will appear. Here you can test your agent(s).
8. You can go back by pressing the “Tests” button in the upper left corner.
9. All the chat history is saved for your future reference. If you wish you can delete it by pressing the “Delete test history”.

## Dependencies
The “AI Tester” app using the following open-source libraries and SDKs installed via the Cocoapods:

* ‘JSQMessagesViewController'
* ‘UnderKeyboard'
* ‘ApiAI'
* ‘SwiftyJSON'


## Running the app
* Download and unzip file. 
* Open and run the “AI_Tester.xcworkspace” file (not the AI Tester.xcodeproj!)

If you have difficulties with compiling the app because of the third party libraries, do the following:

* In xCode run “Product - Clean”

If this does not help, then:

* Open the terminal
* cd the folder in which the app is situated
* Run the “pod update” command in terminal

More information on Cocoapods can be found here: https://cocoapods.org. 


## Enjoy! :)
