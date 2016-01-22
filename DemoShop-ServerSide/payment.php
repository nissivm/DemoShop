<?php
require_once('vendor/autoload.php');

// Set your secret key: remember to change this to your live secret key in production
// See your keys here https://dashboard.stripe.com/account/apikeys
\Stripe\Stripe::setApiKey("YOUR TEST SECRET KEY");

// read JSon input
$data_back = json_decode(file_get_contents('php://input'));
 
// Get the credit card details submitted by the form
$token = $data_back->{"stripeToken"};
$amount = $data_back->{"amount"};
$currency = $data_back->{"currency"};
$description = $data_back->{"description"};
$receipt_email = $data_back->{"receipt_email"};

// Create the charge on Stripe's servers - this will charge the user's card
try {
	$charge = \Stripe\Charge::create(array(
  	"amount" => $amount*100, // Convert amount in cents to dollar
  	"currency" => $currency,
  	"source" => $token,
  	"description" => $description,
	"receipt_email" => $receipt_email)
	);

	// Check that it was paid:
	if ($charge->paid == true) {

		$response = array('status'=>'Success','message'=>'Payment successfully charged!','chargeId'=>$charge['id']);

	} else { // Charge was not paid!
		$response = array('status'=>'Failure','message'=>'The payment system rejected the transaction. Please try again or use another card.');
	}

	header('Content-Type: application/json');
	echo json_encode($response);

} catch(\Stripe\Error\Card $e) {

  	// The card has been declined
	$response = array( 'status'=> 'Failure', 'message'=>'Your card has been declined. Please try again using another card.' );
	header('Content-Type: application/json');
	echo json_encode($response);
}

?>