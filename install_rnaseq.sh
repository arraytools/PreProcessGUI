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
SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2
# SNPEFF_URL=http://skylineservers.dl.sourceforge.net/project/snpeff/snpEff_latest_core.zip
BCFTOOLS_URL=https://github.com/samtools/bcftools/releases/download/1.3/bcftools-1.3.tar.bz2
HTSEQ_URL=https://pypi.python.org/packages/source/H/HTSeq/
PICARD_URL=https://github.com/broadinstitute/picard/releases/download/2.0.1/picard-tools-2.0.1.zip
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

# sratoolkit
wget -N $SRATOOLKIT_URL -O sratoolkit.tar.gz
tar xzvf sratoolkit.tar.gz

# BWA (needs to compile)
wget -N $BWA_URL -O BWA.tar.gz
tar xzvf BWA.tar.gz
cd bwa-*
make
cd ..

# bowtie
if [ -f bowtie2.zip ]; then
  rm bowtie2.zip
fi
wget $BOWTIE2_URL -O bowtie2.zip
unzip -o bowtie2.zip

# tophat
wget -N $TOPHAT_URL -O tophat.tar.gz
tar xzvf tophat.tar.gz

# samtools (needs to compile)
wget -N $SAMTOOLS_URL -O samtools.tar.bz2
tar xjvf samtools.tar.bz2
cd samtools-*
make

# add htslib from samtools
cd htslib-*
make
cd ../..

# bcftools (needs to compile)
wget -N $BCFTOOLS_URL -O bcftools.tar.bz2
tar xjvf bcftools.tar.bz2
cd bcftools-*
make
cd ..

# Picard tool
wget -N $PICARD_URL -O picard.zip
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
unzip -o fastqc.zip

# fastx
wget $FASTX_URL -O fastx.tar.bz2
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

# clean up
rm *.zip *.tar.gz *.tar.bz2

chown root:root -R /opt/SeqTools/*
#chmod +xr /opt/SeqTools/bin/samtools-0.1.19
#chmod +xr /opt/SeqTools/bin/samtools-0.1.19/bcftools
#chmod +xr /opt/SeqTools/bin/samtools-0.1.19/misc
#chmod +x /opt/SeqTools/bin/FastQC/fastqc

echo
read -p "Press [Enter] key to quit."