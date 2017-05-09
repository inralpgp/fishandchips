<HTML>
<HEAD>
		<style type="text/css">

		body{
				background-color:#029350;
		}

		.fullsample {
				width: 80%;
				border-radius: 30px 30px;
				-moz-border-radius: 10px;
				background-color: #FFFFFF;
				padding: 30px ;
				float : left;
				margin-left: 1em;
				margin-right: 1em;
				font: 11px Trebuchet MS, 11px Lucida Sans Unicode, 11px Arial, 11px sans-serif;
			}

		</style>
<TITLE>Intersection list</TITLE>
<?php
  echo "
	<script language=\"Javascript\">
		function fenCentre(url,largeur,hauteur)
		{
			var Dessus=(screen.height/2)-(hauteur/2);
			var Gauche=(screen.width/2)-(largeur/2);
			var features= 'height='+hauteur+',width='+largeur+',top='+Dessus +',left='+Gauche+\",scrollbars=yes\";
			thewin=window.open(url,'',features);
		}

    function fenetreCent(url,nom,largeur,hauteur,options) {
    var haut=(screen.height-hauteur)/2;
    var Gauche=(screen.width-largeur)/2;
    fencent=window.open(url,nom,\"top=\"+haut+\",left=\"+Gauche+\",width=\"+largeur+\",height=\"+hauteur+\",\"+options);
    }
	</script>
	";
?>
</HEAD>
<div CLASS=fullsample>

<?php
include_once("fonctions.php");
$species = htmlentities($_POST['species']);
echo "<br>$species<br>";
$list = htmlentities($_POST['list']);
$gene="";
$madids=explode("|",$list);
/*
foreach($madids as $madid){

	//echo"<br>$madid<br>";

	$reqNumOrthoEns="
		SELECT `gene_id`
		FROM `orthologies_group_simple`
		WHERE `ortho_num` = '$madid'
	;";
	
	$resultNumOrthoEns = mysql_query ($reqNumOrthoEns,$connexionid);
	$result = mysql_fetch_object ($resultNumOrthoEns);
	$ensId=$result->gene_id;
*/

foreach($madids as $ensId){

	$gene .= "<a href=javascript:fenCentre('http://www.ensembl.org/Multi/Search/Results?species=all;idx=;q=$ensId',900,900)>$ensId</a>";
	
	$gogo = get_info_ensembl($ensId);
	if($gogo->gene_name)
	{
        	$gene_name = $gogo->gene_details ;
        	$symbol=$gogo->gene_name;
		$symbol=preg_replace("/ \(.*/", '', $symbol);
		
		if($symbol=="null")
		{
			$gene .= "<br>";
			continue;
		}
		
		$gene .= "&nbsp;&nbsp;&nbsp; <a href=javascript:fenCentre('http://www.ncbi.nlm.nih.gov/sites/entrez?db=gene&cmd=search&term=$symbol%5Bgene%2Fprotein+name%5D',900,900)>$symbol</a> &nbsp;&nbsp;&nbsp; $gene_name<br>" ;
	}
	else
	{
		$gene .= "<br>";
	}
}



echo "<br>$gene<br><br>" ;

echo "<center><A HREF=\"javascript:window.close()\"><b> close </b></A></center>";

?>

</div>
</body>
</HTML>
