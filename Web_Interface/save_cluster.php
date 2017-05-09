<?php
require_once("fonctions.php");

$id = htmlentities($_GET['id']);
$cluster = htmlentities($_GET['cluster']);

$file = createXmlResultCluster($id,$cluster);

$fichier_taille = filesize("./files/".$file);

header("Content-disposition: attachment; filename=$file"); 
header("Content-Type: application/force-download"); 
header("Content-Transfer-Encoding: application/octet-stream"); 
header("Content-Length: $fichier_taille"); 
header("Pragma: no-cache"); 
header("Cache-Control: must-revalidate, post-check=0, pre-check=0, public"); 
header("Expires: 0"); 
readfile("./files/".$file);

?>
