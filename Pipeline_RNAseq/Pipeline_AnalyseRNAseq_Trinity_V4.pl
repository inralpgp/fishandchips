#!/usr/bin/perl -w

# Launcher pipeline Trinity
# my $downDir="../WorkingDirectoryInsertionProcess";
# my $dataset_list="datasets.txt";


###############################################################################################
#									MAIN
###############################################################################################

my $self = {};
bless $self;
my @list = () ;
my @Mylist=();
my $dir=$ARGV[1];
my $dataset_list=$ARGV[0];
$self->{previousSrp}="";


open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{
	if ($_ eq "" || $_ =~ m/^#/){											### ne prends pas en compte les lignes vides
		print " NE SERA PAS TRAITER !!!\n";
		print $_."\n";
		next;
	}
	else{
		print " ON VA ANALYSER CES DATAS  !!\n";
		chomp;
		print $_."\n";

		$_ =~ /([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*).*/ ;

		#$0 : path
		#$1 : GSE
		#$2 : GPL
		#$3 : Directory (GSE-GPL, file)
		#$4 : Title
		#$5 : Summary
		#$6 : Design
		#$7 : PubMed ID
		#$8 : GPL row count
		#$9 : channel count
		#$10 : Sample number
		#$11 : Sample species

		#print $0."***\n".$1."\n".$2."\n".$3."\n".$4."\n".$5."\n".$6."\n".$7."\n".$8."\n".$9."\n".$10."****\n".$11."***\n\n\n";

		my $dataset_number = $1 ;		
		my $gpl_number=$2;
		my $directory=$3;
		my $title=$4;
		my $summary=$5;
		my $design=$6;
		my $pubmed_id=$7;
		my $row_count=$8;
		my $channel_count=$9;
		my $sample_number=$10;
		my $sample_species=$11;

		$sample_species=~s/ /_/;

		print $dataset_number."\n";
		push(@list, "$dataset_number");

		system("ln -s $dir/$file/Assembly_Trinity/Trinity.fasta ~/bin/Fish_And_Chips_AAJ/Part2/Annotations/Species_to_annotate/$sample_species/$sample_species/_S_$dataset_number/_E_mRNA.fasta");

	}
}
close GO ;




foreach $srp (@list){
	chomp$srp;
	print "--------------------------------> pour chaque SRP \n";
	print $srp."\n";

	if ($self->{previousSrp} eq ""){
		print "pas de precedent\n";
		pipeline($srp);
		$self->{previousSrp}=$srp;
	}
	else{
		print " un precedent \n";
		retry($srp,$self->{previousSrp});
	}

}

###############################################################################################
###############################################################################################

sub retry{
	my $srp1=shift;
	my $previousSrp=shift;
	my $numberline=0;
	print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++RETRY\n";
	system("qstat | grep 'ajosselin' |tr -s \" \" \"\\t\"> listejobs.txt");
	open(FILEJOB,"<listejobs.txt");
	while(<FILEJOB>){
		$numberline+=1;
		$self->{jobs}->{$numberline}=$_;
	}

	if($numberline<30){
		print "*********************************> pour chaque ligne \n";
		print $numberline."\n";
		foreach(my $i=1,$i<=$numberline,$i+=1){
			my @listeVar1=split(/\t/,$self->{jobs}->{$i});
			#print join ('***',@listeVar1)."\n";
			if($listeVar1[2] =~ m/^Trinity_/){
			#if ($listeVar1[2] eq "Trinity_".$previousSrp){
				sleep(60);
				retry($srp1,$previousSrp);
			}
			else{
				pipeline($srp1);
				$self->{previousSrp}=$srp1;
			}
		}
	}
	else{
		sleep(60);
		retry($srp1,$previousSrp);
	}
}


sub pipeline{
	my $file=shift;
	my $TrinityOutDir = $dir."/".$file."/Assembly_Trinity/";


	###########################################################################################
	### 1/ alignment et assemblage
	my $dossier = "$dir/$file/RAW_data/";
	my $dossierO = "$dir/$file/RAW_data/";
	print $dir."\n";
	print $dossier."\n";
	opendir DIR , $dossier;
	opendir DIRO, $dossierO;

	#my @list1=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*_1\.fastq\.gz$/} readdir DIR;	
	#my @list2=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*_2\.fastq\.gz$/} readdir DIR;
	
	my @list1=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*_1\.fastq$/} readdir DIR;
	my @list2=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*_2\.fastq$/} readdir DIRO;

	print join ("\t",sort @list1)."\n";
	print join ("\t",sort @list2)."\n";
	
	my @fulllist = (@list1,@list2);
	my $lengthlist = scalar(@fulllist);
	
	print join ("\t",@fulllist)."\n";
	print "scalar : ".scalar(@list1)."\t".scalar(@list2)."\n";
	if (scalar(@list1)>0 and scalar(@list2)>0){
		#print scalar(@list1)."\t".scalar(@list2)."\n";
		$self->{type}="--left ".$dossier."".join(','.$dossier,sort(@list1))." --right ".$dossier."".join(','.$dossier,sort(@list2))." ";
		$self->{clip}="/home/ajosselin/work/data/TruSeq3-PE.fa";

	}
	if (scalar(@list1)>0 and scalar(@list2)==0){
		#print scalar(@list1)."\t".scalar(@list2)."\n";
		$self->{type}="--single ".$dossier."".join(','.$dossier,@list1)." ";
		$self->{clip}="/home/ajosselin/work/data/TruSeq3-SE.fa";
	}
	close DIR;
	close DIRO; 

	open(CMDTRINITY, ">$dir/$file/1_Trinity.sh");
	printf(CMDTRINITY "#!/bin/bash\n");
	printf(CMDTRINITY "#\$ -N e1_Trinity_".$file."\n");
	printf(CMDTRINITY "#\$ -cwd\n");
	printf(CMDTRINITY "#\$ -V\n");
	## job require at least xxG of memory free on compute node
	printf(CMDTRINITY "## -l mem=8G\n");
	#job must be killed if memory exceed xxG
	printf(CMDTRINITY "#\$ -l h_vmem=100G\n");
	#join SGE output files (.o123 & .e123) in .o only
	printf(CMDTRINITY "#\$ -j no\n");
	## xx threads required for the job"
	printf(CMDTRINITY "#\$ -pe parallel_smp 8\n");
	printf(CMDTRINITY "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDTRINITY "#\$ -q workq\n");
	printf(CMDTRINITY "#\$ -m bea\n");

	#printf(CMDTRINITY "#\$ -hold_jid test888888\n");

	printf(CMDTRINITY "module load bioinfo/Java7\n");

	printf(CMDTRINITY "Trinity --seqType fq ");
	printf(CMDTRINITY "--JM 12G --CPU 8 ");
	printf(CMDTRINITY $self->{type});
	printf(CMDTRINITY "--output ".$TrinityOutDir." ");
	printf(CMDTRINITY "--trimmomatic ");
	printf(CMDTRINITY "--quality_trimming_params \"ILLUMINACLIP:".$self->{clip}.":2:30:10 LEADING:15 TRAILING:15 SLIDINGWINDOW:5:20 MINLEN:40\" \n" );

	close CMDTRINITY;


	#system("qsub","$dir/$file/test.sh");

	#system("qsub","$dir/$file/1_Trinity.sh");


	###########################################################################################
	### 2/ Creation index Bowtie
	open(CMDBOWTIE_1,">$dir/$file/2_indexBowtie2.sh");
	printf(CMDBOWTIE_1 "#!/bin/bash\n");
	printf(CMDBOWTIE_1 "#\$ -N e2_indexbowtie2_".$file."\n");
	printf(CMDBOWTIE_1 "#\$ -cwd\n");
	printf(CMDBOWTIE_1 "#\$ -V\n");
	## job require at least xxG of memory free on compute node
	printf(CMDBOWTIE_1 "#\$ -l mem=12G\n");
	## job must be killed if memory exceed xxG
	printf(CMDBOWTIE_1 "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDBOWTIE_1 "#\$ -j no\n");
	## xx threads required for the job
	printf(CMDBOWTIE_1 "## -pe parallel_smp 12\n");
	printf(CMDBOWTIE_1 "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDBOWTIE_1 "#\$ -q workq\n");
	printf(CMDBOWTIE_1 "#\$ -m bea\n");

	printf(CMDBOWTIE_1 "#\$ -hold_jid e1_Trinity_".$file."\n");

	printf(CMDBOWTIE_1 "bowtie2-build ".$TrinityOutDir."Trinity.fasta ".$TrinityOutDir."Trinity.fasta\n");

	close CMDBOWTIE_1;

	#system("qsub","$dir/$file/2_indexBowtie2.sh");

	###########################################################################################
	### 3/Evaluation Assemblage

	if (scalar(@list1)>0 and scalar(@list2)>0){
	#if (scalar(@trimlist1)>0 and scalar(@trimlist2)>0){
		my $dossier2 = $TrinityOutDir;
		my $dossier21= $TrinityOutDir;
		opendir DIR2 , $dossier2;
		opendir DIR21, $dossier21;
		my @trimlist1=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*_1\.fastq\.P\.qtrim\.gz$/} readdir DIR2;
		my @trimlist2=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*_2\.fastq\.P\.qtrim\.gz$/} readdir DIR21;
		$self->{trimfiles}="-1 ".$TrinityOutDir."".join(','.$TrinityOutDir,sort(@trimlist1))." -2 ".$TrinityOutDir."".join(','.$TrinityOutDir,sort(@trimlist2))." ";

		close DIR2;
		close DIR21;
	}
	if (scalar(@list1)>0 and scalar(@list2)==0){
	#if (scalar(@trimlist1)>0 and scalar(@trimlist2)==0){
		my $dossier22 = $TrinityOutDir;
		#my $dossier23= $TrinityOutDir;
		opendir DIR22 , $dossier22;
		#opendir DIR23, $dossier23;
		my @trimlist12=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*_1\.fastq\.qtrim\.fq$/} readdir DIR22;
		#my @trimlist22=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*_2\.fastq\.qtrim\.fq$/} readdir DIR23;
		$self->{trimfiles}="-U ".$TrinityOutDir."".join(','.$TrinityOutDir,@trimlist12)." ";
	}
	#close DIR2;

	open(CMDBOWTIE_2,">$dir/$file/3_evalAssembly_Bowtie2.sh");
	printf(CMDBOWTIE_2 "#!/bin/bash\n");
	printf(CMDBOWTIE_2 "#\$ -N e3_evalbybowtie2_".$file."\n");
	printf(CMDBOWTIE_2 "#\$ -cwd\n");
	printf(CMDBOWTIE_2 "#\$ -V\n");
	## job must be killed if memory exceed xxG
	printf(CMDBOWTIE_2 "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDBOWTIE_2 "#\$ -j no\n");
	## xx threads required for the job
	printf(CMDBOWTIE_2 "#\$ -pe parallel_smp 12\n");
	printf(CMDBOWTIE_2 "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDBOWTIE_2 "#\$ -q workq\n");
	printf(CMDBOWTIE_2 "#\$ -m bea\n");

	printf(CMDBOWTIE_2 "#\$ -hold_jid e2_indexbowtie2_".$file."\n");

	printf(CMDBOWTIE_2 "bowtie2 --local --threads 12 --phred33 -x ".$TrinityOutDir."Trinity.fasta -q ".$self->{trimfiles}." |samtools view -Sb - | samtools sort -o - - > ".$TrinityOutDir."bowtie_AssemblyEvaluation.nameSorted.bam\n");

	close CMDBOWTIE_2;

	#system("qsub","$dir/$file/3_evalAssembly_Bowtie2.sh");

	###########################################################################################
	### 4/ Statistique d'evaluation du mapping bowtie
	my $pathToUtilSAM="/usr/local/bioinfo/src/trinityrnaseq/current/util/";
	
	open(CMDSTAT,">$dir/$file/4_statsMappingBowtie.sh");
	printf(CMDSTAT "#!/bin/bash\n");
	printf(CMDSTAT "#\$ -N e4_statsevalmapBowtie_".$file."\n");
	printf(CMDSTAT "#\$ -cwd\n");
	printf(CMDSTAT "#\$ -V\n");
	## job must be killed if memory exceed xxG
	printf(CMDSTAT "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDSTAT "#\$ -j no\n");
	## xx threads required for the job
	printf(CMDSTAT "#\$ -pe parallel_smp 12\n");
	printf(CMDSTAT "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDSTAT "#\$ -q workq\n");
	printf(CMDSTAT "#\$ -m bea\n");

	printf(CMDSTAT "#\$ -hold_jid e3_evalbybowtie2_".$file."\n");

	printf(CMDSTAT $pathToUtilSAM."SAM_nameSorted_to_uniq_count_stats.pl ".$TrinityOutDir."bowtie_AssemblyEvaluation.nameSorted.bam > ".$TrinityOutDir."statsEvalMappingBowtie.txt\n");

	close CMDSTAT;

	#system("qsub","$dir/$file/4_statsMappingBowtie.sh");

	###########################################################################################
	### 5/ Preparation de la reference
	my $pathToUtilTrinity ="/usr/local/bioinfo/src/trinityrnaseq/current/util/";

	open(CMDPREPREF,">$dir/$file/5_prepref.sh");
	printf(CMDPREPREF "#!/bin/bash\n");
	printf(CMDPREPREF "#\$ -N e5_preprefRSEM_".$file."\n");
	printf(CMDPREPREF "#\$ -cwd\n");
	printf(CMDPREPREF "#\$ -V\n");
	## job array of X sub-jobs
	printf(CMDPREPREF "## -t 1-2\n");
	## job require at least xxG of memory free on compute node
	printf(CMDPREPREF "## -l mem=12G\n");
	## job must be killed if memory exceed xxG
	printf(CMDPREPREF "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDPREPREF "#\$ -j no\n");
	## xx threads required for the job
	printf(CMDPREPREF "## -pe parallel_smp 16\n");
	printf(CMDPREPREF "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDPREPREF "#\$ -q workq\n");
	printf(CMDPREPREF "#\$ -m bea\n");

	printf(CMDPREPREF "#\$ -hold_jid e4_statsevalmapBowtie_".$file."\n");

	printf(CMDPREPREF $pathToUtilTrinity."align_and_estimate_abundance.pl --transcripts ".$TrinityOutDir."Trinity.fasta --est_method RSEM --aln_method bowtie --trinity_mode --prep_reference\n");
	close(CMDPREPREF);

	#system("qsub","$dir/$file/5_prepref.sh");

	###########################################################################################
	### 6/ estimation de l'abondance RSEM                                                           ##### arevoir pour le single end et le paired end !!!

	
	if (scalar(@list1)>0 and scalar(@list2)>0){
		print join ("\t",@list1)."\n";
		my $mylist = join ("\t",@list1);

		$mylist =~ s/_1.fastq//g;
		print $mylist."\n";
		@Mylist= split (/\t/,$mylist);
		print join ("***",@Mylist)."\n";

		# my @optionlist=();
		# foreach my $elt (@Mylist){
		# 	my $var ="--left ".$TrinityOutDir."".$elt."_1.fasta.P.qtrim.gz --right ".$TrinityOutDir."".$elt."_2.fasta.P.qtrim.gz";
		# 	push @optionlist,$var;
		# }

		# print join("\n",@optionlist)."\n";		

		$self->{samples}= "(toto1 ".join(' ',@Mylist).")" ;
		my $lengthlist0 = scalar(@Mylist);
		print $self->{samples}."\n";

		my $RSEMoutdir=$TrinityOutDir."RSEM/";

		open(CMDESTIMATE_AB,">$dir/$file/6_estimateAbundance_RSEM.sh");
		printf(CMDESTIMATE_AB "#!/bin/bash\n");
		printf(CMDESTIMATE_AB "#\$ -N e6_launchRSEM_".$file."\n");
		printf(CMDESTIMATE_AB "#\$ -cwd\n");
		printf(CMDESTIMATE_AB "#\$ -V\n");
		## job array of X sub-jobs
		printf(CMDESTIMATE_AB "#\$ -t 1-".$lengthlist0."\n");
		## job require at least xxG of memory free on compute node
		printf(CMDESTIMATE_AB "## -l mem=12G\n");
		## job must be killed if memory exceed xxG
		printf(CMDESTIMATE_AB "#\$ -l h_vmem=100G\n");
		## join SGE output files (.o123 & .e123) in .o only
		printf(CMDESTIMATE_AB "#\$ -j no\n");
		## xx threads required for the job
		printf(CMDESTIMATE_AB "#\$ -pe parallel_smp 16\n");
		printf(CMDESTIMATE_AB "#\$ -M ambre-aurore.josselin\@inra.fr\n");
		printf(CMDESTIMATE_AB "#\$ -q workq\n");
		printf(CMDESTIMATE_AB "#\$ -m bea\n");

		printf(CMDESTIMATE_AB "#\$ -hold_jid e5_preprefRSEM_".$file."\n");

		printf(CMDESTIMATE_AB "##table of samples\n");
		printf(CMDESTIMATE_AB "samples=".$self->{samples}."\n");
		printf(CMDESTIMATE_AB "sample=\"\${samples[\$SGE_TASK_ID]}\"\n");

		##some vars 
		printf(CMDESTIMATE_AB "outdir='".$TrinityOutDir."RSEM/'\n");

		printf(CMDESTIMATE_AB $pathToUtilTrinity."align_and_estimate_abundance.pl --thread_count 16 --transcripts ".$TrinityOutDir."Trinity.fasta --seqType fq --est_method RSEM --aln_method bowtie --trinity_mode --output_prefix ".$TrinityOutDir."\${sample}.fastq.P.qtrim.gz --left  ".$TrinityOutDir."\${sample}_1.fastq.P.qtrim.gz --right ".$TrinityOutDir."\${sample}_2.fastq.P.qtrim.gz\n"); 
		close(CMDESTIMATE_AB);

	}
	if (scalar(@list1)>0 and scalar(@list2)==0){

		#my $lengthlist = scalar(@fulllist);
		$self->{samples}= "(toto2 ".$TrinityOutDir."".join('.qtrim.fq '.$TrinityOutDir,@fulllist).".qtrim.fq)" ;

		my $RSEMoutdir=$TrinityOutDir."RSEM/";

		open(CMDESTIMATE_AB,">$dir/$file/6_estimateAbundance_RSEM.sh");
		printf(CMDESTIMATE_AB "#!/bin/bash\n");
		printf(CMDESTIMATE_AB "#\$ -N e6_launchRSEM_".$file."\n");
		printf(CMDESTIMATE_AB "#\$ -cwd\n");
		printf(CMDESTIMATE_AB "#\$ -V\n");
		## job array of X sub-jobs
		printf(CMDESTIMATE_AB "#\$ -t 1-".$lengthlist."\n");
		## job require at least xxG of memory free on compute node
		printf(CMDESTIMATE_AB "## -l mem=12G\n");
		## job must be killed if memory exceed xxG
		printf(CMDESTIMATE_AB "#\$ -l h_vmem=100G\n");
		## join SGE output files (.o123 & .e123) in .o only
		printf(CMDESTIMATE_AB "#\$ -j no\n");
		## xx threads required for the job
		printf(CMDESTIMATE_AB "#\$ -pe parallel_smp 16\n");
		printf(CMDESTIMATE_AB "#\$ -M ambre-aurore.josselin\@inra.fr\n");
		printf(CMDESTIMATE_AB "#\$ -q workq\n");
		printf(CMDESTIMATE_AB "#\$ -m bea\n");

		printf(CMDESTIMATE_AB "#\$ -hold_jid e5_preprefRSEM_".$file."\n");

		printf(CMDESTIMATE_AB "##table of samples\n");
		printf(CMDESTIMATE_AB "samples=".$self->{samples}."\n");
		printf(CMDESTIMATE_AB "sample=\"\${samples[\$SGE_TASK_ID]}\"\n");

		##some vars 
		printf(CMDESTIMATE_AB "outdir='".$TrinityOutDir."RSEM/'\n");

		printf(CMDESTIMATE_AB $pathToUtilTrinity."align_and_estimate_abundance.pl --thread_count 16 --transcripts ".$TrinityOutDir."Trinity.fasta --seqType fq --est_method RSEM --aln_method bowtie --trinity_mode --output_prefix \${sample} --single \${sample}\n"); 
		close(CMDESTIMATE_AB);

	}


	#system("qsub","$dir/$file/6_estimateAbundance_RSEM.sh");

	##########################################################################################
	## 7/ construction des matrices d'expression
	# my $dossier4 = $RSEMoutdir;
	# opendir DIR4 , $dossier4;
	# my @resultRSEMlist=grep{$_ ne '.' and $_ ne '..' and $_=~ m/^.*\.genes\.results$/} readdir DIR4;
	# my $lengthlist2 = scalar(@resultRSEMlist);
	
	if (scalar(@list1)>0 and scalar(@list2)>0){
		#print "C'EST LAAAAAAAAAAAAAAAAAAAAAAAAAAAAA !!\n";
		$self->{RSEMresults}= $TrinityOutDir."".join('.fastq.P.qtrim.gz.genes.results '.$TrinityOutDir,@Mylist).".fastq.P.qtrim.gz.genes.results\n" ;		
	}
	if (scalar(@list1)>0 and scalar(@list2)==0){
		#print "C'EST ICIIIIIIIIIIIIIIIIIIIIIIIIIIIII !!\n";
		$self->{RSEMresults}= $TrinityOutDir."".join('.qtrim.fq.genes.results '.$TrinityOutDir,@fulllist).".qtrim.fq.genes.results\n" ;
	}	
	#print $self->{RSEMresults}."\n";
	#close DIR4;

	open(CMDMATRIX,">$dir/$file/7_ConstructionMatrix.sh");
	printf(CMDMATRIX "#!/bin/bash\n");
	printf(CMDMATRIX "#\$ -N e7_constructMatrixGenes_".$file."\n");
	printf(CMDMATRIX "#\$ -cwd\n");
	printf(CMDMATRIX "#\$ -V\n");
	## job array of X sub-jobs
	#printf(CMDMATRIX "## -t 1-".$lengthlist."\n");
	## job require at least xxG of memory free on compute node
	printf(CMDMATRIX "## -l mem=12G\n");
	## job must be killed if memory exceed xxG
	printf(CMDMATRIX "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDMATRIX "#\$ -j no\n");
	## xx threads required for the job
	printf(CMDMATRIX "## -pe parallel_smp 16\n");
	printf(CMDMATRIX "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDMATRIX "#\$ -q workq\n");
	printf(CMDMATRIX "#\$ -m bea\n");

	printf(CMDMATRIX "#\$ -hold_jid e6_launchRSEM_".$file."\n");

	printf(CMDMATRIX $pathToUtilTrinity."abundance_estimates_to_matrix.pl --est_method RSEM --cross_sample_fpkm_norm TMM --out_prefix ".$TrinityOutDir."".$file."_genes_counts ".$self->{RSEMresults}."\n");

	close(CMDMATRIX);

	#system("qsub","$dir/$file/7_ConstructionMatrix.sh");

	###########################################################################################
	### 8/ comparaison des replicats de chaque echantillon

	### IL va falloir voir comment sera fait la fichier samples.txt contenant la correspondance entre les fichiers et les conditions
	###

	my $pathToDE="/usr/local/bioinfo/src/trinityrnaseq/current/Analysis/DifferentialExpression/";
	my $ComparisionOutDir = $dir."/".$file."/comparisionsReplicates/";
	system("mkdir",$ComparisionOutDir);

	open(CMDcompPERsamples,">$dir/$file/8_compareReplicatesInSamples.sh");
	printf(CMDcompPERsamples "#!/bin/bash\n");
	printf(CMDcompPERsamples "#\$ -N e8_compareEach_".$file."\n");
	printf(CMDcompPERsamples "#\$ -cwd\n");
	printf(CMDcompPERsamples "#\$ -V\n");
	## job array of X sub-jobs
	printf(CMDcompPERsamples "## -t 1-16\n");
	## job require at least xxG of memory free on compute node
	printf(CMDcompPERsamples "## -l mem=12G\n");
	## job must be killed if memory exceed xxG
	printf(CMDcompPERsamples "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDcompPERsamples "#\$ -j no\n");
	## xx threads required for the job
	printf(CMDcompPERsamples "## -pe parallel_smp 16\n");
	printf(CMDcompPERsamples "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDcompPERsamples "#\$ -q workq\n");
	printf(CMDcompPERsamples "#\$ -m bea\n");

	printf(CMDcompPERsamples "#\$ -hold_jid e7_constructMatrixGenes_".$file."\n");

	printf(CMDcompPERsamples $pathToDE."PtR --matrix ".$TrinityOutDir."".$file."_genes_counts.counts.matrix --samples ".$dir."/".$file."/samples.txt  --output ".$ComparisionOutDir."compareReplicatesInSample --log2 --compare_replicates");

	close(CMDcompPERsamples);

	#system("qsub","$dir/$file/8_compareReplicatesInSamples.sh");

	###########################################################################################
	### 9/ comparaison des replicats entre les echantillons


	open(CMDcompBETWEENsamples,">$dir/$file/9_compareReplicatesBetweenSamples.sh");
	printf(CMDcompBETWEENsamples "#!/bin/bash\n");
	printf(CMDcompBETWEENsamples "#\$ -N e9_compAcross_".$file."\n");
	printf(CMDcompBETWEENsamples "#\$ -cwd\n");
	printf(CMDcompBETWEENsamples "#\$ -V\n");
	## job array of X sub-jobs
	printf(CMDcompBETWEENsamples "## -t 1-16\n");
	## job require at least xxG of memory free on compute node
	printf(CMDcompBETWEENsamples "## -l mem=12G\n");
	## job must be killed if memory exceed xxG
	printf(CMDcompBETWEENsamples "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDcompBETWEENsamples "#$ -j no\n");
	## xx threads required for the job
	printf(CMDcompBETWEENsamples "#\# -pe parallel_smp 16\n");
	printf(CMDcompBETWEENsamples "#\$ -M ambre-aurore.josselin;\@inra.fr\n");
	printf(CMDcompBETWEENsamples "#\$ -q workq\n");
	printf(CMDcompBETWEENsamples "#\$ -m bea\n");

	printf(CMDcompBETWEENsamples "#\$ -hold_jid e8_compareEach_".$file."\n");

	printf(CMDcompBETWEENsamples $pathToDE."PtR --matrix ".$TrinityOutDir."".$file."_genes_counts.counts.matrix --samples ".$dir."/".$file."/samples.txt  --output ".$ComparisionOutDir."compareReplicatesAccrossSamples --log2 --sample_cor_matrix\n");

	close(CMDcompBETWEENsamples);

	#system("qsub","$dir/$file/9_compareReplicatesBetweenSamples.sh");

	###########################################################################################
	### 10/ comparaison des replicat en composantes principales 

	open(CMDcompCOMPPRINCIPAL,">$dir/$file/10_compareReplicatesCompPrincipal.sh");
	printf (CMDcompCOMPPRINCIPAL "#!/bin/bash\n");
	printf (CMDcompCOMPPRINCIPAL "#\$ -N e10_compCompPrinc_".$file."\n");
	printf (CMDcompCOMPPRINCIPAL "#\$ -cwd\n");
	printf (CMDcompCOMPPRINCIPAL "#\$ -V\n");
	## job array of X sub-jobs
	printf (CMDcompCOMPPRINCIPAL "## -t 1-16\n");
	## job require at least xxG of memory free on compute node
	printf (CMDcompCOMPPRINCIPAL "## -l mem=12G\n");
	## job must be killed if memory exceed xxG
	printf (CMDcompCOMPPRINCIPAL "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf (CMDcompCOMPPRINCIPAL "#\$ -j no\n");
	## xx threads required for the job
	printf (CMDcompCOMPPRINCIPAL "## -pe parallel_smp 16\n");
	printf (CMDcompCOMPPRINCIPAL "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf (CMDcompCOMPPRINCIPAL "#\$ -q workq\n");
	printf (CMDcompCOMPPRINCIPAL "#\$ -m bea\n");

	printf(CMDcompCOMPPRINCIPAL "#\$ -hold_jid e9_compAcross_".$file."\n");

	printf (CMDcompCOMPPRINCIPAL $pathToDE."PtR --matrix ".$TrinityOutDir."".$file."_genes_counts.counts.matrix --samples ".$dir."/".$file."/samples.txt  --output ".$ComparisionOutDir."compareReplicatesCompPrin --log2 --prin_comp 4\n");

	close (CMDcompCOMPPRINCIPAL);

	#system("qsub","$dir/$file/10_compareReplicatesCompPrincipal.sh");

	###########################################################################################
	### 11/ Expression differentielle
	my $self->{methodDE}="edgeR";
	my $pathToDEResults=$TrinityOutDir.$self->{methodDE}."_results";
	system("rm","-rf",$pathToDEResults);
	#system("mkdir",$pathToDEResults);

	open(CMDDE,">$dir/$file/11_DE.sh");
	printf(CMDDE "#!/bin/bash\n");
	printf(CMDDE "#\$ -N e11_runDE_".$file."\n");
	printf(CMDDE "#\$ -cwd\n");
	printf(CMDDE "#\$ -V\n");
	## job array of X sub-jobs
	printf(CMDDE "## -t 1-16\n");
	## job require at least xxG of memory free on compute node
	printf(CMDDE "#\$ -l mem=10G\n");
	## job must be killed if memory exceed xxG
	printf(CMDDE "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDDE "#\$ -j no\n");
	## xx threads required for the job
	printf(CMDDE "## -pe parallel_smp 16\n");
	printf(CMDDE "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDDE "#\$ -q workq\n");
	printf(CMDDE "#\$ -m bea\n");

	printf(CMDDE "#\$ -hold_jid e10_compCompPrinc_".$file."\n");

	printf(CMDDE $pathToDE."run_DE_analysis.pl --matrix ".$TrinityOutDir."".$file."_genes_counts.counts.matrix --method ".$self->{methodDE}." --output ".$pathToDEResults." --samples ".$dir."/".$file."/samples.txt\n");

	close(CMDDE);

	#system("qsub","$dir/$file/11_DE.sh");

	###########################################################################################
	# open(CMD1,">$dir/$file/mkdir.sh");
	# printf(CMD1 "#!/bin/bash\n");
	# printf(CMD1 "#\$ -N mkdir_".$file."\n");
	# printf(CMD1 "#\$ -cwd\n");
	# printf(CMD1 "#\$ -V\n");
	# ## job array of X sub-jobs
	# printf(CMD1 "## -t 1-16\n");
	# ## job require at least xxG of memory free on compute node
	# printf(CMD1 "## -l mem=10G\n");
	# ## job must be killed if memory exceed xxG
	# printf(CMD1 "## -l h_vmem=60G\n");
	# ## join SGE output files (.o123 & .e123) in .o only
	# printf(CMD1 "#\$ -j no\n");
	# ## xx threads required for the job
	# printf(CMD1 "## -pe parallel_smp 16\n");
	# printf(CMD1 "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	# printf(CMD1 "#\$ -q workq\n");
	# printf(CMD1 "#\$ -m bea\n");

	# printf(CMD1 "#\$ -hold_jid runDE_".$file."\n");

	# printf(CMD1 "mkdir ".$pathToDEResults."\n");

	# close(CMD1);

	# system("qsub","$dir/$file/mkdir.sh");

	#########

	# open(CMD2,">$dir/$file/cd.sh");
	# printf(CMD2 "#!/bin/bash\n");
	# printf(CMD2 "#\$ -N cd_".$file."\n");
	# printf(CMD2 "#\$ -cwd\n");
	# printf(CMD2 "#\$ -V\n");
	# ## job array of X sub-jobs
	# printf(CMD2 "## -t 1-16\n");
	# ## job require at least xxG of memory free on compute node
	# printf(CMD2 "## -l mem=10G\n");
	# ## job must be killed if memory exceed xxG
	# printf(CMD2 "## -l h_vmem=60G\n");
	# ## join SGE output files (.o123 & .e123) in .o only
	# printf(CMD2 "#\$ -j no\n");
	# ## xx threads required for the job
	# printf(CMD2 "## -pe parallel_smp 16\n");
	# printf(CMD2 "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	# printf(CMD2 "#\$ -q workq\n");
	# printf(CMD2 "#\$ -m bea\n");

	# printf(CMD2 "#\$ -hold_jid runDE_".$file."\n");

	# printf(CMD2 "cd ".$pathToDEResults."\n");

	# close(CMD2);

	# system("qsub","$dir/$file/cd.sh");



	###########################################################################################
	### 12/ Analyse de l'expression differentielle
	## Dans le dossier d'analyse DE

	open(CMDAnalysisDE,">$dir/$file/12_DEAnalysis.sh");
	printf(CMDAnalysisDE "#!/bin/bash\n");
	printf(CMDAnalysisDE "#\$ -N e12_analyseDE_".$file."\n");
	printf(CMDAnalysisDE "#\$ -wd ".$pathToDEResults."/\n");
	printf(CMDAnalysisDE "#\$ -V\n");
	## job array of X sub-jobs
	printf(CMDAnalysisDE "## -t 1-16\n");
	## job require at least xxG of memory free on compute node
	printf(CMDAnalysisDE "#\$ -l mem=10G\n");
	## job must be killed if memory exceed xxG
	printf(CMDAnalysisDE "#\$ -l h_vmem=100G\n");
	## join SGE output files (.o123 & .e123) in .o only
	printf(CMDAnalysisDE "#\$ -j no\n");
	## xx threads required for the job
	printf(CMDAnalysisDE "## -pe parallel_smp 16\n");
	printf(CMDAnalysisDE "#\$ -M ambre-aurore.josselin\@inra.fr\n");
	printf(CMDAnalysisDE "#\$ -q workq\n");
	printf(CMDAnalysisDE "#\$ -m bea\n");

	printf(CMDAnalysisDE "#\$ -hold_jid e11_runDE_".$file."\n");


	printf(CMDAnalysisDE  $pathToDE."analyze_diff_expr.pl --matrix ".$TrinityOutDir."".$file."_genes_counts.TMM.fpkm.matrix -P 0.001 -C 2 --output differentialExpression --samples ".$dir."/".$file."/samples.txt\n");

	close(CMDAnalysisDE);

	#system("qsub","$dir/$file/12_DEAnalysis.sh"),
}







