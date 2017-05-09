<HTML>


<script language="javascript" type="text/javascript">
function pop_it(the_form) {
   my_form = eval(the_form) ;

   window.open("./wait.php", "popup", "resizable=1, scrollbars=1, height=440,width=640");

	//window.open("./telecharger.php", "popup", "resizable=1, scrollbars=1, height=440,width=640");

   my_form.target = "popup";
   my_form.submit();
}
</script>



<?php
//ini_set('display_errors', 1);
ini_set("auto_detect_line_endings", true);
require_once("tool.html.php");
require_once("fonctions.php");

init_html();
fenetre_java ();

ob_start();
$aleatoire = rand (1, 999999) ;
$test=1;
?>



<body onload="window.defaultStatus='FishAndChips';" >

<div id="container">

<!--
	***** Introduction
-->

<?php  intro();
?>
<!--
	********************
-->


<!--
	***** Contenu page
-->
	<div id="supportingText">
	
	<!--
		***** Menus et liens gauches
	-->
	<?php 
		menu();
	?>
	
		<div id="compare">
			<h3><span>Fish transcriptome database</span></h3>
			<?php 			
			//if($_POST['texte'])
			if ($test=1)
			{
				//$textIds = htmlentities($_POST['texte']);
				//$textIds=explode("\n", $textIds);
				$textIds="ENSTRUG00000005230\nENSTNIG00000005626\nENSTRUG00000012449\nENSTNIG00000005626\nENSONIG00000004759\nENSONIG00000009302\nENSTNIG00000008533\nENSONIG00000004759\nENSONIG00000009133\nENSTRUG00000018676\nENSONIG00000005934\nENSTNIG00000005626\nENSDARG00000017105\nENSDARG00000019181\nENSORLG00000015714\nENSGACG00000020072\nENSTRUG00000005477\nENSXMAG00000003753\nENSONIG00000015932\nENSGACG00000019739\nENSONIG00000009133\nENSXMAG00000013564\nENSTNIG00000011730\nENSDARG00000027141\nENSGACG00000002643\nENSTNIG00000005626\nENSONIG00000006115\nENSONIG00000004823\nENSXMAG00000002121\nENSONIG00000004759\nENSONIG00000009730\nENSTNIG00000005626\nENSDARG00000089441\n";
				$textIds=explode("\n", $textIds);
				$temp_opened=fopen("./files/fichier$aleatoire.txt","w");
				foreach($textIds as $inputIds)
				{
					fputs($temp_opened, $inputIds."\n") ;
				}
				fclose($temp_opened);
			
			}
			
			//de <INPUT TYPE=FILE NAME='file'>
			elseif(is_uploaded_file($_FILES['file']['tmp_name']))
			{
				$userfilename=$_FILES['file']['name'];
				
				move_uploaded_file($_FILES['file']['tmp_name'],"./files/fichier$aleatoire.txt") ;
			}
			
			
			//if(is_uploaded_file($_FILES['clustList']['tmp_name']))
			//{
			//	move_uploaded_file($_FILES['clustList']['tmp_name'],"./files/clustList$aleatoire.txt") ;
			//	$clustFile="./files/clustList$aleatoire.txt";
			//}
			//else
			//{
				$clustFile="EMPTY";
			//}
			


			if(is_file("./files/fichier$aleatoire.txt"))
			{
				//$species = htmlentities($_POST['species']);
				$species="Danio rerio";
				//$type = htmlentities($_POST['type']);
				$type="Compare";
				//$option=htmlentities($_POST['compareoption']);
				$option="ortho";
				// ////////////
				// ANNOTATE //
				// ////////////
				if($type == 'Test your list')
				{
					echo "Species: $species <br>";
										
					//move_uploaded_file($_FILES['file']['tmp_name'],"./files/fichier$aleatoire.txt") ;
				
					$fh = fopen("./files/fichier$aleatoire.txt", 'r') or die($php_errormsg);
					
					?>
					<table>
					<tr>
						<th id="input">Input ID</th>
						<th id="valid">ENSEMBL ID (blast result)</th>
						<?php
							if($option=="ortho")
							{
								echo"<th id=\"orthologs\">Orthologs</th>";	
							}
						?>
						<th id="symbol">Symbol</th>
						<th id="name">Name</th>
					</tr>
					<?php 
					
					$symbForGominer=array();

					while (!feof($fh))
					{
						$ligne = fgets($fh, 4096);
						$ligne = rtrim ($ligne) ; //supprime retour chariot
						
						if(!empty($ligne))
						{
							//array_push($input_list,$ligne);
							//$debut=temps();
							//$madid = find_madid($ligne,$species) ;
							$madid = find_ensembl($ligne,$species) ;
							
							//$fin=temps();
							/*
							if($madid!=""){
								$valid=1;
								array_push($madid_list,$madid);
							}
							else{
								$valid=0;
								array_push($madid_list,'0');
							}
 							//$info = info_madid_humain($madid) ;
							*/
							if($madid=="")
							{
								$madid="-";
							}
							
							$info = get_info_ensembl($madid,$species) ; //On prend l'espece du fichier d'entre pour le resultat de "Test your list"
							?>
							<tr>
								<td><?php echo "$ligne"; ?> &nbsp;</td>
								<td><?php echo "$madid"; ?> &nbsp;</td>
								
								<?php
								if($option=="ortho")
								{
									echo"<td>";
									if($madid=="-")
									{
										echo"- <br>";
									}
									else
									{
										$resOrtho=get_orthologs($madid);
										while($orthoId = mysqli_fetch_object ($resOrtho))
										{
											if($orthoId->orthologs=="NA")
											{
												echo"- <br>";
											}
											else
											{
												echo"$orthoId->orthologs <br>";
											}
										}
									}
									echo"</td>";
								}
								 
								if($info!=NULL)
								{
									$symb=$info->gene_name;
									if($symb=="null")
									{
										$symb="-";
									}
									else
									{
										$symb=preg_replace("/ \(.*/", '', $symb);
									}
									
									//array_push($symbForGominer,$symb);
									
									$nameDetail=$info->gene_details;
									if($nameDetail=="null")
									{
										$nameDetail="-";
									}
								?>

									<td><?php echo "$symb"; ?> &nbsp;</td>
									<td><?php echo "$nameDetail"; ?> &nbsp;</td>
								<?php }
								else
								{?>
									<td>- &nbsp;</td>
									<td>- &nbsp;</td>
								<?php  }
								?>
								</tr><?php 
								
								flush();
    								ob_flush();
						}
					}?>
					</table><?php 
					
					/*
					$fileForGominer="gominer_list_$aleatoire.txt";
					$file_opened=fopen("./gominer/".$fileForGominer,"w");
					foreach($symbForGominer as $gom)
					{
						fputs($file_opened, "$gom\n") ;
					}
					fclose($file_opened);
					
					$button="View GO terms of \nthe input list";
					echo "<br>
					<center><form action=gominer_process.php method=post>
					<input type=hidden name=gominer_file value=$fileForGominer >
					<input type=hidden name=ori_file value=fichier$aleatoire >
					<input type=submit value='View GO terms&#10of the input list'>
					</form></center>
					";
					*/
					
									
					unlink("./files/fichier$aleatoire.txt") or die ("impossible d'effacer ./files/fichier$aleatoire.txt: $php_errormsg");

					?>
					
					<p><a href='analysis.php'><i>Back</i></a><?php 
				}
				
				
				
				// ///////////
				// COMPARE //
				// ///////////
				if($type == 'Compare')
				{
					$liste = array () ;
					$compteur = 0 ;
				
					//move_uploaded_file($_FILES['file']['tmp_name'],"./files/fichier$aleatoire.txt") ;
				
					$fh = fopen("./files/fichier$aleatoire.txt", 'r') or die($php_errormsg);
				
					while (!feof($fh))
					{
						$ligne = fgets($fh, 4096);
						$ligne = rtrim ($ligne) ; //supprime retour chariot
						if($ligne != "")
						{
							$madid = find_ensembl($ligne,$species) ;
							if(!empty($madid))
							{
								$liste[$compteur] = $madid ;
								$compteur++ ;
							}
						}
					}
					unlink("./files/fichier$aleatoire.txt") or die ("impossible d'effacer ./files/fichier$aleatoire.txt: $php_errormsg");

					//suite
					//echo "avant : <br>";
					//print_r(array_values ($liste));
					$liste = array_unique ($liste) ;


					################################################################################
					//////////  FONCTION COMPARE ////////////////////////////
					################################################################################
 					
 					$ak = count($liste) ;
					echo "There are <b>$ak</b> unique genes in your list.<br><br>";
 					
 					//$super_result = compare_clusters_simple ($liste) ;
 					
 					$super_result = compare_clusters_complex ($liste, $option, $clustFile, $ak) ;
 					
					//echo "<br>apr�s unique : <br>";
					//print_r(array_values ($liste));
 					
 					
					//print_r(array_values ($super_result));
					$taille = count($super_result) ;



					###################################################################################

					//$resultfile = send_compare_to_home_tmp($super_result,$userfilename);
					$resultfile = download_compare_results($super_result);				// VERIF A FAIRE !!!!!!!!!!!!!


					### ______________________________________________________________________ ####
						## Saving compare results 
					?>
						<!-- <form>
						
						<input type="button" VALUE="Save results" onClick='fenetreCent("save_result.php?resultfile=<?php echo"$resultfile"; ?>","fencent",480,120,"menubar=no,scrollbars=no,statusbar=no")'> -->
						
						<form action="save_result.php?file=<?php echo $resultfile; ?>" method="POST" name="formulaire">
						<input type="submit" value="Save results">

						</form>


					<!--- ______________________________________________________________________ -->

					<?php 
					##########################################

					if($taille > 0)
					{
						//tableau de r�sultat
						?>
						<table>
						<tr>
							<th id="dataset" title="Dataset Identifier in GEO">DataSet</th>
							<th id="cluster" title="Cluster number extracted by Fish And Chips in the dataset">Cluster</th>
							<th id="ratio" title="Ratio between the number of overlap genes (between your list and the selected cluster) and the number of genes in your list">Ratio</th>
							<th id="pvalue" title="p-value of the Exact Fisher Test">p-value</th>
							<th id="species" title="Species of the dataset">Species</th>
							<th id="overlap" title="Number and list of the overlap genes between your list and the cluster">Overlap genes</th>
							
							<th id="goterm" title="GO terms associated with the cluster">GO term</th>
						</tr><?php 
						//for($i = 0 ; $i < $taille ; $i++)
						if($taille>100){$max=100;}
						else {$max=$taille;}
						for($i = 0 ; $i < $max ; $i++)
						{
							$id = $super_result[$i][0] ;
							$cluster_id = $super_result[$i][1] ;
							$info_data = info_datasets ($id) ;
							
							$GSE=$info_data->directory;
	
							if (preg_match('/(-A-)|(-GPL)/', $GSE) )
							{
								$set=$GSE;	
							}
							else
							{
								$set=$GSE."-".$info_data->GPL;
							}
							
							
							?>
							<tr>
								<!--Dataset-->
								<td>
								<a href=./view.php?id=<?php echo"$id"; ?> target="_blank">
								<?php echo "$set"; ?></a><br><?php //if($info_data->GDS != "0"){echo "GDS$info_data->GDS";}
								echo "<br>Quality: $info_data->quality_estimate"?></td>
								<!--Cluster-->
								<td>
									<a href=./clusters.php?id=<?php echo"$id"; ?>&name=<?php echo"$info_data->directory"; ?>#<?php echo"$cluster_id"; ?> target="_blank"><?php echo"cluster".$cluster_id."</a><br>".$super_result[$i][6]." genes"; ?>
								<!-- ______________________________________________________________________ -->
								<!--  Saving cluster -->
									<!-- <form>
           							<input type="button" VALUE="save" style="width:40px" onClick='fenetreCent("cluster_save.php?id=<?php echo"$id"; ?>&cluster=<?php echo"$cluster_id"; ?>","fencent",480,120,"menubar=no,scrollbars=no,statusbar=no")'> -->
           							
           								<form action="save_cluster.php?id=<?php echo"$id"; ?>&cluster=<?php echo"$cluster_id"; ?>" method="POST" name="formulaire">
									<input type="submit" value="save">

									</form>
								<!-- ______________________________________________________________________ -->
								</td>
							<?php 
							$glou = $super_result[$i][2] ;
							echo "<td>";
							printf('%01.2f',$glou);		
							//printf("%.3e",$glou);
							echo " &nbsp;</td>" ;
							for ($j = 3 ; $j <= 4 ; $j++)
							{
								$glou = $super_result[$i][$j] ;
								if($j == "3" and $glou < "0.001")
								{
									echo "<td><b>";
									printf("%.3e",$glou);
									echo " &nbsp;</b></td>" ;
								}
								elseif($j == "3")
								{
									echo "<td>";
									printf("%.3e",$glou);
									echo " &nbsp;</td>" ;
								}
								else
								{echo "<td>$glou &nbsp;</td>" ;}
							}
							$species = $super_result[$i][4] ;
							$glou = $super_result[$i][5] ;
			
							$nb_gene_commun =  $super_result[$i][8] ;
							echo "
								<td><form name=\"form\" action=\"intersection.php\" method=\"post\">
			
								<input type=\"hidden\" name=\"list\" maxlength=\"32\" size=\"12\" value=\"$glou\" />
								<input type=\"hidden\" name=\"species\" maxlength=\"32\" size=\"12\" value=\"$species\" />
								<input type=\"button\" onclick=\"pop_it(form);\" value=\"list\" /></p>
								</form>$nb_gene_commun genes</td>
							";
							
		
							?>
							<td><?php //echo "$id $cluster_id<br>";
							$resultat_annotation = annotation($id,$cluster_id) ;
							while($info_annotation = mysqli_fetch_object ($resultat_annotation))
							{
								$nono="" ; 
								$nono = $info_annotation->GO_ID;
								
								$zeroNb=7-strlen($nono);
								for($counter=0 ; $counter < $zeroNb ; $counter++)
								{
									$nono="0".$nono;	
								}
								 
								$nono2 = "" ; 
								$nono2 = $info_annotation->GO_term ;
								echo "**<a href=javascript:fenCentre(\"http://www.ebi.ac.uk/QuickGO/GTerm?id=GO:$nono\",900,900)>$nono2</a>**<br>"; 
							}
							?>&nbsp;</td>
							</tr><?php 
						}///for 
						?>
						</table>
						<p><a href='analysis.php'><i>Back</i></a></p>
						<?php 
					}
					else
					{?>
						<p>No result</p>
						<p><a href='analysis.php'><i>Back</i></a></p>
						<p class="blanc"></p>
						<p class="blanc"></p><?php 
					}
				}// if compare
			}//if upload file
			else
			{
				echo "Error with file!";
				echo "<p><a href='analysis.php'><i>Back</i></a>";
			}
			?>
		</div>

			<!--
				***** Pied de page
			-->
			<?php  foot();
			?>
	</div>
		<!--
			********************
		-->

<!--
	***** Menus et liens gauches
-->
	

</div>

<!-- These extra divs/spans may be used as catch-alls to add extra imagery. -->
<!-- Add a background image to each and use width and height to control sizing, place with absolute positioning -->
<div id="extraDiv1"><span></span></div><div id="extraDiv2"><span></span></div><div id="extraDiv3"><span></span></div>
<div id="extraDiv4"><span></span></div><div id="extraDiv5"><span></span></div><div id="extraDiv6"><span></span></div>

</body>
</html>

