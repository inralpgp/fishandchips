<HTML>
<HEAD>
		<style type="text/css">

		body{
				background-color:#029350;
		}

		.fullsample {
				width: 80%;
				border-radius: 110px 110px;
				-moz-border-radius: 60px;
				background-color: #FFFFFF;
				padding: 75px ;
				float : center;
				margin-left: 1em;
				margin-right: 1em;
				font: 13px Trebuchet MS, Lucida Sans Unicode, Arial, sans-serif;
			}

		</style>
<TITLE>GO statistics</TITLE>
</HEAD>
<div CLASS=fullsample>
<?php
require_once("fonctions.php");
fenetre_java();
$name= htmlentities($_GET['name']);
$cluster_id = htmlentities($_GET['cluster_id']);

$set=preg_replace('/(-A-.+)|(-GPL.+)/', '',$name);

$link = "$data/$set/$name/cluster/annotation/formated_result/cluster$cluster_id.txt";

$fh = fopen("$link", 'r') or die($php_errormsg);
//echo "$link<br>";
echo "<center><A HREF=\"javascript:window.close()\"><b> close </b></A></center><br><br>";
echo "<center><table border width=70%>\n";
$j = 0 ;
while (!feof($fh))
{
  $ligne = fgets($fh, 4096);
  
  unset($tab);
  $tab = explode ("\t", $ligne);
if($j > "2000") { break ; }
echo "<tr>\n";
  if($j>0)
  {
    echo "<td><a href=javascript:fenCentre(\"http://www.ebi.ac.uk/QuickGO/GTerm?id=GO:$tab[0]\",900,900)>$tab[0]</a></td>";
  }
  else
  {
    echo "<td>$tab[0]</td>";
  }
  for($i=1;$i<count($tab);$i++)
  {
    $case=$tab[$i];
    echo "<td>$case</td>";
  }

  echo "\n</tr>\n";
  $j++;
}
echo "</table></center><br><br>\n";
fclose($fh);

echo "<center><A HREF=\"javascript:window.close()\"><b> close </b></A></center>";

?>
</div>
</body>
</HTML>
