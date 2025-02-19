<?php
header("Content-Type: application/json");
include 'config/dbconfig.php';

// Handle the request method
$method = $_SERVER['REQUEST_METHOD'];

if ($method !== 'GET') {
    echo json_encode(["status" => "error", "message" => "Invalid request method. Use GET."]);
    exit;
}

// Check the database connection
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
} else {
    echo json_encode(["status" => "success", "message" => "Database connected successfully"]);
}

// Close the database connection
$conn->close();
?>
