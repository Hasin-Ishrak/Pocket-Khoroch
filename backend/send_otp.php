<?php
require_once 'config.php';
cors_headers();

$rawMobile = $_POST['user_mobile'] ?? '';
$digits = normalize_bd_mobile($rawMobile);

if ($digits === null) {
    echo json_encode(['success' => false, 'message' => 'Invalid mobile number format', 'referenceNo' => null]);
    exit;
}

$user_mobile = 'tel:88' . $digits;

$requestData = [
    'applicationId' => BDAPPS_APP_ID,
    'password' => BDAPPS_PASSWORD,
    'subscriberId' => $user_mobile,
    'applicationHash' => 'App Name',
    'applicationMetaData' => [
        'client' => 'MOBILEAPP',
        'device' => 'Web/Android',
        'os' => 'flutter',
        'appCode' => 'com.yourname.pocketkhoroch'
    ]
];

$requestJson = json_encode($requestData);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'https://developer.bdapps.com/subscription/otp/request');
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, $requestJson);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json', 'Content-Length: ' . strlen($requestJson)]);

$responseJson = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

file_put_contents('logs/otp_request.txt', date('Y-m-d H:i:s') . " | $requestJson | HTTP $httpCode | $responseJson\n", FILE_APPEND);

$response = json_decode($responseJson, true);
if (!is_array($response)) {
    echo json_encode(['success' => false, 'message' => 'Invalid response from BDApps', 'referenceNo' => null]);
    exit;
}

$referenceNo = trim((string)($response['referenceNo'] ?? ''));

if ($referenceNo !== '') {
    echo json_encode([
        'success' => true,
        'referenceNo' => $referenceNo,
        'subscriberId' => $user_mobile
    ]);
} else {
    echo json_encode([
        'success' => false,
        'message' => $response['statusDetail'] ?? 'OTP reference not returned',
        'referenceNo' => null
    ]);
}
?>