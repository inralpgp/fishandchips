<?php 
require_once("tool.html.php");
require_once("fonctions.php");

init_html();

$id = htmlentities($_GET['id']);
$info = info_datasets ($id);


$set=$info->directory;
$set=preg_replace('/(-A-.+)|(-GPL.+)/', '',$set);

?>

<body onload="window.defaultStatus='FishAndChips';" >

<div id="container">

<!--
	***** Introduction
-->

<?php  
intro();
?>
<!--
	********************
-->


<!--
	***** Contenu page
-->

	<div id="supportingText">
		<div>
			<?php  
			echo "<h3><b><font color='#044F90'>$info->directory";
			if ( !(preg_match("/GPL/", $info->directory)) && (preg_match("/GSE/", $info->directory)) )
			{
				echo "-$info->GPL";
			}
			echo "</font></b></h3>";
			?>

		</div>
		<div >
			<p class="p1">	
			<?php 		
				if (is_file("$data/$set/$info->directory/cluster/cluster_1.txt"))
				{   
					//echo"<br>**$data/$set/$info->directory/cluster/cluster_1.txt**<br>";
				?>
					<form action="clusters.php?id=<?php echo "$id"; ?>&name=<?php echo "$info->directory"; ?>" method="post">
					<input type="submit" value='Selected clusters' >
					</form>
					<?php 
				}
				?>

				<h2><p align="right">Quality estimation:
				<?php 
					
					if($info->quality_estimate != "" and $info->quality_estimate != "10")
					{
						/*
						if(is_numeric($note))
						{
							$vrai_note = $note ;
						}
						else
						{*/
							$vrai_note = $info->quality_estimate;
						//}
						echo "$vrai_note" ;
					}
					else
					{
						echo "not estimate";
					}
					$ronron_quality = $info->quality_auto ;
				?>
				/4<br><img src=./images/code_quality/Image<?php echo"$vrai_note"; ?>.png><br>
				<?php  if($ronron_quality != 0 and $ronron_quality != "NULL")
				{
					echo sprintf("%.3e",$ronron_quality)."</b></p></h2>";
				}
				?>
				<br>
				<h2>Title:</h2>
				<?php 
				if($info->title != "")
				{
					echo "$info->title";
				}
				else
				{
					echo "no title";
				}
				?>
				<br>
				<h2>Details:</h2>
				<?php 
				//DETAILS
				if($info->summary != "")
				{
					echo "$info->summary <br><br>";
				}
				else
				{
					echo "no summary <br><br>";
				}?>
				<h2>Design:</h2>
				<?php 
				if($info->design != "")
				{
					echo "$info->design";
				}
				else
				{
					echo "design not available";
				}
				?>
				<br><br>
				<?php 
				//PUBMED
				if($info->pubmed_id != "" and $info->pubmed_id != "0")
				{
					echo "<b>Pubmed:</b> <a HREF=http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=pubmed&term=$info->pubmed_id target=_blank>$info->pubmed_id</a><br>";
				}
				//ESPECE
				if($info->sample_species != "")
				{
					echo "<b>Sample species:</b> $info->sample_species<br>";
				}
				//NB echantilons
				if($info->sample_number != "" and $info->sample_number != "0")
				{
					echo "<b>Sample number:</b> $info->sample_number<br>";
				}


				//source
				if($info->source != "")
				{
					if (preg_match("/GEO/i", $info->source))
					{
						echo "<b>Source:</b> GEO <a HREF=http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?acc=GSE$info->GSE target=_blank>GSE$info->GSE</a><br>";
						if($info->GDS != "0")
						{
							echo "<b>GEO Datasets:</b> <a HREF=http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?acc=GDS$info->GDS target=_blank>GDS$info->GDS</a><br>";
						}
					}
					else
					{
						if(preg_match("/http/i", $info->source))
						{
						echo "<b>Source:</b> <a HREF=$info->source target=_blank>link</a><br>";
						}
						else
						{
						echo "<b>Source:</b> $info->source<br>";
						}
					}
					
				}
				//platform
				if($info->GPL != "0")
				{
					if($info->source == "GEO")
					{
						echo "<br><b>Platform:</b><br>GEO: <a HREF=http://www.ncbi.nlm.nih.gov/projects/geo/query/acc.cgi?acc=GPL$info->GPL target=_blank>GPL$info->GPL</a><br>";
						echo "Title: $info->title_GPL <br> Technology: $info->technology_GPL <br> Species: $info->species_GPL <br> Channel count: $info->channel_count<br>Probe number: $info->row_count<br>";
					}
 					else
 					{
 						echo "<b>Platform:</b> $info->platform<br><b>Probe number:</b> $info->row_count<br>";
 					}
				}
				?>
				</p>
				</div>


<!--	A REMETTRE QUAND ON AURA TOUTES LES RAW DATA CLUSTERISEES !!!!!!!!!!!!!!!
				
				<div id="view1">
				<p class="p1">
				<h3><blockquote>Raw data</blockquote></h3>
				<?php 
				if (is_file("$data/$set/$info->directory/$info->directory.txt"))
				{
					echo "<H4>Original data <FONT SIZE=2> <a href=telecharger.php?fichier=$info->directory.txt&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				if (is_file("$data/$set/$info->directory/$info->directory.mad"))
				{
					echo "<H4>Original data with gene and sample information <FONT SIZE=2> <a href=telecharger.php?fichier=$info->directory.mad&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				if (is_file("$data/$set/$info->directory/$info->directory.cdt"))
				{
					echo "<H4>Data treeview file (.cdt) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.cdt>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.cdt&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				if (is_file("$data/$set/$info->directory/$info->directory.atr"))
				{
					echo "<H4>Array treeview file (.atr) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.atr>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.atr&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				if (is_file("$data/$set/$info->directory/$info->directory.gtr"))
				{
					echo "<H4>Gene treeview file (.gtr) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.gtr>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.gtr&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
// 				if (is_file("$data/$info->directory/pdf/raw.pdf"))
// 				{
// 					echo "<H4>Scatter plot (sample vs median sample) <FONT SIZE=2><a href=$data/$info->directory/pdf/raw.pdf>(view)</a>  /  <a href=telecharger.php?fichier=raw.pdf&chemin=$data/$info->directory/pdf/>(download)</a></FONT></H4>";
// 				}
				if (is_file("$data/$set/$info->directory/$info->directory.png"))
				{					
					echo "<img class=\"result\" src=\"$data/$set/$info->directory/$info->directory.png\" />";
					echo "<a href=telecharger.php?fichier=$info->directory.png&chemin=$data/$set/$info->directory/>Download picture</a>";
				}
				//width=\"50%\" height=\"50%\"
				?>
				</p>
				</div>
-->				
				<div id="view2">
				<p class="p1">
				<h3><blockquote>Normalized data</blockquote></h3>
				<!--
				<h3><span>Normalized data (lowess):</span></h3>
				-->
				<?php 
				if (is_file("$data/$set/$info->directory/$info->directory.data_processing.txt"))
				{
					echo "
					<h2>Data processing: </h2>
					<iframe src=$data/$set/$info->directory/$info->directory.data_processing.txt SCROLLING=no WIDTH=100% frameborder=0 marginwidth=0 vspace=0>data processing</iframe>
				";
				}
				
				if (is_file("$data/$set/$info->directory/$info->directory.lowess.knn.txt"))
				{
					echo "<H4>Normalized data <FONT SIZE=2> <a href=telecharger.php?fichier=$info->directory.lowess.knn.txt&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				elseif (is_file("$data/$set/$info->directory/$info->directory.norm.knn.txt"))
				{
					echo "<H4>Normalized data <FONT SIZE=2> <a href=telecharger.php?fichier=$info->directory.norm.knn.txt&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				
				if (is_file("$data/$set/$info->directory/$info->directory.lowess.knn.cdt"))
				{
					echo "<H4>Data treeview file (.cdt) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.lowess.knn.cdt>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.lowess.knn.cdt&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				elseif (is_file("$data/$set/$info->directory/$info->directory.norm.knn.cdt"))
				{
					echo "<H4>Data treeview file (.cdt) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.norm.knn.cdt>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.norm.knn.cdt&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				
				if (is_file("$data/$set/$info->directory/$info->directory.lowess.knn.atr"))
				{
					echo "<H4>Array treeview file (.atr) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.lowess.knn.atr>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.lowess.knn.atr&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				elseif (is_file("$data/$set/$info->directory/$info->directory.norm.knn.atr"))
				{
					echo "<H4>Array treeview file (.atr) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.norm.knn.atr>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.norm.knn.atr&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				
				if (is_file("$data/$set/$info->directory/$info->directory.lowess.knn.gtr"))
				{
					echo "<H4>Gene treeview file (.gtr) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.lowess.knn.gtr>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.lowess.knn.gtr&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				elseif (is_file("$data/$set/$info->directory/$info->directory.norm.knn.gtr"))
				{
					echo "<H4>Gene treeview file (.gtr) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.norm.knn.gtr>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.norm.knn.gtr&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				
// 				if (is_file("$data/$info->directory/pdf/lowess.pdf"))
// 				{
// 					echo "<H4>Scatter plot (sample vs median sample) <FONT SIZE=2><a href=$data/$info->directory/pdf/lowess.pdf>(view)</a>  /  <a href=telecharger.php?fichier=lowess.pdf&chemin=$data/$info->directory/pdf/>(download)</a></FONT></H4>";
// 				}
// 				if (is_file("$data/$info->directory/pdf/lowess_vs_raw.pdf"))
// 				{
// 					echo "<H4>Scatter plot (sample before lowess vs sample after) <FONT SIZE=2><a href=$data/$info->directory/pdf/lowess_vs_raw.pdf>(view)</a>  /  <a href=telecharger.php?fichier=lowess_vs_raw.pdf&chemin=$data/$info->directory/pdf/>(download)</a></FONT></H4>";
// 				}
				if (is_file("$data/$set/$info->directory/$info->directory.lowess.knn.png"))
				{
					echo"<IMG class=\"result\" SRC=$data/$set/$info->directory/$info->directory.lowess.knn.png >";
					echo"<a href=telecharger.php?fichier=$info->directory.lowess.knn.png&chemin=$data/$set/$info->directory/>Download picture</a>";
				}
				elseif (is_file("$data/$set/$info->directory/$info->directory.norm.knn.png"))
				{
					echo"<IMG class=\"result\" SRC=$data/$set/$info->directory/$info->directory.norm.knn.png >";
					echo"<br><center><a href=telecharger.php?fichier=$info->directory.norm.knn.png&chemin=$data/$set/$info->directory/>Download picture</a></center>";
				}?>
				</p>
				
				<div id="view3">
				<p class="p1">	
				<h3><blockquote>Analyzed data</blockquote></h3>
				<!--		
				<h3><span>Analyzed data:</span></h3>
				-->
				<?php 
				if (is_file("$data/$set/$info->directory/$info->directory.analyzed.txt"))
				{
					echo "<H4>Modified data <FONT SIZE=2> <a href=telecharger.php?fichier=$info->directory.analyzed.txt&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				if (is_file("$data/$set/$info->directory/$info->directory.analyzed.cdt"))
				{
					echo "<H4>Data treeview file (.cdt) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.analyzed.cdt>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.analyzed.cdt&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				if (is_file("$data/$set/$info->directory/$info->directory.analyzed.atr"))
				{
					echo "<H4>Array treeview file (.atr) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.analyzed.atr>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.analyzed.atr&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				if (is_file("$data/$set/$info->directory/$info->directory.analyzed.gtr"))
				{
					echo "<H4>Gene treeview file (.gtr) <FONT SIZE=2><a href=$data/$set/$info->directory/$info->directory.analyzed.gtr>(view)</a>  /  <a href=telecharger.php?fichier=$info->directory.analyzed.gtr&chemin=$data/$set/$info->directory/>(download)</a></FONT></H4>";
				}
				if (is_file("$data/$set/$info->directory/$info->directory.analyzed.png"))
				{
					echo"<IMG class=\"result\" SRC=$data/$set/$info->directory/$info->directory.analyzed.png>";	// !!!! peut etre à modifier ( $info->directory.analyzed.fix.png )
					echo"<br><center><a href=telecharger.php?fichier=$info->directory.analyzed.png&chemin=$data/$set/$info->directory/>Download picture</a></center>";
				}
				?>
				</p><br><br>
			<p class="p1">
			<br><br>This site is optimized for Mozilla Firefox. If you have display problems, please download <a href="http://www.mozilla.com/en-US/firefox" target="_blank"><img src="images/firefox.png"/></a>.
			</p>
				</div>
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
<?php 
	menu();
?>	

</div>

<!-- These extra divs/spans may be used as catch-alls to add extra imagery. -->
<!-- Add a background image to each and use width and height to control sizing, place with absolute positioning -->
<div id="extraDiv1"><span></span></div><div id="extraDiv2"><span></span></div><div id="extraDiv3"><span></span></div>
<div id="extraDiv4"><span></span></div><div id="extraDiv5"><span></span></div><div id="extraDiv6"><span></span></div>

</body>
</html>

