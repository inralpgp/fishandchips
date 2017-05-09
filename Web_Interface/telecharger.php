<?php
if ((isset($_GET['chemin']))or(isset($_GET['fichier']))) {
 if (substr_count($_GET['fichier'],"/")>0) die();
 if (substr_count($_GET['fichier'],"\\")>0) die(); 
 if (substr_count($_GET['fichier'],"..")>0) die();
}
//require_once("connection.php");
$chemin =htmlentities($_GET['chemin']);
$fichier = htmlentities($_GET['fichier']);

switch(strrchr(basename($fichier), ".")) {
 case ".gz": $type = "application/x-gzip";  break;
 case ".tgz": $type = "application/x-gzip"; break;
 case ".zip": $type = "application/zip"; break;
 case ".pdf": $type = "application/pdf"; break;
 case ".png": $type = "image/png"; break;
 case ".gif": $type = "image/gif"; break;
 case ".jpg": $type = "image/jpeg"; break;
 case ".txt": $type = "text/plain"; break;
 case ".htm": $type = "text/html"; break;
 case ".html": $type = "text/html"; break;
 default: $type = "application/octet-stream"; break;}
header("Content-disposition: attachment; filename=$fichier");
header("Content-Type: application/image/jpeg");
header("Content-Transfer-Encoding: $type\n");
header("Content-Length: ".filesize($chemin.$fichier));
header("Pragma: no-cache");
header("Cache-Control: must-revalidate, post-check=0, pre-check=0, public");
header("Expires: 0");
readfile($chemin.$fichier);
?>
