<?php
require_once 'config.php';
cors_headers();

$user_otp = trim($_POST['otp'] ?? '');
$referenceNo = trim($_POST['referenceNo'] ?? '');

if (empty($user_otp) || empty($referenceNo)) {
    echo json_encode(['success' => false, 'message' => 'Missing OTP or referenceNo']);
    exit;
}

$requestData = [
    'applicationId' => BDAPPS_APP_ID,
    'password' => BDAPPS_PASSWORD,
    'referenceNo' => $referenceNo,
    'otp' => $user_otp
];
$requestJson = json_encode($requestData);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://developer.bdapps.com/subscription/otp/verify');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $requestJson);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 15);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json', 'Content-Length: ' . strlen($requestJson)]);

$responseJson = curl_exec($ch);
curl_close($ch);

file_put_contents('logs/otp_verify.txt', date('Y-m-d H:i:s') . " | OTP:$user_otp Ref:$referenceNo | $responseJson\n", FILE_APPEND);

$response = json_decode($responseJson, true);
$statusCode = strtoupper((string)($response['statusCode'] ?? ''));

// S1000 = success per BDApps convention
$success = ($statusCode === 'S1000');

echo json_encode([
    'success' => $success,
    'statusCode' => $statusCode,
    'statusDetail' => $response['statusDetail'] ?? '',
    'subscriptionStatus' => $response['subscriptionStatus'] ?? ''
]);
?>