<?php
header("Content-Type: application/json");
echo json_encode([
    "status" => "success",
    "message" => "Pocket Khoroch BDApps API is running.",
    "version" => "1.0"
]);
?>