#!/bin/bash
#
# Installation script for SeqTools
#
# Note that there is a dependency issue. So getting the latest version may not work.
# For example, tophat v2.0.11 only supports bowtie2 v2.2.1 but not v2.2.2.

SRATOOLKIT_URL=http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.7.0/sratoolkit.2.7.0-ubuntu64.tar.gz
BWA_URL=https://github.com/lh3/bwa/archive/0.7.12.tar.gz
# BOWTIE2_URL=http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip/download
BOWTIE2_URL=https://github.com/BenLangmead/bowtie2/releases/download/v2.2.6/bowtie2-2.2.6-linux-x86_64.zip
TOPHAT_URL=https://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.0.Linux_x86_64.tar.gz
STAR_URL=https://github.com/alexdobin/STAR/archive/2.5.1b.tar.gz
SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2
BCFTOOLS_URL=https://github.com/samtools/bcftools/releases/download/1.3/bcftools-1.3.tar.bz2
PICARD_URL=https://github.com/broadinstitute/picard/releases/download/1.141/picard-tools-1.141.zip
HTSEQ_URL=https://pypi.python.org/packages/3c/6e/f8dc3500933e036993645c3f854c4351c9028b180c6dcececde944022992/HTSeq-0.6.1p1.tar.gz#md5=c44d7b256281a8a53b6fe5beaeddd31c
FASTQC_URL=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
FASTX_URL=http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
SNPEFF_URL=http://sourceforge.net/projects/snpeff/files/snpEff_v4_2_core.zip/download
# SNPEFF_URL=https://github.com/pcingola/SnpEff/archive/v4.2.zip
PANDOC_URL=https://github.com/jgm/pandoc/releases/download/1.16.0.2/pandoc-1.16.0.2-1-amd64.deb

set -e

codename=$(lsb_release -s -c)
if [ $codename == "rafaela" ] || [ $codename == "rosa" ]; then
  codename="trusty"
fi

add-apt-repository "deb http://cran.rstudio.com/bin/linux/ubuntu $codename/"
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | sudo apt-key add -

# update repository
apt-get update

# download packages for samtools
apt-get -y install zlib1g-dev
apt-get -y install libncurses5-dev
# download packages for htseq-count
apt-get -y install build-essential python2.7-dev python-numpy python-matplotlib
apt-get -y install python-pip
pip install pysam
# download package for FastQC
if [ $codename == "trusty" ]; then
  apt-get -y install openjdk-7-jdk
fi
if [ $codename == "xenial" ]; then
  apt-get -y install openjdk-9-jdk
fi

# goodies for vc annotation
apt-get -y install parallel

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
wget $SRATOOLKIT_URL -O sratoolkit.tar.gz
dn=`tar -tf sratoolkit.tar.gz | grep -o '^[^/]\+' | sort -u`
echo -e "sratoolkit=$dn" >> .DirName
tar xzvf sratoolkit.tar.gz

# BWA (needs to compile)
wget $BWA_URL -O BWA.tar.gz
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
nline=$(unzip -vl bowtie2.zip | head | grep -n 'CRC-32' | sed 's/^\([0-9]\+\):.*$/\1/')
((nline+=2))
dn=`unzip -vl bowtie2.zip | sed -n "${nline}p" | awk '{print $8}'`
echo -e "bowtie2=$(basename $dn)" >> .DirName
unzip -o bowtie2.zip

# tophat
wget $TOPHAT_URL -O tophat.tar.gz
dn=`tar -tf tophat.tar.gz | grep -o '^[^/]\+' | sort -u`
echo -e "tophat=$dn" >> .DirName
tar xzvf tophat.tar.gz

# star
wget $STAR_URL -O star.tar.gz
dn=`tar -tf star.tar.gz | grep -o '^[^/]\+' | sort -u`
echo -e "star=$dn" >> .DirName
tar xzvf star.tar.gz

# samtools (needs to compile)
wget $SAMTOOLS_URL -O samtools.tar.bz2
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
wget $BCFTOOLS_URL -O bcftools.tar.bz2
dn=`tar -tf bcftools.tar.bz2 | grep -o '^[^/]\+' | sort -u`
echo -e "bcftools=$dn" >> .DirName
tar xjvf bcftools.tar.bz2
cd $dn
make
cd ..

# Picard tool
wget $PICARD_URL -O picard.zip
nline=$(unzip -vl picard.zip | head | grep -n 'CRC-32' | sed 's/^\([0-9]\+\):.*$/\1/')
((nline+=2))
dn=`unzip -vl picard.zip | sed -n "${nline}p" | awk '{print $8}'`
echo -e "picard=$(basename $dn)" >> .DirName
unzip -o picard.zip

# htseq-count (needs to compile)
wget $HTSEQ_URL -O HTSeq.tar.gz
tar xzvf HTSeq.tar.gz
dn=`tar -tf HTSeq.tar.gz | grep -o '^[^/]\+' | sort -u`
cd $dn
python setup.py build
sudo python setup.py install
cd ..

# fastqc
if [ -f fastqc.zip ]; then
  rm fastqc.zip
fi
wget $FASTQC_URL -O fastqc.zip
echo -e "fastqc=FastQC" >> .DirName
unzip -o fastqc.zip

# snpeff
if [ -f snpEff*.zip ]; then
  rm snpEff*.zip
fi
wget $SNPEFF_URL -O snpEff.zip
nline=$(unzip -vl snpEff.zip | head | grep -n 'CRC-32' | sed 's/^\([0-9]\+\):.*$/\1/')
((nline+=2))
dn=`unzip -vl snpEff.zip | sed -n "${nline}p" | awk '{print $8}'`
echo -e "snpeff=$(basename $dn)" >> .DirName
unzip -o snpEff.zip
snpEff=`basename $dn`
if [ ! -d $snpEff/data ]; then mkdir $snpEff/data; fi
sudo chmod a+w $snpEff/data

# fastx
wget $FASTX_URL -O fastx.tar.bz2
echo -e "fastx=fastx" >> .DirName
if [ ! -d fastx ]; then
  mkdir fastx
fi
tar -xjvf fastx.tar.bz2 -C fastx

# install python-pip for variant annotation
# note python 2.7.3 on ubuntu 12.04
#      python 2.7.6 on ubuntu 14.04
# apt-get -y install python-pip
# pip install pylatex
apt-get install -y texlive-latex-base
# apt-get install -y texlive-binaries
apt-get install -y texlive-fonts-recommended # ecrm1000 error
apt-get install -y texlive-latex-extra # .sty files
apt-get install -y lmodern # lmodern.sty

# install r-base & rmarkdown
apt-get install -y r-base
R -e "install.packages('rmarkdown', repos='http://cran.rstudio.com')"

# install pandoc
wget $PANDOC_URL -O pandoc-amd64.deb
dpkg -i pandoc-amd64.deb

# instal lftp for accessing cosmic
apt-get install -y lftp

# clean up
rm *.zip *.tar.gz *.tar.bz2 *.deb

chown root:root -R /opt/SeqTools/*
chmod +x /opt/SeqTools/bin/FastQC/fastqc

echo
read -p "Press [Enter] key to quit."
