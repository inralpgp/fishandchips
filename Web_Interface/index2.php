<?php
session_start ();
if( $_SESSION['login']!="YES" )
{	
	header("Location: index.php");
}

require_once("tool.html.php");
init_html();
?>

<body onload="window.defaultStatus='FishAndChips';" >
<div id="container">

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
		
		<div id="participation">
			<h3><blockquote>A web tool</blockquote></h3>

<!--			<p class="rouge"><b> !!! We encounter a technical problem with one of our server. Therefore, some features don't work well. We try to solve the problem as quickly as possible. We apologize for the inconvenience.</b></p>-->

			<p class="p1">Fish and Chips database gathers all the public transcriptome data related to fish species in various physiological conditions.</p>
			
			<p class="p2">This database provides:
				<ul>
				<li><a href="analysis.php"><strong>Analysis tool</strong> </a> : Compare your gene list to Fish and Chips.
				</li>	
				<br>		
				<li><a href="datasets.php"><strong>Datasets</strong></a> : renormalized and validated sets of data with
				functional annotations of all gene lists. </li>
				</ul>
			</p>
			
			<p><strong>This is the version 2.5 of Fish and Chips, please help us to improve it by sending us your comments or notifying us of bugs (<a href="mailto:jerome.montfort@rennes.inra.fr">jerome.montfort@rennes.inra.fr</a>)</strong></p>
			<p class="p1">
			<br>This site is optimized for Mozilla Firefox. If you have display problems, please download <a href="http://www.mozilla.com/en-US/firefox" target="_blank"><img src="images/firefox.png"/></a>
			</p>

			<p class="blanc"></p>
			</span></p>
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
	menu();
?>	

</div>

<!-- These extra divs/spans may be used as catch-alls to add extra imagery. -->
<!-- Add a background image to each and use width and height to control sizing, place with absolute positioning -->
<div id="extraDiv1"><span></span></div><div id="extraDiv2"><span></span></div><div id="extraDiv3"><span></span></div>
<div id="extraDiv4"><span></span></div><div id="extraDiv5"><span></span></div><div id="extraDiv6"><span></span></div>
</body>
</html>
