<?php
//ini_set('display_errors', 1);

require_once("fonctions.php");
require_once("connection.php");
 
$id=htmlentities($_GET['id']);
$cluster_id=htmlentities($_GET['cluster']);
$targetType=htmlentities($_POST['ids_type']);

//echo"<br>$id   $cluster_id   $targetType<br>";

$requete_species = "
SELECT GSE, GPL, species
FROM datasets, array_design
WHERE id = '$id'
AND datasets.GPL = array_design.array_id
GROUP BY GSE
;";
$resultat_species = mysql_query ($requete_species,$connexionid);
$res_species = mysql_fetch_object ($resultat_species) ;

$requeteId ="
SELECT gb_acc
FROM gene_selection
WHERE id = '$id'
AND cluster_id = '$cluster_id'
;";
$resId = mysql_query ($requeteId,$connexionid);



$geneListFile = "Gene_List_".$res_species->GSE."-".$res_species->GPL."_cluster".$cluster_id."_".$targetType.".txt";
$file_opened=fopen("./files/".$geneListFile,"w");

while ($gbAcc = mysql_fetch_object ($resId))
{
	if($targetType=="GenBank-Id")
	{
		
		if(preg_match('/\w/', $gbAcc->gb_acc))
		{
			//echo"<br>$gbAcc->gb_acc";
			fputs($file_opened, $gbAcc->gb_acc."\n") ;
		}
	}
	else
	{
		$species =  $res_species->species ;
		
		$info_humain = info_gene_list($gbAcc->gb_acc, $species);
		
		if($targetType=="Ensembl-Id")
		{
			if(preg_match('/\w/', $info_humain->Annotation_gene_id))
			{
				//echo"<br>$info_humain->Annotation_gene_id";
				fputs($file_opened, "$info_humain->Annotation_gene_id\n") ;
			}
		}
		else
		{
			$symbol=$info_humain->Annotation_gene_symbol;
			if(preg_match('/\w/', $symbol))
			{
				$symbol=preg_replace("/ \(.*/", '', $symbol);
				//echo"<br>$symbol";
				fputs($file_opened, "$symbol\n") ;
			}
		}
	}
}
fclose($file_opened);

$fichier_taille = filesize("./files/".$geneListFile);
header("Content-disposition: attachment; filename=$geneListFile"); 
header("Content-Type: application/force-download"); 
header("Content-Transfer-Encoding: application/octet-stream"); 
header("Content-Length: $fichier_taille"); 
header("Pragma: no-cache"); 
header("Cache-Control: must-revalidate, post-check=0, pre-check=0, public"); 
header("Expires: 0"); 
readfile("./files/".$geneListFile);

?>

