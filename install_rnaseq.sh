#!/bin/bash
#
# Installation script for RNA-Seq data preprocessing
# 
# Note that there is a dependency issue. So getting the latest version may not work. 
# For example, tophat v2.0.11 only supports bowtie2 v2.2.1 but not v2.2.2.

SRATOOLKIT_URL=http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.3.5-2/sratoolkit.2.3.5-2-ubuntu64.tar.gz
BOWTIE2_URL=http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.1/bowtie2-2.2.1-linux-x86_64.zip/download
TOPHAT_URL=http://ccb.jhu.edu/software/tophat/downloads/tophat-2.0.11.Linux_x86_64.tar.gz
SAMTOOLS_URL=http://sourceforge.net/projects/samtools/files/samtools/0.1.19/samtools-0.1.19.tar.bz2/download
HTSEQ_URL=https://pypi.python.org/packages/source/H/HTSeq/HTSeq-0.6.1.tar.gz#md5=b7f4f38a9f4278b9b7f948d1efbc1f05
FASTQC_URL=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.10.1.zip
FASTX_URL=http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2

set -e
# enable universe for python-matplotlib
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
# update repository
sudo apt-get update

# download packages for samtools
sudo apt-get -y install zlib1g-dev
sudo apt-get -y install libncurses5-dev
# download packages for htseq-count
sudo apt-get -y install build-essential python2.7-dev python-numpy python-matplotlib
# download package for FastQC
sudo apt-get -y install openjdk-6-jdk

# create a new directory
if [ ! -d /opt/RNA-Seq/bin ]; then
  mkdir -p /opt/RNA-Seq/bin
fi
cd /opt/RNA-Seq/bin

# sratoolkit
wget -N $SRATOOLKIT_URL -O sratoolkit.tar.gz
tar xzvf sratoolkit.tar.gz

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
wget $SAMTOOLS_URL -O samtools.tar.bz2
tar xjvf samtools.tar.bz2
cd samtools-*
make
cd ..

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

# clean up
rm *.zip *.tar.gz *.tar.bz2

sudo chown root:root -R /opt/RNA-Seq/*
sudo chmod +xr /opt/RNA-Seq/bin/samtools-0.1.19
sudo chmod +xr /opt/RNA-Seq/bin/samtools-0.1.19/bcftools
sudo chmod +xr /opt/RNA-Seq/bin/samtools-0.1.19/misc
sudo chmod +x /opt/RNA-Seq/bin/FastQC/fastqc

echo
read -p "Press [Enter] key to quit."
