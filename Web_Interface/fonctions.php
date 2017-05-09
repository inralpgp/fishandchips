<?php
//////////////////////////////////////////////////////////////////////////////////////////
//Fonction permattant de faire un tableau des datasets disponible dans la base madmuscle//
//////////////////////////////////////////////////////////////////////////////////////////
require_once("connection.php");
//require_once("config.php");
ini_set('memory_limit', '700M');
ini_set('max_execution_time', 600);
ini_set("auto_detect_line_endings", true);



function listing ()
{
  global $connexionid;

//   $requete1 ="
//   SELECT madmuscle.datasets.id, madmuscle.datasets.directory, madmuscle.datasets.title, madmuscle.datasets.quality_estimate, madmuscle.datasets.quality_auto,
// 	IF(madmuscle.datasets.quality_auto IS NULL , 1, 0)
// 	AS isnull
//   FROM madmuscle.datasets
// ORDER BY isnull ASC, madmuscle.datasets.quality_auto ASC
//   ;";

  $requete1 ="
  SELECT fishAndchips.datasets.id, fishAndchips.datasets.directory, fishAndchips.datasets.GPL, fishAndchips.datasets.title, fishAndchips.datasets.quality_estimate, fishAndchips.datasets.quality_auto
  FROM fishAndchips.datasets
ORDER BY quality_estimate DESC, quality_auto ASC ;
";
//   $requete1 ="
//   SELECT fishAndchips.datasets_RNAseq.id, fishAndchips.datasets_RNAseq.directory, fishAndchips.datasets_RNAseq.title, fishAndchips.datasets_RNAseq.quality_estimate, fishAndchips.datasets_RNAseq.quality_auto
//   FROM fishAndchips.datasets_RNAseq
// ORDER BY quality_estimate DESC, quality_auto ASC ;
// ";
//ORDER BY fish_chips.datasets.quality_estimate DESC
  $resultat1 = mysqli_query ($connexionid,$requete1);

  $nb_resultat1 = mysqli_num_rows($resultat1);
  $compt = 0 ;

  if($nb_resultat1>0)
  {?>
    <table>
    <tr>
		<th id="DSid">Name</td>
		<th >Title</td>
		<th id="quality">Quality <a href=javascript:fenCentre("helpfile1.html",300,400)>Help</a></td>
	</tr>
    <?php 
    while ($ligne = mysqli_fetch_object ($resultat1))
    {
         $compt++ ;
        echo "
        <tr><td><a href=./view.php?id=$ligne->id>$ligne->directory";
      	if ( !(preg_match("/GPL/", $ligne->directory)) && (preg_match("/GSE/", $ligne->directory)) )
      	{
      		echo "-$ligne->GPL";
      	}
      	echo "</a></td><td>$ligne->title</td>";
      	
      	$lulu_quality = $ligne->quality_auto  ;
      	
      	/*
      	if($lulu_quality)
      	{
      		if($lulu_quality < 0.01)
      		{
      			echo "<td><center><img src=./code_quality/Image4.png></center>";
      		}
      		elseif($lulu_quality < 0.05)
      		{
      			echo "<td><center><img src=./code_quality/Image3.png></center>";
      		}
      		elseif($lulu_quality < 0.1)
      		{
      			echo "<td><center><img src=./code_quality/Image2.png></center>";
      		}
      		elseif($lulu_quality < 1)
      		{
      			echo "<td><center><img src=./code_quality/Image1.png></center>";
      		}
      		else
      		{
      			echo "<td><center><img src=./code_quality/Image0.png></center>";
      		}
      		echo sprintf("%.3e",$lulu_quality);
      		echo "</td></tr>";
      	}
      	else
      	{
      		echo "<td><center>?</center></td></tr>";
      	}
      	*/


        if($ligne->quality_estimate != "")
        {
    			$lulu_quality = $ligne->quality_auto  ;
          #echo "<td><center><img src=./images/code_quality/Image$ligne->quality_auto.png></center>";
          echo "<td><center><img src=./images/code_quality/Image$ligne->quality_estimate.png></center>";
    			if ($lulu_quality) {echo sprintf("%.3e",$lulu_quality);}
    			echo "</td></tr>";
        }
        else
        {
          echo "<td><center>?</center></td></tr>";
        }


    }
  }
     echo"$compt datasets: <br>";
     echo "
     </table>
     ";
}

function info_datasets ($id)
{
  global $connexionid;

  $requete2 ="
  SELECT fishAndchips.datasets.*
  FROM fishAndchips.datasets
  WHERE fishAndchips.datasets.id = '$id'
  ;";
  
  $resultat2 = mysqli_query ($connexionid,$requete2);

  $nb_resultat2 = mysqli_num_rows($resultat2);

  $info = mysqli_fetch_object ($resultat2);
  
  if($nb_resultat2>0)
  {
    return $info;
  }
}


function get_dataset_id($GSE){
  global $connexionid;

  $requete2 ="
  SELECT fishAndchips.datasets.id
  FROM fishAndchips.datasets
  WHERE fishAndchips.datasets.directory = '$GSE'
  ;";
  
  $resultat2 = mysqli_query ($connexionid,$requete2);
  $nb_resultat2 = mysqli_num_rows($resultat2);
  $info = mysqli_fetch_object ($resultat2);
  
  if($nb_resultat2>0)
  {
    return $info->id;
  }	
}
//////////////////////////
//affichage fen�tre aide//
//////////////////////////
function fenetre_java ()
{
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
}
////////////////////////
//affiche des clusters//
////////////////////////
function cluster ($id,$name)
{
  global $connexionid;
	global $data ;


  $set=preg_replace('/(-A-.+)|(-GPL.+)/', '',$name);


  //echo"<br><strong><i>$set</i></strong><br><br>";


  $requete_clusters ="
  SELECT DISTINCT fishAndchips.quality_cluster_new.cluster_id
  FROM fishAndchips.quality_cluster_new
  WHERE fishAndchips.quality_cluster_new.id = '$id'
  ;";

  $resultat_clusters = mysqli_query ($connexionid,$requete_clusters);

  $nb_resultat_clusters = mysqli_num_rows($resultat_clusters);

  if($nb_resultat_clusters>0)
  {
   	while ($ligne_clusters = mysqli_fetch_object ($resultat_clusters)){
   	
   	
   	$probeReq="SELECT COUNT(`gene`) AS probeNb FROM `gene_selection` WHERE id='$id' AND cluster_id='$ligne_clusters->cluster_id';";
   	$probeRes = mysqli_query ($connexionid,$probeReq);
   	$probeNb = mysqli_fetch_object ($probeRes);
   	
   	
      	echo "<p class=\"p2\"><a href='view.php?id=$id'><i>Back</i></a></p>
		<h3><u><a NAME=\"$ligne_clusters->cluster_id\"> cluster $ligne_clusters->cluster_id</a></u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;($probeNb->probeNb probes)</h3>";
		$resultat_annotation = annotation($id,$ligne_clusters->cluster_id);
	
		if ($resultat_annotation != "")
		{
			echo "
			<h2>Annotation:</h2>
			<table border=1>
			<tr>
			<td>GO ID</td>
			<td>GO term</td>
			<td>Number in array</td>
			<td>Number in cluster</td>
			<td>Enrichment</td>
			<td>p-value</td>
			</tr>";
		
			while($info_annotation = mysqli_fetch_object ($resultat_annotation))
			{
				echo "<tr>
				<td>$info_annotation->GO_ID</td>
				<td>$info_annotation->GO_term</td>
				<td>$info_annotation->number_puce</td>
				<td>$info_annotation->number_cluster</td>
				<td>".round($info_annotation->R,3)."</td>
				<td>$info_annotation->p_value</td>
				</tr>";
			}
			echo "</table><br>
			";
			/////parsage du fichier de gominer pour affichage
			if (is_file("$data/$set/$name/cluster/annotation/formated_result/cluster$ligne_clusters->cluster_id.txt"))
			{
		
				echo "
				<form action=javascript:fenCentre(\"GO_stat.php?name=$name&cluster_id=$ligne_clusters->cluster_id\",900,900) method=post>
				<input type=submit value='more GO Stats' >
				
				";
					echo "&nbsp;&nbsp;&nbsp;<a href=\"telecharger.php?fichier=cluster$ligne_clusters->cluster_id.txt&chemin=$data/$set/$name/cluster/annotation/formated_result/\">download complete GO Stats</a></form>" ;
		
			}
      	}

		//annotation manuelle de daniel (code à revoir)
      if (is_file("$data/$set/$name/cluster/cluster$ligne_clusters->cluster_id.htm"))
      {
        ?>

		<form method="post" onSubmit="javascript:fenCentre('<?php echo $data.$set.$name; ?>/annotation/cluster<?php echo "$ligne_clusters->cluster_id"; ?>.htm',1200,800)">
		
        <input type=submit value='GO statistical annotation (EASE)'>
        </form>
        <?php 
      }

      if (is_file("$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.txt"))
        {
          echo"
          <H4>Data file (.txt) <FONT SIZE=2><a href=$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.txt>(view)</a>  /
          <a href=telecharger.php?fichier=cluster_$ligne_clusters->cluster_id.txt&chemin=$data/$set/$name/cluster/>(download)</a></FONT></H4>
          ";
        }
      if (is_file("$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.cdt"))
        {














          echo"
          <H4>Data treeview file (.cdt) <FONT SIZE=2><a href=$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.cdt>(view)</a>  /
          <a href=telecharger.php?fichier=cluster_$ligne_clusters->cluster_id.cdt&chemin=$data/$set/$name/cluster/>(download)</a></FONT></H4>
          ";
        }
      if (is_file("$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.atr"))
        {
          echo"
          <H4>Array treeview file (.atr) <FONT SIZE=2><a href=$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.atr>(view)</a>  /
          <a href=telecharger.php?fichier=cluster_$ligne_clusters->cluster_id.atr&chemin=$data/$set/$name/cluster/>(download)</a></FONT></H4>
          ";
        }
      if (is_file("$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.gtr"))
        {
          echo"
          <H4>Gene treeview file (.gtr) <FONT SIZE=2><a href=$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.gtr>(view)</a>  /
          <a href=telecharger.php?fichier=cluster_$ligne_clusters->cluster_id.gtr&chemin=$data/$set/$name/cluster/>(download)</a></FONT></H4>
          ";
        }
     /*
      if (is_file("$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.png"))
      {
        echo"<img src=$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.png>";
        echo"<a href=telecharger.php?fichier=cluster_$ligne_clusters->cluster_id.png&chemin=$data/$set/$name/cluster/>Download picture</a>";
      }
     */
      if (is_file("$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.fix.png") || is_file("$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.png"))
      {
        echo"<img src=$data/$set/$name/cluster/cluster_$ligne_clusters->cluster_id.fix.png>";
        echo"<br><center><a href=telecharger.php?fichier=cluster_$ligne_clusters->cluster_id.fix.png&chemin=$data/$set/$name/cluster/>Download picture</a></center><br>";
      }

      echo "
      <form action=gene_list.php?id=$id method=post>
      <input type=hidden name=cluster_id value=$ligne_clusters->cluster_id >
      <input type=hidden name=name VALUE=$name >
      <input type=submit value='View gene list' >
      </form>
      ";
      

		//QUALITY AUTO
  // 		$result_quality = quality_auto($id,$ligne_clusters->cluster_id);
  // 		if($result_quality)
  // 		{
  // 			$result_quality = $result_quality * 100 ;
  // 			echo "<center><b>Quality: $result_quality%</b></center><br>";
  // 		}

		$result_quality_new = quality_auto_new($id,$ligne_clusters->cluster_id);
		if($result_quality_new)
		{
			if($result_quality_new < "0.001") 
			{ echo "<center><h2>VERY GOOD CLUSTER <IMG SRC=./images/quality4.png><h2></center>"; }
			elseif($result_quality_new < "0.01")
			{ echo "<center><h2>GOOD CLUSTER <IMG SRC=./images/quality3.png><h2></center>"; }
			elseif($result_quality_new < "0.05")
			{ echo "<center><h2>CORRECT CLUSTER <IMG SRC=./images/quality2.png><h2></center>"; }
			elseif($result_quality_new < "0.2")
			{ echo "<center><h2>BAD CLUSTER <IMG SRC=./images/quality1.png><h2></center>"; }
			elseif($result_quality_new > "0.2")
			{ echo "<center><h2>NOISY CLUSTER <IMG SRC=./images/quality0.png><h2></center>"; }

			echo "<br><center><b>p-value quality: $result_quality_new</b></center>";
			echo "<center><a href=telecharger.php?fichier=cluster_$ligne_clusters->cluster_id.R.log&chemin=$data/$set/$name/cluster/>download quality output file</a></center>";
		}

		echo "<br><br><hr>";
    }?>
	<p class="p2"><a href='view.php?id=<?php echo "$id"; ?>'><i>Back</i></a></p><?php 
  }
  else
  {
    echo "no selected cluster<br><br><br><br><br><br><br><br><br><br><br><br>";?>
	<p class="p2"><a href='view.php?id=<?php echo"$id"; ?>'><i>Back</i></a></p>
	<p class="blanc"></p>
	<p class="blanc"></p>
	<p class="blanc"></p>
	<?php 	
  }
}
//////////////////////////////////
//affiche les g�nes d'un cluster//
//////////////////////////////////
function gene_list($id,$cluster_id)
{
  global $connexionid ;

  $requete_madid ="
  SELECT fishAndchips.gene_selection.gb_acc, fishAndchips.gene_selection.gene
  FROM fishAndchips.gene_selection
  WHERE fishAndchips.gene_selection.id = '$id'
  AND fishAndchips.gene_selection.cluster_id = '$cluster_id'
  ;";

  //ESPECE
	/*
  $requete_species = "
  SELECT fish_chips.datasets.species_GPL
  FROM fish_chips.datasets
  WHERE fish_chips.datasets.id = '$id'
  ;";
	*/

	// PEUT ETRE A REVOIR
	/*$requete_species = "
  SELECT fish_chips.datasets.sample_species
  FROM fish_chips.datasets
  WHERE fish_chips.datasets.id = '$id'
  ;";
  */
	$requete_species = "
	SELECT `array_design`.`species`
	FROM `array_design` , `datasets`
	WHERE `array_design`.`array_id` = `datasets`.`GPL`
	AND `datasets`.`id` = '$id'
	GROUP BY `array_design`.`species`
	;";


  $resultat_species = mysqli_query ($connexionid,$requete_species);
  $nb_resultat_species = mysqli_num_rows($resultat_species);

  if($nb_resultat_species>0)
  {
    $res_species = mysqli_fetch_object ($resultat_species) ;
    $species =  $res_species->species ;
    //echo "<br>$species<br>";
  }

  //FIN ESPECE

  $resultat_madid = mysqli_query ($connexionid,$requete_madid);

  $nb_resultat_madid = mysqli_num_rows($resultat_madid);

  if($nb_resultat_madid>0)
  {
      echo "
      <table Bordercolor=#FFFFFF class=\"texte_general\">
      <tr><td>GPL ID</td><td>GenBank</td><td>Ensembl ID&nbsp;(Blast result)</td><td>Symbol</td><td>Name</td>
      </tr>
      ";
      
      while ($ligne666 = mysqli_fetch_object ($resultat_madid))
      {
        //$info_humain = info_madid_humain($ligne666->gb_acc, $species);
        $info_humain = info_gene_list($ligne666->gb_acc, $species);
        
        $symbol=$info_humain->Annotation_gene_symbol;
        
  	if (preg_match("/Danio/", $species) )
  	{
  		/*
  		$requete_gene_name_danio="
  		SELECT DISTINCT(gene_details)
  		FROM cDNA
  		WHERE species = 'Danio rerio'
  		AND gene_name = '$symbol'
  		;";
  	
        	$resultat_gene_name_danio = mysql_query ($requete_gene_name_danio,$connexionid);
        	$res_gene_name_danio = mysql_fetch_object ($resultat_gene_name_danio);
        	$gene_name = $res_gene_name_danio->gene_details ;
        	*/
        	$gene_name = $info_humain->gene_details ;
        }
        else
        {
        	$gene_name = $info_humain->Annotation_gene_name ;
        }
        
	$symbol=preg_replace("/ \(.*/", '', $symbol);


        echo"
        <tr>
        <td>$ligne666->gene&nbsp;</td>
        <td><a href='http://www.ncbi.nlm.nih.gov/nucest/$ligne666->gb_acc' target='_blank'>$ligne666->gb_acc</a>&nbsp;</td>
	<td><a href='http://www.ensembl.org/Multi/Search/Results?species=all;idx=;q=$info_humain->Annotation_gene_id' target='_blank'>$info_humain->Annotation_gene_id</a>&nbsp;</td>
        <td><a href='http://www.ncbi.nlm.nih.gov/sites/entrez?db=gene&cmd=search&term=$symbol%5Bgene%2Fprotein+name%5D' target='_blank'>$symbol</a> &nbsp;</td>
        <td>$gene_name&nbsp;</td>
        </tr>
        ";
        
        flush();
    	ob_flush();
        
      }
      echo "
      </table>
      ";
      ?>
      
	<br>
	<form action="save_gene_list.php?id=<?php echo $id; ?>&cluster=<?php echo $cluster_id; ?>" method="POST" name="formulaire">
		<strong>Save this gene list with : </strong>
		<input type="radio" name="ids_type" value="GenBank-Id"> GenBank accession number
		<input type="radio" name="ids_type" value="Ensembl-Id"> Ensembl IDs
		<input type="radio" name="ids_type" value="Symbol-Id"> Symbol IDs 
		<br><br>
		<center><input type="submit" value="Save"></center>
	</form>
	
      <?php 
  }
  else
  {
    echo"not enter in database !<br><br>";
  }
  
}




function info_gene_list($madid, $species)
{
  global $connexionid,$base_madgene;
  
  if(preg_match("/,/", $species) )
  {
  	$requete_humain="
  	SELECT Annotation_gene_id, Annotation_gene_symbol, Annotation_gene_name
  	FROM annotations_Salmo_salar
  	WHERE seq_id='$madid'
  	;";
  	
  	$resultat_humain = mysqli_query ($connexionid,$requete_humain);
  	$num_res = mysqli_num_rows($resultat_humain);
  	
  	if($num_res==0)
  	{
  		$requete_humain="
	  	SELECT Annotation_gene_id, Annotation_gene_symbol, Annotation_gene_name
	  	FROM annotations_Oncorhynchus_mykiss
	  	WHERE seq_id='$madid'
	  	;";
	  	
	  	$resultat_humain = mysqli_query ($connexionid,$requete_humain);
  	}
  }
  else
  {
	  $tab=preg_replace("/ /", "_", $species);
	  $tab="annotations_".$tab;
	  
	  
	  if (preg_match("/Danio/", $species) )
	  {
	  	$requete_humain="
	  	SELECT Annotation_gene_id, Annotation_gene_symbol, gene_details
		FROM annotations_Danio_rerio, cDNA
		WHERE seq_id = '$madid'
		AND annotations_Danio_rerio.Annotation_gene_id = cDNA.gene_id
	  	;";
	  }
	  else
	  {
	  	$requete_humain="
	  	SELECT Annotation_gene_id, Annotation_gene_symbol, Annotation_gene_name
	  	FROM $tab
	  	WHERE seq_id='$madid'
	  	;";
	  }
  
  	$resultat_humain = mysqli_query ($connexionid,$requete_humain);
  }
  
  $info_humain = mysqli_fetch_object ($resultat_humain);
  
  return $info_humain ;
}



/////////////////////////////////////////////////////////////////
//pour avoir info symbol + name gene humain � partir d'un madid//
/////////////////////////////////////////////////////////////////
function info_madid_humain($madid, $species)
{
  global $connexionid,$base_madgene;
  
  $tab=preg_replace("/ /", "_", $species);
  $tab="annotations_".$tab;
  
  
  if (preg_match("/Danio/", $species) )
  {
  	$requete_humain="
  	SELECT Annotation_gene_id, Annotation_gene_symbol, orthologies_group_simple.ortho_num AS OrthoNum
  	FROM $tab, orthologies_group_simple
  	WHERE seq_id='$madid'
  	AND Annotation_gene_id = orthologies_group_simple.gene_id
  	;";
  }
  else
  {
  	$requete_humain="
  	SELECT Annotation_gene_id, Annotation_gene_symbol, Annotation_gene_name, orthologies_group_simple.ortho_num AS OrthoNum
  	FROM $tab, orthologies_group_simple
  	WHERE seq_id='$madid'
  	AND Annotation_gene_id = orthologies_group_simple.gene_id
  	;";
  }
  
  
  $resultat_humain = mysqli_query ($connexionid,$requete_humain);
  
  $info_humain = mysqli_fetch_object ($resultat_humain);
  
  return $info_humain ;
}


/////////////////////////////////////////////////////////////////
//pour avoir info symbol + name gene a partir d'un ID ENSEMBL//
/////////////////////////////////////////////////////////////////
function get_info_ensembl($madid)
{
  global $connexionid;
  
  $requete="
  SELECT DISTINCT(gene_name), gene_details
  FROM cDNA
  WHERE gene_id = '$madid'
  ;";
  
  $resultat = mysqli_query ($connexionid,$requete);
  
  $info = mysqli_fetch_object ($resultat);
  
  return $info ;
}



/////////////////////////////////////////////////////////////////
//     pour avoir les orthologs a partir d'un ID ENSEMBL       //
/////////////////////////////////////////////////////////////////
function get_orthologs($madid)
{
  global $connexionid;
  
  $requete="
	SELECT `orthologs`
	FROM `orthologies_tab`
	WHERE `gene_id` = '$madid'
	GROUP BY `orthologs`;
  ;";
  
  $resOrtho = mysqli_query ($connexionid,$requete);
  
  return $resOrtho ;
}




//////////////////////
//cluster annotation//
//////////////////////
function annotation($id,$cluster_id)
{
	global $connexionid;
	
	$requete_annotation = "
	SELECT fishAndchips.cluster.*
	FROM fishAndchips.cluster
	WHERE fishAndchips.cluster.id = '$id'
	AND fishAndchips.cluster.cluster_id = '$cluster_id'
	ORDER BY fishAndchips.cluster.p_value ASC
	;";
  
  	$resultat_annotation = mysqli_query ($connexionid,$requete_annotation);
	$nb_resultat_annotation = mysqli_num_rows($resultat_annotation);

	if($nb_resultat_annotation>0)
	{
		return $resultat_annotation ;
	}
}

/////////////////////////////////////////////////////////////////
// Fonction pour rechercher l'ID ENSEMBL d'un gene partir d'un identifiant //
/////////////////////////////////////////////////////////////////
function find_ensembl($gene,$species)
{
  global $connexionid,$base_madgene;
  
  $tab="annotations_".$species;
  
  $requete_GB = "
  SELECT Annotation_gene_id
  FROM $tab
  WHERE seq_id = '$gene'
  ";
  
  $requete_ENST = "
  SELECT DISTINCT(gene_id)
  FROM cDNA
  WHERE transcript_id = '$gene'
  ";
  
  $requete_SYMBOL = "
  SELECT DISTINCT(gene_id)
  FROM cDNA
  WHERE ( gene_name = '$gene'
  OR gene_name REGEXP '$gene \\\(' )
  AND gene_id NOT REGEXP 'MO'
  ";

  $etat = 1 ;    // 1 -> ENSG non trouv� !
  //ENSG
  if (preg_match("/^ENS\w{3}G/", $gene) )
  {
  	return $gene;
  }
  //ENST
  elseif (preg_match("/^ENS\w{3}T/", $gene) )
  {
	$resultat = mysqli_query ($connexionid,$requete_ENST);
	$nb_resultat = mysqli_num_rows($resultat);
		
	if($nb_resultat > 0){
		$madid = mysqli_fetch_object ($resultat);
		return $madid->gene_id;
	}
	else	{
		return false ;
	}	
  }
  /*
  //GB
  //elseif (preg_match("/^[A-Z]{2}_?[0-9]{6,13}/", $gene) )
  elseif (preg_match("/^[a-zA-Z]{2}_?[0-9]{6,13}/", $gene) )
  {
	$resultat = mysql_query ($requete_GB,$connexionid);
	$nb_resultat = mysql_num_rows($resultat);
	if($nb_resultat > 0)   {
		$madid = mysql_fetch_object ($resultat);
	
		return $madid->Annotation_gene_id ;
	}
	else    {
		return false ;
	}
  }
  */
  
  // SYMBOL et GB
  else
  {
  	$resultat = mysqli_query ($connexionid,$requete_SYMBOL);
	$nb_resultat = mysqli_num_rows($resultat);
	
	if($nb_resultat > 0){
		$madid = mysqli_fetch_object ($resultat);
		return $madid->gene_id;
	}
	else{
		
		$resultat = mysqli_query ($connexionid,$requete_GB);
		$nb_resultat = mysqli_num_rows($resultat);
		if($nb_resultat > 0)   {
			$madid = mysqli_fetch_object ($resultat);
	
			return $madid->Annotation_gene_id ;
		}
		else    {
			return false ;
		}
	}
  }

}


/////////////////////////////////////////////////////////////////////////
// Comparaison d'une liste avec les clusters 		VERSION SIMPLE //
/////////////////////////////////////////////////////////////////////////
function compare_clusters_simple ($liste)
{
	global $connexionid;
	
	echo"Convert input list ...";
	flush();
    	ob_flush();
	
	// CONVERSION DE LA LISTE EN numOrtho
	
	$orthoMatchList=array();
	
	$numList = array() ;
	$cpt=0;
	foreach($liste as $elt)
	{
		
		$requeteNumOrthoList = "
			SELECT `ortho_num` 
			FROM `orthologies_group_simple` 
			WHERE `gene_id`='$elt';
		";
		$resultNumOrtho = mysqli_query ($connexionid,$requeteNumOrthoList);
		while ($numOrtho = mysqli_fetch_object ($resultNumOrtho))
		{
			//echo"<br>$elt   $numOrtho->ortho_num";
			$numList[$cpt]=$numOrtho->ortho_num;
			$cpt++;
		}
		
	}	
	$liste=array_unique($numList);
	
	echo" DONE";
	flush();
    	ob_flush();
    	
	

	////////////////////////////////////////////////////////////////
	//Pré-calcul intersection "liste U - GPL" et taille du GPL /////
	////////////////////////////////////////////////////////////////
	
	
	echo"<br>Retrieve all probes foreach array design ...";
	flush();
    	ob_flush();
	
	$requete_liste_GPL = "
	SELECT array_id, species
	FROM array_design
	GROUP by array_id
	;";
	$result_GPL = mysqli_query ($connexionid,$requete_liste_GPL);
	$taille_GPL = array() ;
	$intersect = array() ;
	while ($GPL = mysqli_fetch_object ($result_GPL))
	{
		$numero_GPL = $GPL->array_id ;
		
		/*
		if($numero_GPL!="A-MEXP-664")
		{
			continue;
		}
		*/
		//echo"<br>$numero_GPL<br>";
		
		
		$numList = array() ;
		$cpt=0;
		
		/*
		$liste_gene_GPL = recupere_gene_GPL ($numero_GPL, $GPL->species) ;			// PROBLEME GPL MULTI ESPECES A REGLER
		
		foreach ($liste_gene_GPL as $elt)
		{
			//echo"<br>$elt";
			
			$requeteNumOrthoList = "
				SELECT `ortho_num` 
				FROM `orthologies_group_simple` 
				WHERE `gene_id`='$elt';
			";
			$resultNumOrtho = mysql_query ($requeteNumOrthoList,$connexionid);
			$numOrtho = mysql_fetch_object ($resultNumOrtho);
			
			$numList[$cpt]=$numOrtho->ortho_num;
			$cpt++;
		}
		*/
		
		$requeteNumOrthoList = "
			SELECT `ortho_num` 
			FROM `array_orthologs` 
			WHERE `array_id`='$numero_GPL';
		";
		$resultNumOrtho = mysqli_query ($connexionid,$requeteNumOrthoList);
		
		while ($numOrtho = mysqli_fetch_object ($resultNumOrtho))
		{
			$numList[$cpt]=$numOrtho->ortho_num;
			$cpt++;
		}
		
		//$liste_gene_GPL=$numList;
		$liste_gene_GPL=array_unique($numList);
		
		$intersect[$numero_GPL] = count(array_intersect($liste_gene_GPL,$liste)) ;
		
		$taille_GPL[$numero_GPL] = count($liste_gene_GPL) ;
		if($taille_GPL[$numero_GPL]==0)
		{
			$intersect[$numero_GPL] = 0;
			continue;
		}

		//echo "<br>$numero_GPL   $taille_GPL[$numero_GPL]   $intersect[$numero_GPL]<br>";
	}
	
	echo" DONE";
	flush();
    	ob_flush();
	
	////////////////////////////////////////////////////////////////
	//FIN Pré-calcul intersection "liste U - GPL" et taille du GPL /////
	////////////////////////////////////////////////////////////////
  	
  	
  	echo"<br>Retrieve all genes foreach cluster ...";
	flush();
    	ob_flush();
  	
  	/***************************************  TEST    *********************************************/
  	
  	$requete_cluster_ortho="
		SELECT `id`, `cluster_id`,`ortho_num`
		FROM `cluster_orthologs`
	";
	$resultat_cluster_ortho = mysqli_query ($connexionid,$requete_cluster_ortho);
	
	$newID="0-0";
	while ($res = mysqli_fetch_object ($resultat_cluster_ortho))
	{
		$tempID=$res->id."-".$res->cluster_id;
		
		if($newID=="0-0")
		{
			$newID=$tempID;
			$orthoNumTab=array();
			$cpt=0;
		}
		
		if($tempID!=$newID)
		{
			$orthoNumTab=array_unique($orthoNumTab);
			
			$big_tab[$newID]=$orthoNumTab;
			
			$newID=$tempID;
			$orthoNumTab=array();
			$cpt=0;
		}
		$orthoNumTab[$cpt]=$res->ortho_num;
		$cpt++;
		
		//array_push($orthoNumTab, $res->ortho_num);
	}
	mysqli_free_result($resultat_cluster_ortho);
	
	echo" DONE";
	flush();
    	ob_flush();
	
	//$now=date("H:i:s");
	//echo"<br>END TEST : $now<br>";
	

  	/***************************************   END TEST    *********************************************/
  	
  	
  	//recherche tous les clusters
  	$requete_clusters="
  		SELECT DISTINCT fishAndchips.liste_cluster_correct.id, fishAndchips.liste_cluster_correct.cluster_id
  		FROM fishAndchips.liste_cluster_correct
  	;";

  	$resultat_clusters = mysqli_query ($connexionid,$requete_clusters);

  	$result = array () ;
  	$compteur_result = 0 ;
  	
  	$compteurClust=0;
  	
  	echo"<br>Compare in progress ";
	flush();
    	ob_flush();
    	
    	// RECUPERATION DE TOUS LES SYMBOL AVEC LES NUM ORTHO
    	$requete_symbol_ortho="
		SELECT `ortho_num`,`symbol`
		FROM `cluster_orthologs`
		GROUP BY `ortho_num`;
	";
	$resultat_symbol_ortho = mysqli_query ($connexionid,$requete_symbol_ortho);
	
	$orthoSymbolTab=array();
	while($symb = mysqli_fetch_object ($resultat_symbol_ortho))
    	{
    		$orthoSymbolTab[$symb->ortho_num]=$symb->symbol;
    	}    	
    	
    	

  	//pour chaque cluster
  	while ($cluster = mysqli_fetch_object ($resultat_clusters))
  	{
  		//$now=date("H:i:s");
		//echo"<br>$now<br>";
		
		$compteurClust++;
		
		if(($compteurClust%10000)==0)
		{
			echo"<br>";
			flush();
    			ob_flush();
		}
		elseif(($compteurClust%100)==0)
		{
			echo".";
			flush();
    			ob_flush();
		}
				
		
		$newID=$cluster->id."-".$cluster->cluster_id;
		$liste_gene_cluster=$big_tab[$newID];
		
		
		/*
		echo"<br>$newID<br>";
		foreach($liste_gene_cluster as $val)
		{
			echo"$val / ";
		}
		echo"<br>";
		continue;
		*/
		
		
		
		/*
  		$id=$cluster->id;
  		$cluster_id=$cluster->cluster_id;
  		
   
	    //////////////////////////////////////////////////////////////////
	    // on a les 2 listes � comparer : $liste et $liste_gene_cluster //
	    //////////////////////////////////////////////////////////////////

   		$cpt=0;
   		$liste_gene_cluster = array () ;

		$requete_cluster_ortho="
			SELECT `ortho_num`
			FROM `cluster_orthologs`
			WHERE `id`='$id'
			AND `cluster_id`='$cluster_id'
			GROUP BY `ortho_num`
		";
		$resultat_cluster_ortho = mysql_query ($requete_cluster_ortho,$connexionid);
  		
  		while ($res = mysql_fetch_object ($resultat_cluster_ortho))
		{
    			$liste_gene_cluster[$cpt]=$res->ortho_num;
    			$cpt++;
    		}
    		*/
    		
    		$cummun = array_intersect($liste,$liste_gene_cluster);

		$nb_commun =  count($cummun) ;
    	
    	
    		//echo"<br>$id   $cluster_id   $nb_commun<br>";
    		
    		
    		$info_data = info_datasets ($cluster->id) ;
		$numero_gpl = $info_data->GPL ;
		

		$taille_GPL1 = $taille_GPL[$numero_gpl];

		if($nb_commun > 5 and $taille_GPL1 > 0)
		{
			$taille_GPL1 = $taille_GPL[$numero_gpl];
			
			$tailleR = count($liste) ;   //nbre de g�nes dans la liste de r�f�rence (liste utilisateur)
			$tailleT = count($liste_gene_cluster) ;   //nbre de g�nes dans la liste � tester (cluster de la base !)

			$poiu = $intersect[$numero_gpl] ;

			$c = $poiu - $nb_commun ;
			$d = $taille_GPL1 - $tailleT ;
			
			$score_gg =  $nb_commun/$tailleR ;
			
			$commande ="./fisher50000 $nb_commun $tailleT $c $d 2";
			$p_value = "" ;
			exec($commande,$p_value);
			
			
			$result[$compteur_result][0] = $cluster->id;
			//echo "dataset id:  $cluster->id<br>" ;
			$result[$compteur_result][1] = $cluster->cluster_id ;
			//echo "cluster: $cluster->cluster_id <br>" ;
			$result[$compteur_result][2] = $score_gg ;
			//echo "score gg: $score_gg <br>" ;
			$result[$compteur_result][3] = $p_value[0] ;
			//echo "p_value: $p_value[0] <br>" ;
			$result[$compteur_result][4] = $info_data->sample_species ;
			//echo "species: $info_data->sample_species <br>" ;
			
			
			$listlist = "" ;
			$geneNames="";
			foreach( $cummun as $valeur)
			{
				//echo"<br>$valeur<br>";
	
				//$listlist .= $valeur."_".$result[$compteur_result][4]."|"; // Contient les madid des genes en commun séparés par des |
				$listlist .= $valeur."|";

				//$gogo = get_info_ensembl($valeur);




				//Concatenation des symboles de genes en commun avec /
				/*
				$requete_symbol_ortho="
					SELECT `symbol`
					FROM `cluster_orthologs`
					WHERE `ortho_num`='$valeur'
					GROUP BY `symbol`;
				";
				
				$resultat_symbol_ortho = mysql_query ($requete_symbol_ortho,$connexionid);
				$symb = mysql_fetch_object ($resultat_symbol_ortho);
				$symbol=$symb->symbol;
		
				$geneNames.=$symbol."/";
				*/
				
				
				
				$geneNames.=$orthoSymbolTab[$valeur]."/";
			}

			$result[$compteur_result][5] = $listlist ;
			//echo "genes: $listlist <br>" ;
			$result[$compteur_result][6] =$tailleT ;
			//echo "nb genes dans cluster: $tailleT <br>" ;
			$result[$compteur_result][8] = $nb_commun ;
			//echo "nb commun: $nb_commun <br>" ;
			$result[$compteur_result][9] =  $geneNames;
			//echo "symbols: $geneNames <br>" ;
			$compteur_result++ ;
			//echo"<br><br>";
		}
		
		$big_tab[$newID]="";
		unset($big_tab[$newID]);
	}
	
	//$now=date("H:i:s");
	//echo"<br>END : $now<br>";
	
	$big_tab="";
	unset($big_tab);
	
	echo" DONE<br><br><br><br>";
	flush();
    	ob_flush();
	
	usort($result, "cmp3");
	return $result ;
}



///////////////////////////////////////////////
// Comparaison d'une liste avec les clusters //
///////////////////////////////////////////////
function compare_clusters_complex ($liste, $option, $clustFile, $ak)
{
	global $connexionid;
	
	$orthoMatchList=array();
	
	if($option=="ortho")
	{
		echo"<br>Search for orthologs ...";
		flush();
	    	ob_flush();
	    	
	    	$orthoIdList=array();
	    	$cpt=0;
		foreach($liste as $elt)
		{
			$cpt++;
			if(($cpt%20)==0)
			{
				echo".";
				flush();
	    			ob_flush();
			}
			
			array_push($orthoIdList, $elt);
			
			$resOrtho=get_orthologs($elt);
			while($orthoId = mysqli_fetch_object ($resOrtho))
			{
				array_push($orthoIdList, $orthoId->orthologs);
			}
		}
	    	$liste=array_unique($orthoIdList);
	
		echo" DONE";
		flush();
	    	ob_flush();
	}
	

	////////////////////////////////////////////////////////////////
	//Pré-calcul intersection "liste U - GPL" et taille du GPL /////
	////////////////////////////////////////////////////////////////
	
	
	echo"<br>Retrieve all probes for each array design ...";
	flush();
    	ob_flush();
    	
	
	$requete_liste_GPL = "
	SELECT array_id, species
	FROM array_design
	GROUP by array_id
	;";
	$result_GPL = mysqli_query ($connexionid,$requete_liste_GPL);
	$taille_GPL = array() ;
	$intersect = array() ;
	while ($GPL = mysqli_fetch_object ($result_GPL))
	{
		$numero_GPL = $GPL->array_id ;
		
		$numList = array() ;
		$cpt=0;
		
		$requeteNumOrthoList = "
			SELECT `gene_id` 
			FROM `array_gene` 
			WHERE `array_id`='$numero_GPL';
		";
		$resultNumOrtho = mysqli_query ($connexionid,$requeteNumOrthoList);
		
		while ($numOrtho = mysqli_fetch_object ($resultNumOrtho))
		{
			$numList[$cpt]=$numOrtho->gene_id;
			$cpt++;
		}
		
		$liste_gene_GPL=array_unique($numList);
		
		$taille_GPL[$numero_GPL] = count($liste_gene_GPL) ;
		if($taille_GPL[$numero_GPL]==0)
		{
			$intersect[$numero_GPL] = 0;
		}
		else
		{
			$intersect[$numero_GPL] = count(array_intersect($liste_gene_GPL,$liste)) ;
		}
	}
	
	echo" DONE";
	flush();
    	ob_flush();

	
	////////////////////////////////////////////////////////////////
	//FIN Pré-calcul intersection "liste U - GPL" et taille du GPL /////
	////////////////////////////////////////////////////////////////
  	
  	
  	echo"<br>Retrieve all genes foreach cluster ...";
	flush();
    	ob_flush();
  	
  	/***************************************  TEST    *********************************************/
  	
  	$requete_cluster_ortho="
		SELECT `id`, `cluster_id`,`gene_id`
		FROM `cluster_gene`;
	";
	$resultat_cluster_ortho = mysqli_query ($connexionid,$requete_cluster_ortho);
	
	$newID="0-0";
	while ($res = mysqli_fetch_object ($resultat_cluster_ortho))
	{
		$tempID=$res->id."-".$res->cluster_id;
		
		if($newID=="0-0")
		{
			$newID=$tempID;
			$orthoNumTab=array();
			$cpt=0;
		}
		
		if($tempID!=$newID)
		{
			//$orthoNumTab=array_unique($orthoNumTab);
			
			//echo "<br>$newID     ";
			//echo count($orthoNumTab);
			
			$big_tab[$newID]=$orthoNumTab;
			
			$newID=$tempID;
			$orthoNumTab=array();
			$cpt=0;
		}
		$orthoNumTab[$cpt]=$res->gene_id;
		$cpt++;
	}
	mysqli_free_result($resultat_cluster_ortho);
	
	echo" DONE";
	flush();
    	ob_flush();
	
	//$now=date("H:i:s");
	//echo"<br>END TEST : $now<br>";
	

  	/***************************************   END TEST    *********************************************/
  	
  	
  	if($clustFile!="EMPTY")
  	{
  		$requete_clusters=convertClustFile($clustFile);
  	}
  	else
  	{
	  	//recherche tous les clusters
	  	$requete_clusters="
	  		SELECT DISTINCT fishAndchips.liste_cluster_correct.id, fishAndchips.liste_cluster_correct.cluster_id
	  		FROM fishAndchips.liste_cluster_correct
	  	;";
	}
	
	//echo "<br>$requete_clusters<br><br>";

  	$resultat_clusters = mysqli_query ($connexionid,$requete_clusters);

  	$result = array () ;
  	$compteur_result = 0 ;
  	
  	$compteurClust=0;
  	
  	echo"<br>Compare in progress <br>";
	flush();
    	ob_flush();
    	
    	// RECUPERATION DE TOUS LES SYMBOL AVEC LES NUM ORTHO
    	$requete_symbol_ortho="
		SELECT `gene_id`,`symbol`
		FROM `cluster_gene`
		GROUP BY `gene_id`;
	";
	$resultat_symbol_ortho = mysqli_query ($connexionid,$requete_symbol_ortho);
	
	$orthoSymbolTab=array();
	while($symb = mysqli_fetch_object ($resultat_symbol_ortho))
    	{
    		$orthoSymbolTab[$symb->gene_id]=$symb->symbol;
    	}    	
    	
    	

  	//pour chaque cluster
  	while ($cluster = mysqli_fetch_object ($resultat_clusters))
  	{
  		//$now=date("H:i:s");
		//echo"<br>$now<br>";
		
		$compteurClust++;
		
		if(($compteurClust%4500)==0)
		{
			echo"<br>";
			flush();
    			ob_flush();
		}
		elseif(($compteurClust%35)==0)
		{
			echo".";
			flush();
    			ob_flush();
		}
				
		
		$newID=$cluster->id."-".$cluster->cluster_id;
		$liste_gene_cluster=$big_tab[$newID];
		
		
		/*
		echo"<br>$newID<br>";
		foreach($liste_gene_cluster as $val)
		{
			echo"$val / ";
		}
		echo"<br>";
		continue;
		*/
		
		
		
		/*
  		$id=$cluster->id;
  		$cluster_id=$cluster->cluster_id;
  		
   
	    //////////////////////////////////////////////////////////////////
	    // on a les 2 listes � comparer : $liste et $liste_gene_cluster //
	    //////////////////////////////////////////////////////////////////

   		$cpt=0;
   		$liste_gene_cluster = array () ;

		$requete_cluster_ortho="
			SELECT `ortho_num`
			FROM `cluster_orthologs`
			WHERE `id`='$id'
			AND `cluster_id`='$cluster_id'
			GROUP BY `ortho_num`
		";
		$resultat_cluster_ortho = mysql_query ($requete_cluster_ortho,$connexionid);
  		
  		while ($res = mysql_fetch_object ($resultat_cluster_ortho))
		{
    			$liste_gene_cluster[$cpt]=$res->ortho_num;
    			$cpt++;
    		}
    		*/
    		
    		$cummun = array_intersect($liste,$liste_gene_cluster);

		$nb_commun =  count($cummun) ;
    	
    	
    		//echo"<br>$id   $cluster_id   $nb_commun<br>";
    		
    		
    		$info_data = info_datasets ($cluster->id) ;
		$numero_gpl = $info_data->GPL ;
		

		$taille_GPL1 = $taille_GPL[$numero_gpl];

		if($nb_commun > 2 and $taille_GPL1 > 0)
		{
			$taille_GPL1 = $taille_GPL[$numero_gpl];
			
			$tailleR = count($liste) ;   //nbre de g�nes dans la liste de r�f�rence (liste utilisateur)
			$tailleT = count($liste_gene_cluster) ;   //nbre de g�nes dans la liste � tester (cluster de la base !)

			$poiu = $intersect[$numero_gpl] ;

			$c = $poiu - $nb_commun ;
			$d = $taille_GPL1 - $tailleT ;
			
			#$score_gg =  $nb_commun/$tailleR ; // calcul du ratio
			$score_gg =  $nb_commun/$ak ;
			
			$commande ="./fisher50000 $nb_commun $tailleT $c $d 2";
			$p_value = "" ;
			exec($commande,$p_value);
			
			
			$result[$compteur_result][0] = $cluster->id;
			//echo "dataset id:  $cluster->id<br>" ;
			$result[$compteur_result][1] = $cluster->cluster_id ;
			//echo "cluster: $cluster->cluster_id <br>" ;
			$result[$compteur_result][2] = $score_gg ;
			//echo "score gg: $score_gg <br>" ;
			$result[$compteur_result][3] = $p_value[0] ;
			//echo "p_value: $p_value[0] <br>" ;
			$result[$compteur_result][4] = $info_data->sample_species ;
			//echo "species: $info_data->sample_species <br>" ;
			
			
			$listlist = "" ;
			$geneNames="";
			foreach( $cummun as $valeur)
			{
				//echo"<br>$valeur<br>";
	
				//$listlist .= $valeur."_".$result[$compteur_result][4]."|"; // Contient les madid des genes en commun séparés par des |
				$listlist .= $valeur."|";

				//$gogo = get_info_ensembl($valeur);




				//Concatenation des symboles de genes en commun avec /
				/*
				$requete_symbol_ortho="
					SELECT `symbol`
					FROM `cluster_orthologs`
					WHERE `ortho_num`='$valeur'
					GROUP BY `symbol`;
				";
				
				$resultat_symbol_ortho = mysql_query ($requete_symbol_ortho,$connexionid);
				$symb = mysql_fetch_object ($resultat_symbol_ortho);
				$symbol=$symb->symbol;
		
				$geneNames.=$symbol."/";
				*/
				
				
				
				$geneNames.=$orthoSymbolTab[$valeur]."/";
			}

			$result[$compteur_result][5] = $listlist ;
			//echo "genes: $listlist <br>" ;
			$result[$compteur_result][6] =$tailleT ;
			//echo "nb genes dans cluster: $tailleT <br>" ;
			$result[$compteur_result][8] = $nb_commun ;
			//echo "nb commun: $nb_commun <br>" ;
			$result[$compteur_result][9] =  $geneNames;
			//echo "symbols: $geneNames <br>" ;
			$compteur_result++ ;
			//echo"<br><br>";
		}
		
		$big_tab[$newID]="";
		unset($big_tab[$newID]);
	}
	
	//$now=date("H:i:s");
	//echo"<br>END : $now<br>";
	
	$big_tab="";
	unset($big_tab);
	
	echo" DONE<br>";
	flush();
    	ob_flush();
    	
    	
    	if($option=="ortho")
	{
		$listeOrthoNumb=count($liste);
		echo"<br><br>With orthologs, there are <b>$listeOrthoNumb</b> unique genes in your list.<br>";
	}
	
	echo"<br><br><br>";
    	
	
	usort($result, "cmp3");
	return $result ;
}




function recupere_gene_GPL ($numero_GPL, $species)
{

  global $connexionid,$base_madgene;

  //recherche tout les g�nes d'un cluster
	/*
  $requete_recup_gene="
  SELECT fish_chips.GPL_composition2.mad_id
  FROM fish_chips.GPL_composition2
  WHERE fish_chips.GPL_composition2.gpl = '$numero_GPL'
  ;";
	*/
	
	$tab=preg_replace("/ /", "_", $species);
  	$tab="annotations_".$tab;

	$requete_recup_gene="
	SELECT `Annotation_gene_id`
	FROM $tab , `array_design`
	WHERE $tab.`seq_id` = `array_design`.`gb_acc` 
	AND `array_design`.`array_id` = '$numero_GPL'
	AND `Annotation_gene_id` IS NOT NULL
	GROUP BY `Annotation_gene_id`
	;";


  $resultat_recup_gene = mysqli_query ($connexionid,$requete_recup_gene);

  $liste_gene_gpl = array () ;
  $compteur_cluster = 0 ;
  //pour chaque madid
  while ($lemadid = mysqli_fetch_object ($resultat_recup_gene))
  {
    $liste_gene_gpl[$compteur_cluster] =  $lemadid->Annotation_gene_id;
    $compteur_cluster++ ;
    
    //$liste_gene_gpl[$lemadid->Annotation_gene_id] = 0;
  }
  mysqli_free_result($resultat_recup_gene);
  return $liste_gene_gpl ;
}


/////////////////////////////////////////////
// recup�re les g�nes (madid) d'un cluster //
/////////////////////////////////////////////
function recupere_gene_cluster ($id,$cluster_id,$species)
{

  global $connexionid;
  
  $tab=preg_replace("/ /", "_", $species);
  $tab="annotations_".$tab;

  //recherche tout les g�nes d'un cluster
  $requete_recup_gene="
  SELECT $tab.Annotation_gene_id
  FROM gene_selection_correct, $tab
  WHERE gene_selection_correct.id ='$id'
  AND gene_selection_correct.cluster_id ='$cluster_id'
  AND gene_selection_correct.gb_acc IS NOT NULL
  AND $tab.seq_id = gene_selection_correct.gb_acc
  AND $tab.Annotation_gene_id IS NOT NULL
  GROUP BY $tab.Annotation_gene_id
  ;";

  $resultat_recup_gene = mysqli_query ($connexionid,$requete_recup_gene);

  $liste_gene_cluster = array () ;
  $compteur_cluster = 0 ;
  //pour chaque madid
  while ($lemadid = mysqli_fetch_object ($resultat_recup_gene))
  {
    $liste_gene_cluster[$compteur_cluster] =  $lemadid->Annotation_gene_id;
    $compteur_cluster++ ;
  }  

  return $liste_gene_cluster ;
}


/////////////////////////
//Test exact de Fisher //
/////////////////////////
function fisher ($a,$b,$c,$d)
{
  if($a*$d>$b*$c){
  $temp=$b; $b=$a; $a=$temp;
  $temp=$d; $d=$c; $c=$temp;
  }

  if($a>$d){$temp=$d; $d=$a; $a=$temp;}
  if($b>$c){$temp=$b; $b=$c; $c=$temp;}
  $a_org=$a;
  $p_sum=0;
  $p_1=$p=FisherSub($a,$b,$c,$d);
  while($a>=0)
  	{
  	$p_sum +=$p;
  	if($a==0){break;}
  	--$a; ++$b; ++$c; --$d;
  	$p=FisherSub($a,$b,$c,$d);
  	}
  if($test==1){return($p_sum);}
  $a=$b; $b=0; $c=$c-$a; $d=$d+$a;
  $p=FisherSub($a,$b,$c,$d);
  while($p<$p_1)
  	{
  	if($a==$a_org){break;}
  	$p_sum +=$p;
  	--$a; ++$b; ++$c; --$d;
  	$p=FisherSub($a,$b,$c,$d);
  	}
  //resultat
  return $p_sum ;

}
/////////////////////////////
// 2 fonctions pour Fisher //
/////////////////////////////
function FisherSub ($a,$b,$c,$d)
	{
	$p=0;
	$p=logfactorial($a+$b)+logfactorial($c+$d)+logfactorial($a+$c)+logfactorial($b+$d)-logfactorial($a+$b+$c+$d)-logfactorial($a)-logfactorial($b)-logfactorial($c)-logfactorial($d);
	return (exp($p));
	}

function logfactorial ()
	{
	if (func_get_arg(0)==0){return(0);}
	else{ $result=0;
	for($i=2;$i<=func_get_arg(0);$i++){$result+=log($i);}
	return $result;}
	}
///////////////////////////////////////////////
// fonction pour le tri sur la colonne 3 [2] //
///////////////////////////////////////////////
function cmp1($a,$b) {
    return ($a[2] > $b[2]) ? -1 : 1;
}
function cmp3($a,$b) {
	if($a[3]==$b[3])
	{
		return ($a[2] > $b[2]) ? -1 : 1;
	}
	else
	{
    return ($a[3] < $b[3]) ? -1 : 1;
	}
}



/////////////////////////////////////////
// Fonctions pour la page topics ////
//////////////////////////////////////////

//Creation du formulaire
function formulaire_dynamique ()
{
  global $connexionid;
  
  echo "
  <FORM ACTION='search.php' METHOD=POST ENCTYPE='multipart/form-data'>
  ";

  //choix de l'esp�ce
  $requete_espece = "
  SELECT DISTINCT fishAndchips.datasets.species
  FROM fishAndchips.datasets
  ;";
  
  $resultat_espece = mysqli_query ($connexionid,$requete_espece);
  
  $nb_resultat_espece = mysqli_num_rows($resultat_espece);

  if($nb_resultat_espece>0)
  {
    echo "<p>Select your species: <SELECT NAME='species' SIZE=1>";
    echo"<OPTION VALUE=all>all" ;
    while ($ligne_espece = mysqli_fetch_object ($resultat_espece))
    {
      if($ligne_espece->species != "")
      {
        echo"<OPTION VALUE=$ligne_espece->species>$ligne_espece->species" ;
      }
    }
    echo "</select></p>" ;
  }

  // affichage dynamique des topics
  $requete_type ="
  SELECT DISTINCT fishAndchips.topics.type
  FROM fishAndchips.topics
  ;";

  $resultat_type = mysqli_query ($connexionid,$requete_type);

  $nb_resultat_type = mysqli_num_rows($resultat_type);

  if($nb_resultat_type>0)
  {
    while ($ligne = mysqli_fetch_object ($resultat_type))
    {
      if($ligne->type != "")
      {
        echo "<p>Select your $ligne->type: <SELECT NAME='$ligne->type' SIZE=1>";
        // Recherche des sous types correspondant � ce type
        $requete_sous_type = "
        SELECT DISTINCT fishAndchips.topics.sous_type
        FROM fishAndchips.topics
        WHERE fishAndchips.topics.type = '$ligne->type'
        ;";
        $resultat_sous_type = mysqli_query ($connexionid,$requete_sous_type);

        $nb_resultat_sous_type = mysqli_num_rows($resultat_sous_type);

        if($nb_resultat_sous_type>0)
        {
          echo"<OPTION VALUE=all>all" ;
          while ($ligne_sous_type = mysqli_fetch_object ($resultat_sous_type))
          {
            echo"<OPTION VALUE='$ligne_sous_type->sous_type'>$ligne_sous_type->sous_type" ;
          }
        }
        echo "</select></p>" ;
      }
    }
  }
  
  echo "
  <p>Select only meta-analysis datasets:<input type='checkbox' name='meta' value='oui'></p>
  ";
  
  echo "<INPUT TYPE=SUBMIT VALUE='Search'>" ;
}

/////////////////
//Affichage du resultat (search) ////
//////////////////////
function resultat_search ()
{
  global $connexionid;
  
  $species = htmlentities($_POST['species']);
  $meta = htmlentities($_POST['meta']);

  if($meta == TRUE)
  {
    $meta = "oui";
  }
  else
  {
    $meta = "non" ;
  }

  //Construction dynamique de la requete
  $requete_search = "
  SELECT DISTINCT fishAndchips.datasets.*
  FROM fishAndchips.datasets, fishAndchips.information, fishAndchips.topics
  WHERE fishAndchips.datasets.rep IS NOT NULL
  ";

  if($meta == "oui")
  {
   $requete_search .= "AND fishAndchips.datasets.meta = '$meta'" ;
  }

  
  if($species != 'all')
  {

    $requete_search .= "AND fishAndchips.datasets.species LIKE '$species%'" ;
  }
  
  
  $requete_type ="
  SELECT DISTINCT fish_chips.topics.type
  FROM fish_chips.topics
  ;";

  $resultat_type = mysqli_query ($connexionid,$requete_type);

  $nb_resultat_type = mysqli_num_rows($resultat_type);

  if($nb_resultat_type>0)
  {
    while ($ligne = mysqli_fetch_object ($resultat_type))
    {
      if($ligne->type != "")
      {
        $type_dynamique = "" ;
        $sous_type_dynamique = "" ;
        $type_dynamique = $ligne->type ;
        
        $sous_type_dynamique = htmlentities($_POST["$type_dynamique"]);
        if($sous_type_dynamique != 'all')
        {
          $requete_search .= "
          AND fishAndchips.datasets.id IN
          (
          SELECT fishAndchips.datasets.id
          FROM fishAndchips.information, fishAndchips.topics, fishAndchips.datasets
          WHERE fishAndchips.information.info_id = fishAndchips.topics.info_id
          AND fishAndchips.datasets.id = fishAndchips.information.id
          AND fishAndchips.topics.type = '$type_dynamique'
          AND fishAndchips.topics.sous_type = '$sous_type_dynamique'
          )
          " ;
        }
      }
    }
  }
  $requete_search .= ";" ;
  //echo "$requete_search" ;
  
  //interrogation de la base
  $resultat_search = mysqli_query ($connexionid,$requete_search);

  $nb_resultat_search = mysqli_num_rows($resultat_search);

  if($nb_resultat_search>0)
  {
    echo "
    <TABLE BORDER=2 Bordercolor=#FFFFFF class=\"texte_general\">
    <TR><TD>Name</TD><TD>Title</TD><TD>Quality</TD></TR>
    ";
    while ($ligne_search = mysqli_fetch_object ($resultat_search))
    {
      echo"
      <TR><TD><A href=./view.php?id=$ligne_search->id>$ligne_search->name</A></TD><TD>$ligne_search->titre</TD>
      ";
      if($ligne_search->quality_estimate != "")
      {
        echo "<TD><CENTER><IMG SRC=./code_quality/Image$ligne_search->quality_estimate.png></CENTER></TD></TR>";
      }
      else
      {
        echo "<TD><CENTER>?</CENTER></TD></TR>";
      }
    }
    echo "
    </TABLE>
    ";
  }
  else
  {
    echo "<br><br>no result !<br><br>";
  }
  
}
/////////////////
//Affichage du resultat (search)nouveau avec keyword
//////////////////////
function resultat_search_new ()
{
  global $connexionid;

  $species = htmlentities($_POST['species']);
  $key = htmlentities($_POST['key']);
  
  $key=preg_replace('/\s/', '.*', $key);

  $requete1 ="
  SELECT fishAndchips.datasets.id, fishAndchips.datasets.directory, fishAndchips.datasets.GPL, fishAndchips.datasets.title, fishAndchips.datasets.quality_estimate
  FROM fishAndchips.datasets
  ";
  
  if($species != "all")
  {
    $requete1 .= "WHERE fish_chips.datasets.sample_species LIKE '%$species%'" ;
  }
  if($species != "all" and $key != "") {$requete1 .= " AND ";} elseif($species == "all" and $key != "") {$requete1 .= " WHERE ";}
  if($key != "")
  {
    #$requete1 .= "(fish_chips.datasets.title LIKE '%$key%' OR fish_chips.datasets.summary LIKE '%$key%' OR fish_chips.datasets.design LIKE '%$key%')" ;
    $requete1 .= "(fishAndchips.datasets.title REGEXP '$key' OR fishAndchips.datasets.summary REGEXP '$key' OR fishAndchips.datasets.design REGEXP '$key')" ;
  }
  $requete1 .= "ORDER BY quality_estimate DESC, quality_auto ASC;";
  //echo "<br>$requete1<br>";
  $resultat1 = mysqli_query ($connexionid,$requete1);

  $nb_resultat1 = mysqli_num_rows($resultat1);

  echo"$nb_resultat1 datasets: <a href=javascript:fenCentre(\"helpfile1.html\",300,400)>Help</a><br>";

  if($nb_resultat1>0)
  {?>
    <table>
    <tr>
		<th id="DSid">Name</td>
		<th >Title</td>
		<th id="quality">Quality</td>
	</tr>
    <?php 
    while ($ligne = mysqli_fetch_object ($resultat1))
    {
      echo"<tr><td><a href=./view.php?id=$ligne->id>$ligne->directory";

	if ( !(preg_match('/(-A-)|(-GPL)/', $ligne->directory)) && !(preg_match('/AQUAEXCEL/', $ligne->directory)))
	{
		echo "-$ligne->GPL";
	}

	echo "</a></td><td>$ligne->title</td>";

      if($ligne->quality_estimate != "")
      {
        echo "<td><center><img src=./images/code_quality/Image$ligne->quality_estimate.png></center></td></tr>";
      }
      else
      {
        echo "<td><center>?</center></td></tr>";
      }
    }
    echo "
    </table>
    ";
  }
  else
  {
    echo"no result !<br><br><br>";
  }

}

function temps(){
//microtime renvoie le temps Unix en �sec, sec
	$tableau=explode(" ", microtime());
	return ($tableau[1]+$tableau[0]);
}

function give_quality ($id)
{
	echo"
	<div id='change_quality'l>
	<b>Your are connected with administrator permission ! </b><br>
	<FORM ACTION='view.php?id=$id' METHOD=POST ENCTYPE='multipart/form-data'>
	<input type=hidden name=change VALUE='letruc' >
	<p>Quality: <SELECT NAME='note' SIZE=1>

    <OPTION VALUE='0'>0
    <OPTION VALUE='1'>1
    <OPTION VALUE='2'>2
    <OPTION VALUE='3'>3
    <OPTION VALUE='4'>4
    </select><INPUT TYPE=SUBMIT VALUE='Change'>
</div>
	";
}
function change_quality ($id,$note)
{
	global $connexionid;
	$requete = "
	UPDATE fishAndchips.datasets
	SET fishAndchips.datasets.quality_estimate =  '$note'
	WHERE fishAndchips.datasets.id = '$id' ;
	";
	$resultat = mysqli_query ($connexionid,$requete);
}

function quality_auto ($id, $cluster_id)
{
	global $connexionid;
	$requete = "
	SELECT fishAndchips.quality_cluster.quality
	FROM fishAndchips.quality_cluster
	WHERE fishAndchips.quality_cluster.id = '$id'
	AND fishAndchips.quality_cluster.cluster_id = '$cluster_id' ;
	";
	$resultat = mysqli_query ($connexionid,$requete);
	$res = mysqli_fetch_object ($resultat);
	return($res->quality);
}
function quality_auto_new ($id, $cluster_id)
{
	global $connexionid;
	$requete = "
	SELECT fishAndchips.quality_cluster_new.quality
	FROM fishAndchips.quality_cluster_new
	WHERE fishAndchips.quality_cluster_new.id = '$id'
	AND fishAndchips.quality_cluster_new.cluster_id = '$cluster_id' ;
	";
	$resultat = mysqli_query ($connexionid,$requete);
	$res = mysqli_fetch_object ($resultat);
	return($res->quality);
}	

//  Fonctions GO Stats (Eric)


/////////////////////////////////////////////////////
//pour avoir info symbol + name gene grace au madid//
/////////////////////////////////////////////////////
function symbol_madid($madid, $species)
{
  global $connexionid, $base_madgene;

  $requete_humain="
  SELECT $base_madgene.Off_symbol.off_symbol, $base_madgene.Off_symbol.name
  FROM $base_madgene.Off_symbol, $base_madgene.MAD_gene
  WHERE $base_madgene.MAD_gene.species = '$species'
  AND $base_madgene.MAD_gene.mad_id = '$madid'
  AND $base_madgene.MAD_gene.symbol_id = $base_madgene.Off_symbol.symbol_id
  ;";

  $resultat_humain = mysqli_query ($connexionid,$requete_humain);

  $info_humain = mysqli_fetch_object ($resultat_humain);

  return $info_humain ;
}
///////////////////////////////////////////////////////////////
//pour r�cuperer les annotations correspondantes � un symbol //
///////////////////////////////////////////////////////////////
function annot_symbol($symbol, $species, $spec)
{
  $name = $symbol;
//pour chaque symbol  on recupere les annotations parents
  if ($name != "")
  {
    global $connexionid, $base_occurence;
//pour les official name humain
    if($species == "Hs")
    {
      $name2 = $symbol."_HUMAN";
      $requete_annot_parent = "
          SELECT DISTINCT $base_occurence.gen_annot_$spec.GO_id
          FROM $base_occurence.gen_annot_$spec
          WHERE  $base_occurence.gen_annot_$spec.off_symbol LIKE '$name'
          OR $base_occurence.gen_annot_$spec.symbol LIKE '$name2'
          ";
      $res =mysqli_query($connexionid,$requete_annot_parent);

      if (mysqli_num_rows($res)== 0)
      {
        $requete_annot_parent = "
          SELECT DISTINCT $base_occurence.gen_annot_$spec.GO_id
          FROM $base_occurence.gen_annot_$spec
          WHERE $base_occurence.gen_annot_$spec.symbol LIKE (
              SELECT $base_occurence.offhuman.entryName
              FROM $base_occurence.offhuman
              WHERE $base_occurence.offhuman.symbol = '$name')
        ";
        $res =mysqli_query($connexionid,$requete_annot_parent);

        if (mysqli_num_rows($res)== 0)
        {
          $requete_annot_parent = "
            SELECT DISTINCT $base_occurence.gen_annot_$spec.GO_id
            FROM $base_occurence.gen_annot_$spec
            WHERE $base_occurence.gen_annot_$spec.symbol LIKE (
              SELECT $base_occurence.humansynonym.entryName
              FROM $base_occurence.humansynonym
              WHERE $base_occurence.humansynonym.symbol = '$name')
        ";
        $res =mysqli_query($connexionid,$requete_annot_parent);
        } #finif
      } #finif
    } #finif
    else
    {
        $requete_annot_parent = "
          SELECT DISTINCT $base_occurence.gen_annot_$spec.GO_id
          FROM $base_occurence.gen_annot_$spec
          WHERE  $base_occurence.gen_annot_$spec.symbol LIKE '$name'
          ";
        $res =mysqli_query($connexionid,$requete_annot_parent);
    } //finifelse

    return $res;
  }//finif
}//finannot_symbol

////////////////////////////////////////////////////////////////////////////////
// pour r�cuperer l'occurence d'une annotation GO dans le g�nome
////////////////////////////////////////////////////////////////////////////////
function GO_occur($go, $spec)
{
  global $connexionid, $base_occurence;

  $requete_occ_symbol = "
    SELECT DISTINCT $base_occurence.GO_occur_$spec.occurence
    FROM $base_occurence.GO_occur_$spec
    WHERE $base_occurence.GO_occur_$spec.GO_id LIKE '$go'
  ";
  $result = mysqli_query($connexionid,$requete_occ_symbol);
  return $result;
}//finGO_occur

////////////////////////////////////////////
// pour r�cuperer le nom d'une annotation //
////////////////////////////////////////////
function go_annot($numgo)
{
  global $connexionid, $base_go;
  
  $requete_name_go = "SELECT $base_go.term.name FROM $base_go.term WHERE $base_go.term.acc like '$numgo';";

  $res = mysqli_query($connexionid,$requete_name_go);

  return $res ;
}//fingo_annot

///////////////////////////////////////////////////////////
// pour retrouver un gene poss�dant l'annotation choisie //
///////////////////////////////////////////////////////////
function searchgene($name, $go, $spec)
{
  global $connexionid, $base_occurence;
//pour les official name humain
  if($spec == 88299)
  {
    $name2 = $name."_HUMAN";
    $requete_annot_parent = "
          SELECT $base_occurence.gen_annot_$spec.GO_id
          FROM $base_occurence.gen_annot_$spec
          WHERE  $base_occurence.gen_annot_$spec.off_symbol LIKE '$name'
          AND $base_occurence.gen_annot_$spec.GO_id LIKE '$go'
          OR $base_occurence.gen_annot_$spec.symbol LIKE '$name2'
          AND $base_occurence.gen_annot_$spec.GO_id LIKE '$go';
          ";
  }
  else
  {
      $requete_annot_parent = "
          SELECT $base_occurence.gen_annot_$spec.GO_id
          FROM $base_occurence.gen_annot_$spec
          WHERE  $base_occurence.gen_annot_$spec.symbol LIKE '$name'
          AND $base_occurence.gen_annot_$spec.GO_id LIKE '$go';
          ";
  } //finifelse

  $res =mysqli_query($connexionid,$requete_annot_parent);
  return ($res);
}


### Cette fonction copie automatiquement les resultats du compare dans un fichier temporaire sur le serveur du portail (/home/tmp). Ce fichier est déplacé dans le dossier personnel sur demande de l'utilisateur (click sur save)
####################### 
function send_compare_to_home_tmp($super_result,$userfilename) {
	global $home_server;

	##Cherche les infos sur les datasets et les annotations dans la base
	$info_data = $info_dataset = $goterms = array () ;
	$resume=array(); ## equivalent au tableau $super_result, moins la colonne [5] avec le symbol et nom des gènes(avec un lien html)
	for($i = 0 ; $i < count($super_result) ; $i++)
	{
		$id = $super_result[$i][0] ;
		$resume[$i][0]=$super_result[$i][0] ;
		$cluster_id = $super_result[$i][1] ;
		$resume[$i][1]=$super_result[$i][1] ;
	
		$info_data[$i] = info_datasets ($id) ;
		$info_dataset[$i]["directory"] = $info_data[$i]->directory;
		$info_dataset[$i]["GDS"] = $info_data[$i]->GDS;
		
		$resultat_annotation = annotation($id,$cluster_id);
		$j=0;
		while($info_annotation = mysqli_fetch_object ($resultat_annotation))
		{
			$goterms[$i][$j] = $info_annotation->GO_term ;
			$j++;
		}

		$resume[$i][2]=$super_result[$i][2] ; //p-val
		$resume[$i][3]=$super_result[$i][3] ; //score similarite
		$resume[$i][4]=$super_result[$i][4] ; //espece
		$resume[$i][5]=$super_result[$i][6] ; //taille cluster input
		$resume[$i][6]=$super_result[$i][8] ; //nb genes en commun
		$resume[$i][7]=$super_result[$i][9] ; //Nom genes en commun separes par des /
	}

	##Nom du fichier qui sera stocké dans le rep tmp du home serveur
	$date=date("jmY_G:i");

	$resultfile = "fish_chips_compare_".$date."_".$userfilename;
	// On passe ces variables au serveur contenant l'espace de résultats
	//$client = new SoapClient("http://$home_server/madtools/soap/madtools_userdata.wsdl", array('trace'=>1));
	//$client->write_userdata($resume,$info_dataset,$goterms,$resultfile);
 
	return $resultfile;
}

/*
function createXmlResultCluster($dataset_id,$cluster,$identifiant){
	global $home_server;

	$info_data = info_datasets ($dataset_id);
// 	$annotation = recupere_annotation_cluster ($dataset_id,$cluster);
	$resultat_annotation = annotation ($dataset_id,$cluster);
	$i=0;
	while($info_annotation = mysql_fetch_object ($resultat_annotation))
	{
		$annotation[$i]['GO_ID'] = $info_annotation->GO_ID ;
		$annotation[$i]['GO_term'] = $info_annotation->GO_term ;
		$annotation[$i]['p_value'] = $info_annotation->p_value ;
		$i++;
	}  
  	$liste_madid = recupere_gene_cluster ($dataset_id,$cluster);
  
	## Envoi des parametres au serveur "home" pour l'enregistrement des résultats dans l'espace personnel
	//$client = new SoapClient("http://$home_server/madtools/soap/madtools_userdata.wsdl",array('trace'=>1));
	//$GSE=$info_data->directory;
	//$client->save_cluster($identifiant,$GSE,$dataset_id,$cluster,$info_data->species_GPL,$annotation,$liste_madid,"MADMUSCLE");

	return $GSE;
}
*/

### Cette fonction copie automatiquement les resultats de "Test your list" dans un fichier temporaire XML sur le serveur du portail (/home/tmp). Ce fichier est déplacé dans le dossier personnel sur demande de l'utilisateur (click sur save)
####################### 
function send_your_list_to_home_tmp($input_list,$madid_list,$species,$userfilename){
	global $home_server;

	##Nom du fichier qui sera stocké dans le rep tmp du home serveur
	$date=date("jmY_G:i");

	## On supprime l'extension du fichier de l'utilisateur
	$userfilename= substr($userfilename,0,strlen($userfilename)-4);

	$resultfilename = "yourlist_".$date."_".$userfilename;

	$client = new SoapClient("http://$home_server/madtools/soap/madtools_userdata.wsdl",array('trace'=>1));
	$client->save_list($input_list,$madid_list,$species,$resultfilename);

	return $resultfilename;
}





function download_compare_results($super_result) {

	$date=date("jmY_G:i");
	$resultfile = "fish_chips_compare_".$date.".txt";

	$file_opened=fopen("./files/".$resultfile,"w");
	fputs($file_opened, "Dataset\tCluster number\tRatio\tP-value\tSpecies\tCluster size\tOverlap number\tOverlap genes\n") ;


	##Cherche les infos sur les datasets et les annotations dans la base
	$info_data = $info_dataset = $goterms = array () ;
	$resume=array(); ## equivalent au tableau $super_result, moins la colonne [5] avec le symbol et nom des gènes(avec un lien html)
	for($i = 0 ; $i < count($super_result) ; $i++)
	{
		$id = $super_result[$i][0] ;

		$info_data[$i] = info_datasets ($id) ;
		$info_dataset[$i]["directory"] = $info_data[$i]->directory;
		$info_dataset[$i]["GDS"] = $info_data[$i]->GPL;
	
		if (preg_match('/(-A-)|(-GPL)/', $info_dataset[$i]["directory"]) )
		{
			$set=$info_dataset[$i]["directory"];	
		}
		else
		{
			$set=$info_dataset[$i]["directory"]."-".$info_dataset[$i]["GDS"];
		}

		fputs($file_opened, $set."\t") ;

		$cluster_id = $super_result[$i][1] ;
		fputs($file_opened, $super_result[$i][1]."\t") ;
		
		$resultat_annotation = annotation($id,$cluster_id);
		$j=0;
		while($info_annotation = mysqli_fetch_object ($resultat_annotation))
		{
			$goterms[$i][$j] = $info_annotation->GO_term ;
			$j++;
		}

		fputs($file_opened, $super_result[$i][2]."\t") ; //ratio
		fputs($file_opened, $super_result[$i][3]."\t") ; //p-val
		fputs($file_opened, trim($super_result[$i][4])."\t"); //espece
		fputs($file_opened, $super_result[$i][6]."\t") ; //taille cluster input
		fputs($file_opened, $super_result[$i][8]."\t") ; //nb genes en commun
		fputs($file_opened, $super_result[$i][9]."\n") ; //Nom genes en commun separes par des /
	}

	//fputs($file_opened,$resume);
	fclose($file_opened);

	##Nom du fichier qui sera stocké dans le rep tmp du home serveur
	//$date=date("jmY_G:i");

	//$resultfile = "fish_chips_compare_".$date."_".$userfilename;
	// On passe ces variables au serveur contenant l'espace de résultats
	//$client = new SoapClient("http://$home_server/madtools/soap/madtools_userdata.wsdl", array('trace'=>1));
	//$client->write_userdata($resume,$info_dataset,$goterms,$resultfile);
 
	return $resultfile;
}


function createXmlResultCluster($dataset_id,$cluster){
	global $home_server;


	$date=date("jmY_G:i");
	
	$info_data = info_datasets ($dataset_id);

	$GSE=$info_data->directory;
	
	if (preg_match('/(-A-)|(-GPL)/', $GSE) )
	{
		$set=$GSE;	
	}
	else
	{
		$set=$GSE."-".$info_data->GPL;
	}
	
	
	$resultclusterfile = "fish_chips_".$set."_cluster".$cluster."_".$date.".txt";

	$file_opened=fopen("./files/".$resultclusterfile,"w");
	fputs($file_opened, "GO ID \tGO term\tP-value\n") ;

	$resultat_annotation = annotation ($dataset_id,$cluster);
	$i=0;
	while($info_annotation = mysqli_fetch_object ($resultat_annotation))
	{
		//$annotation[$i]['GO_ID'] = $info_annotation->GO_ID ;
		//$annotation[$i]['GO_term'] = $info_annotation->GO_term ;
		//$annotation[$i]['p_value'] = $info_annotation->p_value ;
		
		$goId=$info_annotation->GO_ID;
		$zeroNb=7-strlen($goId);
		for($counter=0 ; $counter < $zeroNb ; $counter++)
		{
			$goId="0".$goId;	
		}

		fputs($file_opened, $goId ."\t") ;
		fputs($file_opened, $info_annotation->GO_term ."\t") ;
		fputs($file_opened, $info_annotation->p_value ."\n") ;

		$i++;
	}  
	fclose($file_opened);
	
  	//$liste_madid = recupere_gene_cluster ($dataset_id,$cluster);
  
	## Envoi des parametres au serveur "home" pour l'enregistrement des résultats dans l'espace personnel
	//$client = new SoapClient("http://$home_server/madtools/soap/madtools_userdata.wsdl",array('trace'=>1));
	//$GSE=$info_data->directory;
	//$client->save_cluster($identifiant,$GSE,$dataset_id,$cluster,$info_data->species_GPL,$annotation,$liste_madid,"MADMUSCLE");

	return $resultclusterfile;
}


function convertClustFile($clustFile)
{
	$speReq="
		SELECT DISTINCT gene_selection.id, gene_selection.cluster_id
		FROM gene_selection, datasets
		WHERE (datasets.directory = 'GSE0' AND gene_selection.id = datasets.id)
	";

	$fh = fopen($clustFile, 'r') or die($php_errormsg);
	while (!feof($fh))
	{
		$ligne = fgets($fh, 4096);
		$ligne = rtrim ($ligne) ; //supprime retour chariot
		if(!empty($ligne))
		{
			$speReq.=" OR (";
		
			$tabLigne = explode("\t", $ligne);
			
			if(preg_match("/-GPL/", $tabLigne[0]))
			{
				$idsTabLigne = explode("-", $tabLigne[0]);
				//echo "<br>datasets.GSE = '$idsTabLigne[0]' AND datasets.GPL='$idsTabLigne[1]'";
				$speReq.="datasets.GSE = '$idsTabLigne[0]' AND datasets.GPL='$idsTabLigne[1]'";
			}
			elseif(preg_match("/-A-/", $tabLigne[0]))
			{
				$idsTabLigne = explode("-A-", $tabLigne[0]);
				//echo "<br>datasets.GSE = '$idsTabLigne[0]' AND datasets.GPL='A-$idsTabLigne[1]'";
				$speReq.="datasets.GSE = '$idsTabLigne[0]' AND datasets.GPL='A-$idsTabLigne[1]'";
			}
			else
			{
				//echo "<br>datasets.GSE = '$tabLigne[0]'";
				$speReq.="datasets.GSE = '$tabLigne[0]'";
			}
			
			$speReq.=" AND ";
		
			if($tabLigne[1]=="all")
			{
				//echo "<br>liste_cluster_correct.id = datasets.id";
				$speReq.="gene_selection.id = datasets.id";
			}
			else
			{
				$tabLigne[1]=preg_replace('/-*|_*| *|\.*/', '', $tabLigne[1]);
				$tabLigne[1]=str_replace("cluster", "", $tabLigne[1]);
				//echo "<br>liste_cluster_correct.id = datasets.id AND liste_cluster_correct.cluster_id =$tabLigne[1]";
				$speReq.="gene_selection.id = datasets.id AND gene_selection.cluster_id =$tabLigne[1]";
			}
			
			$speReq.=")";
		}
	}
	fclose($fh);
	$speReq.=";";
	
	//echo "<br><br><br>$speReq<br><br>";
	//die();
	
	return $speReq;
}
		






?>
