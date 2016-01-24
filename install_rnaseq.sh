#!/bin/bash
#
# Installation script for SeqTools
#
# Note that there is a dependency issue. So getting the latest version may not work.
# For example, tophat v2.0.11 only supports bowtie2 v2.2.1 but not v2.2.2.

SRATOOLKIT_URL=http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.3.5-2/sratoolkit.2.3.5-2-ubuntu64.tar.gz
BWA_URL=https://github.com/lh3/bwa/archive/0.7.12.tar.gz
BOWTIE2_URL=http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip/download
TOPHAT_URL=https://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.0.Linux_x86_64.tar.gz
STAR_URL=https://github.com/alexdobin/STAR/archive/2.5.1a.tar.gz
SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2
# SNPEFF_URL=http://skylineservers.dl.sourceforge.net/project/snpeff/snpEff_latest_core.zip
BCFTOOLS_URL=https://github.com/samtools/bcftools/releases/download/1.3/bcftools-1.3.tar.bz2
HTSEQ_URL=https://pypi.python.org/packages/source/H/HTSeq/
PICARD_URL=https://github.com/broadinstitute/picard/releases/download/1.141/picard-tools-1.141.zip
HTSEQ_URL=https://pypi.python.org/packages/source/H/HTSeq/HTSeq-0.6.1.tar.gz#md5=b7f4f38a9f4278b9b7f948d1efbc1f05
FASTQC_URL=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.10.1.zip
FASTX_URL=http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2

set -e

# update repository
apt-get update

# download packages for samtools
apt-get -y install zlib1g-dev
apt-get -y install libncurses5-dev
# download packages for htseq-count
apt-get -y install build-essential python2.7-dev python-numpy python-matplotlib
# download package for FastQC
apt-get -y install openjdk-7-jdk

# create a new directory
if [ ! -d /opt/SeqTools/bin ]; then
  mkdir -p /opt/SeqTools/bin
fi
cd /opt/SeqTools/bin

# bookmark the directory name for SeqTools
if [ -f .DirName ]; then
  rm .DirName
fi
touch .DirName

# sratoolkit
wget -N $SRATOOLKIT_URL -O sratoolkit.tar.gz
dn=`tar -tf sratoolkit.tar.gz | grep -o '^[^/]\+' | sort -u`
echo -e "sratoolkit=$dn" >> .DirName
tar xzvf sratoolkit.tar.gz

# BWA (needs to compile)
wget -N $BWA_URL -O BWA.tar.gz
dn=`tar -tf BWA.tar.gz | grep -o '^[^/]\+' | sort -u`
echo -e "bwa=$dn" >> .DirName
tar xzvf BWA.tar.gz
cd $dn
make
cd ..

# bowtie
if [ -f bowtie2.zip ]; then
  rm bowtie2.zip
fi
wget $BOWTIE2_URL -O bowtie2.zip
dn=`unzip -vl bowtie2.zip | sed -n '4p' | awk '{print $8}'`
echo -e "bowtie2=$(basename $dn)" >> .DirName
unzip -o bowtie2.zip

# tophat
wget -N $TOPHAT_URL -O tophat.tar.gz
dn=`tar -tf tophat.tar.gz | grep -o '^[^/]\+' | sort -u`
echo -e "tophat=$dn" >> .DirName
tar xzvf tophat.tar.gz

# star
wget $STAR_URL -O star.tar.gz
dn=`tar -tf star.tar.gz | grep -o '^[^/]\+' | sort -u`
echo -e "star=$dn" >> .DirName
tar xzvf star.tar.gz

# samtools (needs to compile)
wget -N $SAMTOOLS_URL -O samtools.tar.bz2
dn=`tar -tf samtools.tar.bz2 | grep -o '^[^/]\+' | sort -u`
echo -e "samtools=$dn" >> .DirName
tar xjvf samtools.tar.bz2
cd $dn
./configure
make

dn=$(basename `find -maxdepth 1 -name 'htslib*'`)
echo -e "htslib=$dn" >> ../.DirName
# add htslib from samtools
cd $dn
./configure
make
cd ../..

# bcftools (needs to compile)
wget -N $BCFTOOLS_URL -O bcftools.tar.bz2
dn=`tar -tf bcftools.tar.bz2 | grep -o '^[^/]\+' | sort -u`
echo -e "bcftools=$dn" >> .DirName
tar xjvf bcftools.tar.bz2
cd $dn
make
cd ..

# Picard tool
wget -N $PICARD_URL -O picard.zip
dn=`unzip -vl picard.zip | sed -n '4p' | awk '{print $8}'`
echo -e "picard=$(basename $dn)" >> .DirName
unzip -o picard.zip

# htseq-count (needs to compile)
wget -N $HTSEQ_URL -O HTSeq.tar.gz
tar xzvf HTSeq.tar.gz
cd HTSeq-*
python setup.py build
sudo python setup.py install
cd ..

# fastqc
if [ -f fastqc.zip ]; then
  rm fastqc.zip
fi
wget -N $FASTQC_URL -O fastqc.zip
echo -e "fastqc=FastQC" >> .DirName
unzip -o fastqc.zip

# fastx
wget $FASTX_URL -O fastx.tar.bz2
echo -e "fastx=fastx" >> .DirName
if [ ! -d fastx ]; then
  mkdir fastx
fi
tar -xjvf fastx.tar.bz2 -C fastx

# add snpeff
# wget -N $SNPEFF_URL -O snpEff.zip
# unzip snpEff.zip

# install python-pip for variant annotation
# note python 2.7.3 on ubuntu 12.04
#      python 2.7.6 on ubuntu 14.04
apt-get -y install python-pip
pip install pylatex
apt-get install -y texlive-latex-base
# apt-get install -y texlive-binaries
apt-get install -y texlive-fonts-recommended # ecrm1000 error
apt-get install -y texlive-latex-extra # .sty files
apt-get install -y lmodern # lmodern.sty

# install r-base
apt-get install -y r-base

# clean up
rm *.zip *.tar.gz *.tar.bz2

chown root:root -R /opt/SeqTools/*
#chmod +xr /opt/SeqTools/bin/samtools-0.1.19
#chmod +xr /opt/SeqTools/bin/samtools-0.1.19/bcftools
#chmod +xr /opt/SeqTools/bin/samtools-0.1.19/misc
#chmod +x /opt/SeqTools/bin/FastQC/fastqc

echo
read -p "Press [Enter] key to quit."
