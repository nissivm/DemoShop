# DemoShop
Shop demo using Stripe as payment gateway. Also uses Parses as backend.

<img src="https://cloud.githubusercontent.com/assets/6089173/12519924/6ee4b7ea-c120-11e5-9d2a-853a154856e3.png" alt="Sign Up" width="320" height="568"/>
<img src="https://cloud.githubusercontent.com/assets/6089173/12519922/6edd73fe-c120-11e5-9e47-8073b42e5b2a.png" alt="Products" width="320" height="568"/>
<img src="https://cloud.githubusercontent.com/assets/6089173/12519927/6ee6580c-c120-11e5-8677-1393c3b0d66c.png" alt="Shopping Cart" width="320" height="568"/>
<img src="https://cloud.githubusercontent.com/assets/6089173/12519926/6ee5cf68-c120-11e5-9930-93e27b9a3a11.png" alt="Checkout" width="320" height="568"/>
<img src="https://cloud.githubusercontent.com/assets/6089173/12519923/6ee43b8a-c120-11e5-9ab1-c13d67b7eba4.png" alt="Apple Pay" width="320" height="568"/>
<img src="https://cloud.githubusercontent.com/assets/6089173/12519925/6ee52bb2-c120-11e5-93fc-a1c373217648.png" alt="Credit Card" width="320" height="568"/>

### SETUP

Obs.: Maybe you'll have to change xcodeproj address in Podfile. After doing it, open project's main folder on Terminal, input "pod install" and press enter.

STRIPE SETUP:
- Create an Account at Stripe
- Input your Test Publishable Key on Constants class, in the project, and your Test Secret Key on payment.php, in the DemoShop-ServerSide folder.

APPLE PAY SETUP:
- Go to your Apple Developer Account and create a Merchant ID.
- Create an App ID including Apple Pay. 
	Obs.: Maybe you'll have to set a different bundle identifier for the app.
- Enabled Apple Pay using your Merchant ID.
- Create a development provisioning profile and sign the app with it.
- Go to project target and select your Merchant ID in Capabilities tab.

PARSE SETUP:
- Sign up in Parse and create an App.
- Input your credentials on Constants class, in the project.
- In the dashboard, go to Core and click on "Create a class".
- On type of class, select "User".
- Add column "name" to User class.

- Create class "ItemForSale".
- Add columns "position"(Number), "itemName"(String), "itemPrice"(Number) and "itemImage"(File).
- Fill the cells with the data contained in Parse Data folder:
	position fields => first row: 1, second row: 2 etc.
	objectId fields => double click inside the field and, when the cursor shows, click outside.
	itemImage fields => double click inside the field and a blue "Upload file" button will show. 

- Create class "Order" and add columns "chargeId"(String), "clientId"(String), "description"(String) and "chargeAmount"(Number).

TO TEST:
- Install Xamp, normally it is installed under the “Applications” folder.
- Close Xamp if open.
- Insert DemoShop-ServerSide folder (unzipped) in Applications/XAMPP/htdocs folder.
- Open Xamp, open Manage Servers tab and click "Start All".

Credit cards for testing: https://stripe.com/docs/testing
