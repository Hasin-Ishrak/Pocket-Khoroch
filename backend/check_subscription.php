<?php
require_once 'config.php';
cors_headers();

$rawMobile = $_POST['user_mobile'] ?? $_GET['user_mobile'] ?? '';
$digits = normalize_bd_mobile($rawMobile);

if ($digits === null) {
    echo json_encode(['success' => false, 'message' => 'Invalid mobile number format']);
    exit;
}

$subscriberId = 'tel:88' . $digits;

$requestData = [
    'version' => '1.0',
    'applicationId' => BDAPPS_APP_ID,
    'password' => BDAPPS_PASSWORD,
    'subscriberId' => $subscriberId,
];
$requestJson = json_encode($requestData);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://developer.bdapps.com/subscription/getStatus');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $requestJson);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json', 'Content-Length: ' . strlen($requestJson)]);

$responseJson = curl_exec($ch);
curl_close($ch);

$response = json_decode($responseJson, true);
$status = strtoupper(trim($response['subscriptionStatus'] ?? ''));
$isSubscribed = ($status === 'REGISTERED');

echo json_encode([
    'success' => true,
    'subscriptionStatus' => $status,
    'isSubscribed' => $isSubscribed,
    'subscriberId' => $subscriberId
]);
?>