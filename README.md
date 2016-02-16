# DemoShop
Shop demo using Stripe as payment gateway. The purchase can be made using Apple Pay or regularly with Credit Card. Also, uses a PHP+MySql backend.

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

BACKEND SETUP:
- Install Xamp.
- In the web browser, go to phpMyAdmin (http://localhost/phpmyadmin/).
- Create a new database called "shop_manager".
- Enter shop_manager and create 3 tables using the queries in phpMyAdmin.rtf.
- Fill items_for_sale table with the data in items_for_sale.json, in the same order as showed in the json file.

TO TEST:
- Insert DemoShop-ServerSide folder (unzipped) in Applications/XAMPP/htdocs folder.
- Open Xamp, open Manage Servers tab and click "Start All".

Credit cards for testing: https://stripe.com/docs/testing
