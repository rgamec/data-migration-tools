<?php
echo "<pre>";
echo "Starting tool...\n";

if (!isset($_GET['id'])){
    $get_id = 100;
} else {
    $get_id = $_GET['id'];
}


#### CONFIGURATION #########################################

# Details of existing Kusaba database to transfer posts from
$kusaba_con_server = "";
$kusaba_con_database = "";
$kusaba_con_username = "";
$kusaba_con_password = "";

# Details of Tinyboard database to transfer posts to
$tinyboard_con_server = "";
$tinyboard_con_database = "";
$tinyboard_con_username = "";
$tinyboard_con_password = "";

############################################################


$kusaba_con = mysqli_connect($kusaba_con_server, $kusaba_con_database, $kusaba_con_username, $kusaba_con_password);
if (mysqli_connect_errno($kusaba_con)){
    echo "Unable to connect to Kusaba's database. Exiting.\n";
    die("Error.");
}

$tinyboard_con = mysqli_connect($tinyboard_con_server, $tinyboard_con_database, $tinyboard_con_username, $tinyboard_con_password);
if (mysqli_connect_errno($tinyboard_con)){
    echo "Unable to connect to Tinyboard's database. Exiting.\n";
    die("Error.");
}

// Now show some stats for Kusaba
$result = $kusaba_con->query("SELECT COUNT(*) FROM `posts`");
$row = $result->fetch_row();
echo 'Number of posts in Kusaba : '. $row[0] . "\n\n";

// From https://github.com/tslocum/kusaba/blob/master/trunk/inc/func/encryption.php
function md5_decrypt($enc_text, $password, $iv_len = 16) {
    $enc_text = base64_decode($enc_text);
    $n = strlen($enc_text);
    $i = $iv_len;
    $plain_text = '';
    $iv = substr($password ^ substr($enc_text, 0, $iv_len), 0, 512);
    while ($i < $n) {
        $block = substr($enc_text, $i, 16);
        $plain_text .= $block ^ pack('H*', md5($iv));
        $iv = substr($block . $iv, 0, 512) ^ $password;
        $i += 16;
    }
    return preg_replace('/\\x13\\x00*$/', '', $plain_text);
}

$query = "SELECT `id`, `boardid`, `parentid`, `name`, `tripcode`, `email`, `subject`, 
`message`, `password`, `file`, `file_md5`, `file_type`, `file_original`, `file_size`, 
`file_size_formatted`, `image_w`, `image_h`, `thumb_w`, `thumb_h`, `ip`, `ipmd5`, `tag`, 
`timestamp`, `stickied`, `locked`, `posterauthority`, `reviewed`, `deleted_timestamp`, `IS_DELETED`, `bumped` FROM `g82jsposts` WHERE `boardid`=2 AND `id`=$get_id";
if ($result = mysqli_query($kusaba_con, $query)) {
echo "Query was successful\n";
    /* fetch associative array */
    while ($kusaba = mysqli_fetch_assoc($result)) {
        echo "\nid: " . $kusaba["id"] . "\n";
        echo "boardid: " . $kusaba["boardid"] . "\n";
        echo "parentid: " . $kusaba["parentid"] . "\n";
        echo "name: " . $kusaba["name"] . "\n";
        echo "tripcode: " . $kusaba["tripcode"] . "\n";
        echo "email: " . $kusaba["email"] . "\n";
        echo "subject: " . $kusaba["subject"] . "\n";
        echo "message: " . $kusaba["message"] . "\n";  
        echo "password: " . $kusaba["password"] . "\n";
        echo "file: " . $kusaba["file"] . "\n";
        echo "file_type: " . $kusaba["file_type"] . "\n";
        echo "file_original: " . $kusaba["file_original"] . "\n";
        echo "file_size: " . $kusaba["file_size"] . "\n";
        echo "file_size_formatted: " . $kusaba["file_size_formatted"] . "\n";
        echo "image_w: " . $kusaba["image_w"] . "\n";
        echo "image_h: " . $kusaba["image_h"] . "\n";
        echo "thumb_w: " . $kusaba["thumb_w"] . "\n";
        echo "thumb_h: " . $kusaba["thumb_h"] . "\n";
        echo "ip: " . $kusaba["ip"] . "\n";
        echo "ipmd5: " . $kusaba["ipmd5"] . "\n";
        echo "tag: " . $kusaba["tag"] . "\n";
        echo "timestamp: " . $kusaba["timestamp"] . "\n";
        echo "stickied: " . $kusaba["stickied"] . "\n";
        echo "locked: " . $kusaba["locked"] . "\n";
        echo "posterauthority: " . $kusaba["posterauthority"] . "\n";
        echo "reviewed: " . $kusaba["reviewed"] . "\n";
        echo "deleted_timestamp: " . $kusaba["deleted_timestamp"] . "\n";
        echo "IS_DELETED: " . $kusaba["IS_DELETED"] . "\n";
        echo "bumped: " . $kusaba["bumped"] . "\n\n";


        $tinyboard_id = $kusaba['id'];

        if ($kusaba['parentid'] == "0"){
            $tinyboard_thread = "";
        } else {
            $tinyboard_thread = $kusaba['parentid'];
        }

        if (strlen($kusaba["subject"]) > 100){
            $tinyboard_subject = substr($kusaba["subject"],0,100);
        } else {
            $tinyboard_subject = $kusaba["subject"];
        }

        // Name field in Tinyboard limited to 35 chars
        if (strlen($kusaba["name"]) > 35){
            $tinyboard_name = substr($kusaba["name"],0,35);
        } else {
            $tinyboard_name = $kusaba["name"];
        }

        $tinyboard_email = $kusaba['id']; 
        $tinyboard_trip = $kusaba['id'];
        $tinyboard_capcode = $kusaba['id'];
        $tinyboard_body = $kusaba['id'];
        $tinyboard_body_nomarkup = $kusaba['id'];
        $tinyboard_time = $kusaba['timestamp'];
        $tinyboard_bump = $kusaba['bumped'];
        $tinyboard_thumb = $kusaba['file'] . "s.jpg";
        $tinyboard_thumbwidth = $kusaba["thumb_w"];
        $tinyboard_thumbheight = $kusaba["thumb_h"];
        $tinyboard_file = $kusaba['id'];
        $tinyboard_filewidth = $kusaba['image_w'];
        $tinyboard_fileheight = $kusaba['image_h'];
        $tinyboard_filesize = $kusaba['id'];
        $tinyboard_filename = $kusaba['file_original'] . "." . $kusaba['file_type'];
        $tinyboard_filehash = $kusaba['id'];
        $tinyboard_password = $kusaba['id'];
        $tinyboard_ip = md5_decrypt($kusaba['ip'],"ywzwqcrlednu6f0tt6xbbwmeulevjq880zuyiv5w");
        $tinyboard_sticky = $kusaba['stickied'];
        $tinyboard_locked = $kusaba['locked'];
        $tinyboard_sage = $kusaba['id'];
        $tinyboard_embed = $kusaba['id'];

        // Now add this post into TinyBoard's database
        $query = "INSERT INTO `posts` (`id`, `thread`, `subject`, `email`, `name`, `trip`, `capcode`, 
         `body`, `body_nomarkup`, `time`, `bump`, `thumb`, `thumbwidth`, `thumbheight`, `file`, `filewidth`, 
         `fileheight`, `filesize`, `filename`, `filehash`, `password`, `ip`, `sticky`, `locked`, `sage`, `embed`) 
            VALUES
            (`$tinyboard_id`, `$tinyboard_thread`, `$tinyboard_subject`, `$tinyboard_email`, `$tinyboard_name`, 
                `$tinyboard_trip`, `$tinyboard_capcode`, `$tinyboard_body`, `$tinyboard_body_nomarkup`, `$tinyboard_time`, `$tinyboard_bump`, `$tinyboard_thumb`, 
        `$tinyboard_thumbwidth`, `$tinyboard_thumbheight`, `$tinyboard_file`, `$tinyboard_filewidth`, `$tinyboard_fileheight`, 
        `$tinyboard_filesize`, `$tinyboard_filename`, `$tinyboard_filehash`, `$tinyboard_password`, 
        `$tinyboard_ip`, `$tinyboard_sticky`, `$tinyboard_locked`, `$tinyboard_sage`, `$tinyboard_embed`)";

        echo "\n$query\n";
    }

    /* free result set */
    mysqli_free_result($result);
}

