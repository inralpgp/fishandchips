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
		<div id="datasets">
			<!--
			<h3><span>Fish transcriptome database</span></h3>
			-->
			<h3><blockquote>Datasets</blockquote></h3>
			<p><strong>This is the release 2.5 of Fish and Chip</strong></p>
			<p class="p1">	
			<?php 	listing();
				//fenetre_java();
				?>

			<p class="p1">
			<?php 	//listing_auto(); ?>
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
	//piwick();
?>	

</div>

<!-- These extra divs/spans may be used as catch-alls to add extra imagery. -->
<!-- Add a background image to each and use width and height to control sizing, place with absolute positioning -->
<div id="extraDiv1"><span></span></div><div id="extraDiv2"><span></span></div><div id="extraDiv3"><span></span></div>
<div id="extraDiv4"><span></span></div><div id="extraDiv5"><span></span></div><div id="extraDiv6"><span></span></div>

</body>
</html>

