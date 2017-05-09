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
			<h3><span>Topics</span></h3>
			<p class="p1">
				<ul>
          <li><b> What is the method of normalisation used in Fish and Chips?</b></li>
          LOWESS:<br>
          Linear bias and non-linear bias (saturation, background or print-tip effect) are often observed in micro-array datasets.
          Such bias were corrected by normalizing all datasets with a LOWESS (Locally WEighted Scatter plot Smoothing) procedure [1] implemented in the statistical software package R [2].
          We specifically use a channel by channel procedure [3], each array being individually normalized to the median profile of all arrays of the considered dataset.
          <br><br>
          [1] <a href="http://www.pubmedcentral.nih.gov/articlerender.fcgi?tool=pubmed&pubmedid=11842121" target="_blank">
          Yang YH, Dudoit S, Luu P, Lin DM, Peng V, Ngai J, Speed TP:</a> Normalization for cDNA microarray data: a robust composite method addressing single and multiple slide systematic variation.
          Nucleic Acids Res 2002, 30:e15.
          <br><br>
          [2] <a href="http://www.r-project.org/" target="_blank">Ihaka R, Gentleman R:</a>
           A language for data analysis and graphics. J Comput Graph Statist 1996, 5:299-314.
          <br><br>
          [3] <a href="http://www.pubmedcentral.nih.gov/articlerender.fcgi?tool=pubmed&pubmedid=12225587" target="_blank">
          Workman C, Jensen LJ, Jarmer H, Berka R, Gautier L, Nielser HB, Saxild HH, Nielsen C, Brunak S, Knudsen S:</a> A new non-linear normalization method for reducing variability in DNA microarray
          experiments. Genome Biol 2002, 3(9):research0048.
				  <br><br>
				  <li><b> What is the cluster analysis used in Fish and Chips?</b></li>
				  We used Hierarchical clustering methods described in <a href="http://www.pnas.org/cgi/content/full/95/25/14863" target="_blank">Eisen et al. (1998) PNAS 95:14863.</a><br>
				  We ajusted data (log transform and median center genes) before hierarchical clustering (uncentered correlation, average linkage).<br>
				  <a href="http://rana.lbl.gov/EisenSoftware.htm" target="_blank">Download Cluster (Eisen)</a><br>
				  <br>
					<li><b> How to read cluster files (.cdt, .gtr, .atr)?</b></li>
					You must use Treeview:<br>Graphically browse results of clustering and other analyses from Cluster.<br>Supports tree-based and image based browsing of hierarchical trees.<br>
          <a href="http://jtreeview.sourceforge.net/" target="_blank">Download JavaTreeview</a><br>
          <a href="http://rana.lbl.gov/EisenSoftware.htm" target="_blank">Download Treeview (Eisen)</a><br><br>
          <b>Note for french users:</b><br>
          If your decimal symbol for numbers is coma, you must change in point to read Fish and Chips cluster files (Control Panel, Regional Options, Numbers, Decimal symbol).
          <br><br>
          <li><b> What is the method used to annotate gene clusters?</b></li>
          We used a statistical approache (Fisher's exact test) on <a href="http://www.geneontology.org/" target="_blank">gene ontology (GO)</a> annotations to determine statistically significant terms in gene clusters.<br>
          GO tools used in Fish and Chips:<br>
          - <a href="http://discover.nci.nih.gov/gominer/" target="_blank">GoMiner</a><br>
          - <a href="http://niaid.abcc.ncifcrf.gov/ease/" target="_blank">EASE</a><br>
          <br>
				</ul>
			</p>

			<p class="blanc"></p><p class="blanc"></p>
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

