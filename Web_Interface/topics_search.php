<?php 
session_start ();
if( $_SESSION['login']!="YES" )
{	
	header("Location: index.php");
}

require_once("tool.html.php");
require_once("fonctions.php");
//require_once("islogged.php");
//require_once("config.php");
init_html();
?>
<body onload="window.defaultStatus='MADGENE';" >

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
		<div id="participation">
			<!--
			<h3><span>Topics</span></h3>
			-->
			<h3><blockquote>A web tool</blockquote></h3>
			<p class="p1">
			<strong>Dataset search engine according to topic:</strong><br>
   <br>
  <FORM ACTION='search_by_topics.php' METHOD=POST ENCTYPE='multipart/form-data'>


    <p>Select your species: <SELECT NAME='species' SIZE=1>
    <OPTION VALUE=all>all
<!--
    <OPTION VALUE="Homo sapiens">Homo sapiens
    <OPTION VALUE="Mus musculus">Mus musculus
    <OPTION VALUE="Rattus norvegicus">Rattus norvegicus
    <OPTION VALUE="Drosophila melanogaster">Drosophila melanogaster
    <OPTION VALUE="Bos taurus">Bos taurus
    <OPTION VALUE="Xenopus laevis">Xenopus laevis
-->
    <OPTION VALUE="Danio rerio">Danio rerio
    <OPTION VALUE="Dicentrarchus labrax">Dicentrarchus labrax
    <OPTION VALUE="Gadus morhua">Gadus morhua
    <OPTION VALUE="Gillichthys mirabilis">Gillichthys mirabilis
    <OPTION VALUE="Oncorhynchus mykiss">Oncorhynchus mykiss
    <OPTION VALUE="Salmo salar">Salmo salar
    <OPTION VALUE="Sparus aurata">Sparus aurata
<!--
    <OPTION VALUE="Macaca mulatta">Macaca mulatta
    <OPTION VALUE="Canis familiaris">Canis familiaris
	<OPTION VALUE="Canis lupus familiaris">Canis lupus familiaris
	<OPTION VALUE="Gallus gallus">Gallus gallus
	<OPTION VALUE="Sus scrofa">Sus scrofa
	<OPTION VALUE="Ovis aries">Ovis aries
	<OPTION VALUE="Caenorhabditis elegans">Caenorhabditis elegans
	<OPTION VALUE="Pan troglodytes">Pan troglodytes
	<OPTION VALUE="Meleagris gallopavo">Meleagris gallopavo
	<OPTION VALUE="Oncorhynchus mykiss">Oncorhynchus mykiss
	<OPTION VALUE="Fundulus heteroclitus">Fundulus heteroclitus
	<OPTION VALUE="Spermophilus parryii">Spermophilus parryii
	<OPTION VALUE="Coregonus clupeaformis">Coregonus clupeaformis
	<OPTION VALUE="Litopenaeus vannamei">Litopenaeus vannamei
-->
    </select></p>
    <br><br>Filtering datasets by keyword:
    <input type="text" name="key" size="40" maxlength="100" value=''>
    <br><br><br>


  <center><INPUT TYPE=SUBMIT VALUE='Search'></center>
			</p>

			<p class="blanc"></p>
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
	//menu($identifiant);
	menu();
	//phpMyVisites();
?>

</div>

<!-- These extra divs/spans may be used as catch-alls to add extra imagery. -->
<!-- Add a background image to each and use width and height to control sizing, place with absolute positioning -->
<div id="extraDiv1"><span></span></div><div id="extraDiv2"><span></span></div><div id="extraDiv3"><span></span></div>
<div id="extraDiv4"><span></span></div><div id="extraDiv5"><span></span></div><div id="extraDiv6"><span></span></div>

</body>
</html>
