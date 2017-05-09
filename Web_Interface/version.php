<HTML>
<?php 
require_once("tool.html.php");
init_html();
?>

<body onload="window.defaultStatus='MADGENE';" >

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
		<div id="participation">
			<h3><span>Version</span></h3>
			<p class="p1">
				<ul>
		<li><b> Fish and Chips beta-version (November 2011)</b></li>
		Fish and Chips database with 19 public <em>Danio rerio</em> datasets from Gene Expression Omnibus<br><br>
		
		<li><b> Fish and Chips version 1.0 (July 2012)</b></li>
		Fish and Chips database with 68 datasets, over 5 fish species, from the AquaExcel Project, Gene Expression Omnibus and ArrayExpress<br><br>
		
		<li><b> Fish and Chips version 1.1 (July 2012)</b></li>
		Fish and Chips database with 317 datasets, over 5 fish species, from the AquaExcel Project, Gene Expression Omnibus and ArrayExpress<br>
		- Several new Features (acces protected by a password, automatic download of cluster's gene list,...) <br>
		- Query speed improved<br><br>
		
		<li><b> Fish and Chips version 1.2 (August 2012)</b></li>
		- New option in "Analysis tool" part <br>
		- Querying bugs fixed <br>
		- Missing GO terms for some datasets available<br><br>	
		
		<li><b> Fish and Chips version 2.0 (September 2012)</b></li>
		Fish and Chips database with 346 datasets, over 7 fish species, from the AquaExcel Project, Gene Expression Omnibus and ArrayExpress<br><br>
		
		<li><b> Fish and Chips version 2.1 (September 2012)</b></li>
		- Possibility to compare a gene list versus specific clusters in "Analysis tool"<br><br>
		
		<li><b> Fish and Chips version 2.2 (November 2012)</b></li>
		Fish and Chips database with 351 datasets, over 7 fish species, from the AquaExcel Project, Gene Expression Omnibus and ArrayExpress<br><br>
		
		<li><b> Fish and Chips version 2.3 (January 2013)</b></li>
		- Annotations updated and improved for <em>Sparus aurata</em><br><br>
		
		<li><b> Fish and Chips version 2.4 (February 2013)</b></li>
		Fish and Chips database with 353 datasets, over 7 fish species, from the AquaExcel Project, Gene Expression Omnibus and ArrayExpress<br>
		- Annotations updated and improved for all species<br><br>
		
		<li><b> Fish and Chips version 2.5 (April 2013)</b></li>
		Fish and Chips database with 354 datasets, over 7 fish species, from the AquaExcel Project, Gene Expression Omnibus and ArrayExpress<br>
		- Annotations updated for some private AQUAEXCEL datasets<br><br>
			
				</ul>
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
	menu();
?>	

</div>

<!-- These extra divs/spans may be used as catch-alls to add extra imagery. -->
<!-- Add a background image to each and use width and height to control sizing, place with absolute positioning -->
<div id="extraDiv1"><span></span></div><div id="extraDiv2"><span></span></div><div id="extraDiv3"><span></span></div>
<div id="extraDiv4"><span></span></div><div id="extraDiv5"><span></span></div><div id="extraDiv6"><span></span></div>

</body>
</html>

