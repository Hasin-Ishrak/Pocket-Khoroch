<?php
define('BDAPPS_APP_ID', 'APP_137539');
define('BDAPPS_PASSWORD', 'c2dd7d7ab475be8a6175f3f318856541');

function cors_headers() {
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");
    header('Content-Type: application/json; charset=utf-8');
    if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

function normalize_bd_mobile($rawMobile) {
    $digits = preg_replace('/\D+/', '', $rawMobile);
    if (strpos($digits, '880') === 0 && strlen($digits) === 13) {
        $digits = '0' . substr($digits, 3);
    } elseif (strpos($digits, '88') === 0 && strlen($digits) === 12) {
        $digits = '0' . substr($digits, 2);
    }
    if (!preg_match('/^01[3-9][0-9]{8}$/', $digits)) {
        return null;
    }
    return $digits;
}
?>