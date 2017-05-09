<?php 
require_once("tool.html.php");
require_once("fonctions.php");
//require_once("islogged.php");
//require_once("config.php");

init_html();

?>
<body onload="window.defaultStatus='MADMUSCLE';" >

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
		<div id="datasets">
			<!--
			<h3><span>Muscle transcriptome database</span></h3>
			-->
			<h3><blockquote>Datasets</blockquote></h3>
			<p><strong>Results</strong></p>
			<p class="p1">
				<?php 
					resultat_search_new () ;
				?>
			</p>

			<p class="p2">
			</p>
			<p class="p3"></p>
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
