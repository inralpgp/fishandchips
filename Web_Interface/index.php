<?php
session_start ();


$directory = './files';
$scannedDirectory = array_diff(scandir($directory), array('..', '.'));
foreach($scannedDirectory as $createdFile)
{
	$todayMonth = date("m");
	$todayDay = date("d");
	$lastModifMonth=date("m", filemtime("./files/".$createdFile));
	$lastModifDay=date("d", filemtime("./files/".$createdFile));
	
	if( ($lastModifMonth!=$todayMonth) || ($lastModifDay!=$todayDay) )
	{
		//echo"$createdFile<br>";
	
		unlink("./files/".$createdFile);
	}
}


if( $_SESSION['login']=="YES" )
{	
	header("Location: index2.php");
}
else
{
	session_unset();
	session_destroy();
	session_start ();
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
			<br><br>
			
				<font color='red'><strong>Please login before using the tool</strong></font>
				<br><br>
				<FORM ACTION='login.php' METHOD=POST ENCTYPE='multipart/form-data'>
				Password:</strong>
				<input type="password" name="password" size="20" value=''>
				<INPUT TYPE=SUBMIT VALUE='Login'>
				<br><br><br>			


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
