<?php
session_start ();
if( $_SESSION['login']!="YES" )
{	
	header("Location: index.php");
}

require_once("tool.html.php");
//require_once("islogged.php");
//require_once("config.php");
init_html();
?>

<body onload="window.defaultStatus='FishAndChips';" >

<div id="container">

<!--
	***** Introduction
-->

<?php
/* 
$LOGGED = user_islogged();
if(!$LOGGED)
{	
	header("Location: $home_url");
}
else
{
	$identifiant=htmlentities($_COOKIE['user_name']);
	$classe=get_classe($identifiant);
}
*/
intro();
?>
<!--
	********************
-->


<!--
	***** Contenu page
-->
	<div id="supportingText">
		<div id="compare">
			<!--
			<h3><span>Analysis tool</span></h3>
			-->
			<h3><blockquote>Compare profiles</blockquote></h3>
			<h2>Compare your profile with Fish and Chips profiles</h2>
			<p>This tool looks for significant overlap between the user's list of genes and the annotated Fish and Chips lists. </p>
			
			<br>
			
 			<form action="compare.php"  method="post" enctype="multipart/form-data"> 
<!-- 			<form action="test_SOAP.php"  method="post" enctype="multipart/form-data"> -->
			<p>	<strong>Input File:</strong> <input type=FILE name='file'> (text file with one ID per line) </p>
			
				<strong>Or paste your list:</strong>         <tab>(one ID per line)
				
				<br><textarea name='texte' rows=5 cols=30></textarea>
				
			<p>
				<center><strong><font color='red'>Warning! For statistical calculus reasons, your list must include more than 30 IDs!</font></strong></center>
			</p>
			
			<p>
				<em>Supported ID types include gene symbols, GenBank accession numbers, Ensembl transcript and gene IDs.</em>
			</p>
			<br>
			<p>	
				<strong>Select your input species: </strong>  <!-- Surement à modifier -->
				<select name='species' size=1>
			<!--
				<option value="Hs">Homo sapiens
				<option value="Mm">Mus musculus
				<option value="Rn">Rattus norvegicus
				<option value="Dm">Drosophila melanogaster
				<option value="Cel">Caenorhabditis elegans
				<option value="Cfa">Canis familiaris
				<option value="Gga">Gallus gallus
			-->
				<option value="Danio_rerio">Danio rerio
				<option value="Dicentrarchus_labrax">Dicentrarchus labrax
				<option value="Gadus_morhua">Gadus morhua
				<option value="Gillichthys_mirabilis">Gillichthys mirabilis
				<option value="Oncorhynchus_mykiss">Oncorhynchus mykiss
				<option value="Salmo_salar">Salmo salar
				<option value="Sparus_aurata">Sparus aurata
				</select>
			</p>
			<br>
			<p>
				<strong>Select your comparison type: </strong>
				<input type= "radio" name="compareoption" value="direct" checked>Direct matching
				<input type= "radio" name="compareoption" value="ortho">Comparison including orthologs
			</p>
			<br>
			<p>
				<!--
				The comparison is performed versus all clusters of the datasets of Fish And Chips. 
				<br>
				But if you want to perform it only versus some specific clusters, just put your clusters list below.
				Else, let this field empty.
				<br>
				-->
				
				<br> 
				<em>For a comparison versus some specific clusters, put your clusters list below. Or let this field empty for a comparison versus all clusters of the datasets of Fish And Chips.</em>
				<br> 
				<br> 
				<strong>Cluster list: </strong> 
				<input type=FILE name='clustList'> 
				<br>(text file with one dataset ID and one cluster ID, separated by a tab, per line) 
			</p>
			<br>
			<br>			
			<p>
				<center>
				<input type="submit" value='Test your list' name='type'>
				<input type="submit" value='Compare' name='type'>
				<input type="reset" value='Reset'>
				</center>
			</p>
			<p class="blanc"></p>
			<!-- <p >This tool is powered by <a href="http://cardioserve.nantes.inserm.fr/mad/madgene/">Madgene</a>.</p> -->
			</form>
		</div>

			<!--
				***** Pied de page
			-->
			<?php foot();
			?>
	</div>
		<!--
			********************
		-->

<!--
	***** Menus et liens gauches
-->
<?php
	//menu($identifiant);
	menu();
	//phpMyVisites();
	//piwick();
?>	

</div>

<!-- These extra divs/spans may be used as catch-alls to add extra imagery. -->
<!-- Add a background image to each and use width and height to control sizing, place with absolute positioning -->
<div id="extraDiv1"><span></span></div><div id="extraDiv2"><span></span></div><div id="extraDiv3"><span></span></div>
<div id="extraDiv4"><span></span></div><div id="extraDiv5"><span></span></div><div id="extraDiv6"><span></span></div>

</body>
</html>

