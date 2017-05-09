<?php

function init_html(){
	?>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" >
	<head>
		<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
		<meta name="author" content="Yann Echasseriau" />
		<meta name="keywords" content="microarray, puces a ADN, poisson, fish, stress, annotation fonctionnelle, functional annotation" />
		<meta name="description" content="" />
		<meta name="robots" content="all" />
		<link rel="SHORTCUT ICON" href="favicon.ico">
		
		<title>Fish and Chips : fish transcriptome database</title>

		<!-- Function to display to help window -->
		<script language="Javascript">
		function fenCentre(url,largeur,hauteur)
		{
			var Dessus=(screen.height/2)-(hauteur/2);
			var Gauche=(screen.width/2)-(largeur/2);
			var features= 'height='+hauteur+',width='+largeur+',top='+Dessus +',left='+Gauche+",scrollbars=yes, resizable=yes";
			thewin=window.open(url,'',features);
		}
		</script>

		<link rel="stylesheet" type="text/css" href="style.css" media="screen, projection" />
	</head>
	<?php 
}

function intro(){?>
	<div id="intro">
		<div id="pageHeader">
			<h1>Fish and Chips</h1>
			<h2>Fish transcriptome database</h2>
		</div>

		<div id="quickSummary">
			<p class="p1"></p>
			<p class="p2"><span></span></p>
		</div>
	</div>
<?php 
}


function foot(){?>

		<div id="logos">
			<p class="p1">
			<!-- <a href="http://www.sigenae.org/" target="_blank"><img src="images/logo_sigenae.jpg" width="30%" heigth="30%"/></a> -->
			<a href="http://www.aquaexcel.eu/" target="_blank"><img src="images/logo_aquaexcel.png" width="30%" heigth="30%"/></a>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="http://www.international.inra.fr/" target="_blank"><img src="images/logo_inra.png" width="20%" heigth="20%"/></a>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="http://www.iats.csic.es/" target="_blank"><img src="images/logo_iats.gif" width="15%" heigth="15%"/></a>
			</p>
		</div>

		<div id="footer">
			<div id="labelFoot"><a href="http://www4.rennes.inra.fr/lpgp_eng/" target="_blank">All rights reserved &copy; 2012, INRA LPGP</a></div>
		</div>
<?php 
}

function menu(){

?>
	<div id="linkList">
		<div id="linkList2">

			<div id="lselect">

				<h3 class="select">Menu:</h3>
				<ul>				
					<li><a href="index.php" >HOME</a></li>
					<li><a href="analysis.php" >Analysis Tool</a> </li>
					<li><a href="datasets.php" >DataSets</a> </li>
					<li><a href="topics_search.php" >Search</a> </li>
				</ul>
			</div>
			<br>

			<div id="lresources">
				<h3 class="resources">Resources:</h3>
				<ul>
					<li><a href="faq.php" ><acronym title="Frequented Asked Questions">FAQ</acronym> </a></li>		<!-- A VOIR -->
					<li><a href="version.php" >Version</a></li>			<!-- A VOIR -->
					<li><a href="credits.php" >Credits</a>&nbsp;</li>		<!-- A VOIR -->
				</ul>
			</div>
		</div>
	</div>
<?php }

?>
