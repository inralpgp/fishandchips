<HTML>
<?php 
require_once("tool.html.php");
require_once("fonctions.php");

init_html();

$id=htmlentities($_GET['id']);
	$cluster_id=htmlentities($_POST['cluster_id']);
	$nameGSE=htmlentities($_POST['name']);
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

		<div >
			<h3><span>Cluster <?php echo "$cluster_id"; ?></span></h3>
			<p class="p1">	
			<a href="clusters.php?id=<?php echo"$id"; ?>&name=<?php echo"$nameGSE";?>#<?php echo"$cluster_id"; ?>"><i>Back</i></a>
			<?php 	
				gene_list($id,$cluster_id);
			?>
			</p>

			<p class="p2">
				<a href="clusters.php?id=<?php echo"$id"; ?>&name=<?php echo"$nameGSE"; ?>#<?php echo"$cluster_id"; ?>"><i>Back</i></a>
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

</div>

<!-- These extra divs/spans may be used as catch-alls to add extra imagery. -->
<!-- Add a background image to each and use width and height to control sizing, place with absolute positioning -->
<div id="extraDiv1"><span></span></div><div id="extraDiv2"><span></span></div><div id="extraDiv3"><span></span></div>
<div id="extraDiv4"><span></span></div><div id="extraDiv5"><span></span></div><div id="extraDiv6"><span></span></div>

</body>
</html>

