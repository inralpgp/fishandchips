<HTML>
<?php
require_once("tool.html.php");
require_once("fonctions.php");
init_html();

$id=htmlentities($_GET['id']);
$name2=htmlentities($_GET['name']);

$info = info_datasets ($id);

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
			<h3><b><font color='#044F90'>
			<?php echo $name2;
			if ( !(preg_match("/GPL/", $name2)) && (preg_match("/GSE/", $name2)) )
			{
				echo "-$info->GPL";
			}?>
			</font></b></h3>

			<p class="p1">	
			<?php 	
				cluster($id,$name2);
			?>
			</p>

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

