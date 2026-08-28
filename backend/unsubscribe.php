<?php
require_once 'config.php';
cors_headers();

$rawMobile = $_POST['user_mobile'] ?? '';
$digits = normalize_bd_mobile($rawMobile);

if ($digits === null) {
    echo json_encode(['success' => false, 'message' => 'Invalid mobile number format']);
    exit;
}

$subscriberId = 'tel:88' . $digits;

$requestData = [
    'applicationId' => BDAPPS_APP_ID,
    'password' => BDAPPS_PASSWORD,
    'subscriberId' => $subscriberId,
    'version' => '1.0',
    'action' => '0',
];
$requestJson = json_encode($requestData);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://developer.bdapps.com/subscription/send');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $requestJson);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json', 'Content-Length: ' . strlen($requestJson)]);

$responseJson = curl_exec($ch);
curl_close($ch);

$response = json_decode($responseJson, true);
$statusCode = strtoupper((string)($response['statusCode'] ?? ''));
$success = ($statusCode === 'S1000');

echo json_encode([
    'success' => $success,
    'statusCode' => $statusCode,
    'statusDetail' => $response['statusDetail'] ?? ''
]);
?>