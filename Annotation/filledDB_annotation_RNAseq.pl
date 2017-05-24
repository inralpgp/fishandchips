#!/usr/bin/perl -w
# Copyright {2017} INRA (Institut National de Recherche Agronomique - FRANCE) 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#AUTHOR : Yann Echasseriau, Ambre-Aurore Josselin

use DBI;

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $species=$ARGV[0];


my %species_conversion=
(
	"Oncorhynchus mykiss"=>"Omy",
	"Oryzias latipes"=>"Ola",
	"Salmo salar"=>"Ssa",
	"Gadus morhua"=>"Gmr"
);

my $species2=$species;
$species2=~s/ /_/;
print "species 2 : ".$species2."\n";

$dbh = DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);
$sth = $dbh->prepare("INSERT INTO annotations_".$species2."(seq_id, seq_length, species, type, clone_id, end, contig_id) VALUES (?, ?, ?, ?, ?, ?, ?);");
$sth1 = $dbh->prepare("INSERT INTO Annotation_all_sequences(seq_id, seq_length, species, type, contig_id) VALUES (?, ?, ?, ?, ?);");


opendir (RESDIR,"./Species_to_annotate/$species");
my @files_list= grep {$_=~m/$species2/ and $_=~m/mRNA\.fasta/} readdir RESDIR;
closedir RESDIR;

print  "liste fichier : \n".join("\n", @files_list)."\n";

foreach my $file (@files_list){
	chomp $file;
	
	open (SEQFILE, ">./Blast/First_blast/Fasta_for_blast/".$file);
	
	print "\nreading ".$file." ...\n";
	
	open (FILE,"./Species_to_annotate/".$species."/".$file);
	@data=<FILE>;
	close FILE;
	
	$id_exps=$file;
	$id_exps=~s/.+\_S_//;
	$id_exps=~s/_E_.+\.fasta//;


	my $transcript_id="null";
	my $gene_id="null";
	my $contig_id= "null";
	my $len="0";

	foreach $line (@data)
	{
		if ($line=~m/^>/){
			chomp $line;
			$line=~s/>//;
			
			if($line=~m/.+_i.+/){
				$transcript_id=$line;
				$transcript_id=~s/_i.+ len=.+//;
				$transcript_id=$id_exps."_".$transcript_id;
				$len = $line;
				$len =~s/.+ len=//;
				$len =~s/ path=.+//;
				print $transcript_id."\t".$len."\t".$species."\t"."mRNA"."\t"."null"."\t"."0"."\t".$contig_id."\n";
				$sth->execute($transcript_id, $len, $species, "mRNA", "null", "0", $contig_id);
				$sth1->execute($transcript_id, $len, $species, "mRNA", "null");
				print SEQFILE ">".$transcript_id."\n";
			}
			else{
				$gene_id=$line;
				$gene_id=~s/ len=.+//;
				$gene_id=$id_exps."_".$gene_id;
				$len = $line;
				$len =~s/.+ len=//;
				$len =~s/ path=.+//;
				print $gene_id."\t".$len."\t".$species."\t"."mRNA"."\t"."null"."\t"."0"."\t".$contig_id."\n";
				$sth->execute($gene_id, $len, $species, "mRNA", "null", "0", $contig_id);
				$sth1->execute($gene_id, $len, $species, "mRNA", "null");
				print SEQFILE ">".$gene_id."\n";
		
			}
			
			
			
			
		}
		else {
			print SEQFILE $line;
		}
	}
}

close SEQFILE;

$sth -> finish;
$sth1 -> finish;
$dbh -> disconnect;

exit;









