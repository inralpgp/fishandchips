<?php
session_start();

if ($_POST['password'] == "aquaexceluser") 
{
	$_SESSION['login'] = "YES";
}
else
{
	$_SESSION['login'] = "Wrong password !";
}

header("Location: index2.php");


?>
