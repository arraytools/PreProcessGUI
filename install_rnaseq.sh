#!/bin/bash
#
# Installation script for SeqTools
#
# Note that there is a dependency issue. So getting the latest version may not work.
# For example, tophat v2.0.11 only supports bowtie2 v2.2.1 but not v2.2.2.

SRATOOLKIT_URL=https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.7.0/sratoolkit.2.7.0-ubuntu64.tar.gz
BWA_URL=https://github.com/lh3/bwa/archive/0.7.12.tar.gz
# BOWTIE2_URL=http://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.2.6/bowtie2-2.2.6-linux-x86_64.zip/download
BOWTIE2_URL=https://github.com/BenLangmead/bowtie2/releases/download/v2.2.6/bowtie2-2.2.6-linux-x86_64.zip
TOPHAT_URL=https://ccb.jhu.edu/software/tophat/downloads/tophat-2.1.0.Linux_x86_64.tar.gz
STAR_URL=https://github.com/alexdobin/STAR/archive/2.5.1b.tar.gz
# SAMTOOLS_URL=https://svwh.dl.sourceforge.net/project/samtools/samtools/1.3/samtools-1.3.tar.bz2
SAMTOOLS_URL=https://github.com/samtools/samtools/releases/download/1.3/samtools-1.3.tar.bz2
BCFTOOLS_URL=https://github.com/samtools/bcftools/releases/download/1.3/bcftools-1.3.tar.bz2
PICARD_URL=https://github.com/broadinstitute/picard/releases/download/1.141/picard-tools-1.141.zip
HTSEQ_URL=https://pypi.python.org/packages/3c/6e/f8dc3500933e036993645c3f854c4351c9028b180c6dcececde944022992/HTSeq-0.6.1p1.tar.gz#md5=c44d7b256281a8a53b6fe5beaeddd31c
FASTQC_URL=http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
FASTX_URL=http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
SNPEFF_URL=https://downloads.sourceforge.net/project/snpeff/snpEff_v4_2_core.zip
# SNPEFF_URL=https://github.com/pcingola/SnpEff/archive/v4.2.zip
JDK_URL=http://download.oracle.com/otn-pub/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz
PANDOC_URL=https://github.com/jgm/pandoc/releases/download/1.16.0.2/pandoc-1.16.0.2-1-amd64.deb
SUBREAD_URL=https://sourceforge.net/projects/subread/files/subread-1.5.2/subread-1.5.2-source.tar.gz

set -e
export DEBIAN_FRONTEND=noninteractive

# Support Mint Linux
codename=$(lsb_release -s -c)
if [ $codename == "rafaela" ] || [ $codename == "rosa" ]; then
  codename="trusty"
fi

# For R
echo step 1
# if [ -d ~/.gnupg ]; then
#   chown -R root:root ~/.gnupg
# fi
add-apt-repository "deb https://cran.rstudio.com/bin/linux/ubuntu $codename/"
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
# gpg --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
# gpg -a --export E084DAB9 | apt-key add -

# check if WSL is used
if grep -q -F 'Microsoft' /proc/version || \
   grep -q -F 'Microsoft' /proc/sys/kernel/osrelease; then
   os="Windows"
else
   os="Linux"
fi

echo step 2
if [[ "$os" == "Linux" ]]; then
  # For Java 8 on Ubuntu 14.04
  # jdk 8 is available on Ubuntu 16.04
  if [ $codename == "trusty" ]; then
    if find /etc/apt/sources.list.d/* -iname *.list | xargs cat | grep webupd8team; then
      echo ppa:webupd8team was found
    else
      add-apt-repository -y ppa:webupd8team/java
    fi
  fi
fi

# update repository
echo step 3
apt-get update

# download packages for samtools
echo step 4
apt-get -y install zlib1g-dev
echo step 5
apt-get -y install libncurses5-dev
# download packages for htseq-count
echo step 6
apt-get -y install build-essential python2.7-dev python-numpy python-matplotlib
echo step 7
apt-get -y install python-pip
echo step 8
sudo -H pip install pysam

# download Java for fastQC, gatk, picard and snpeff
echo step 9
if [[ "$os" == "Linux" ]]; then
  if [ $codename == "trusty" ]; then
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
    apt-get -y install oracle-java8-installer
  fi
  if [ $codename == "xenial" ]; then
    apt-get -y install openjdk-8-jdk
  fi
fi

# goodies for vc annotation
echo step 10
apt-get -y install parallel

# create a new directory
echo step 11
if [ ! -d /opt/SeqTools/bin ]; then
  mkdir -p /opt/SeqTools/bin
fi
cd /opt/SeqTools/bin

if [[ "$os" == "Windows" ]]; then
  # Windows 10 Anniversary update
  if [ $codename == "trusty" ]; then
    wget --header "Cookie: oraclelicense=accept-securebackup-cookie" $JDK_URL -O jdk-linux-x64.tar.gz
    if [ ! -d /opt/jdk ]; then
      mkdir /opt/jdk
    fi
    tar -zxvf jdk-linux-x64.tar.gz -C /opt/jdk
    dn=`tar -tf jdk-linux-x64.tar.gz | head -1 | cut -f1 -d"/"`
    update-alternatives --install /usr/bin/java java /opt/jdk/$dn/bin/java 100
    update-alternatives --install /usr/bin/javac javac /opt/jdk/$dn/bin/javac 100
  fi
  # Windows 10 Creators update
  if [ $codename == "xenial" ]; then
    apt-get -y install openjdk-8-jdk
  fi
fi

# bookmark the directory name for SeqTools
echo step 12
if [ -f .DirName ]; then
  rm .DirName
fi
touch .DirName

# sratoolkit
echo step 13
wget $SRATOOLKIT_URL -O sratoolkit.tar.gz
dn=`tar -tf sratoolkit.tar.gz | head -1 | cut -f1 -d"/"`
echo -e "sratoolkit=$dn" >> .DirName
tar xzvf sratoolkit.tar.gz

# BWA (needs to compile)
echo step 14
wget $BWA_URL -O BWA.tar.gz
dn=`tar -tf BWA.tar.gz | head -1 | cut -f1 -d"/"`
echo -e "bwa=$dn" >> .DirName
tar xzvf BWA.tar.gz
cd $dn
make
cd ..

# bowtie
echo step 15
if [ -f bowtie2.zip ]; then
  rm bowtie2.zip
fi
wget $BOWTIE2_URL -O bowtie2.zip
nline=$(unzip -vl bowtie2.zip | head | grep -n 'CRC-32' | sed 's/^\([0-9]\+\):.*$/\1/')
((nline+=2))
dn=`unzip -vl bowtie2.zip | sed -n "${nline}p" | awk '{print $8}'`
echo -e "bowtie=$(basename $dn)" >> .DirName
unzip -o bowtie2.zip

# tophat
echo step 16
wget $TOPHAT_URL -O tophat.tar.gz
dn=`tar -tf tophat.tar.gz | head -1 | cut -f1 -d"/"`
echo -e "tophat=$dn" >> .DirName
tar xzvf tophat.tar.gz

# star
echo step 17
wget $STAR_URL -O star.tar.gz
dn=`tar -tf star.tar.gz | head -1 | cut -f1 -d"/"`
echo -e "star=$dn" >> .DirName
tar xzvf star.tar.gz

# samtools (needs to compile)
echo step 18
wget $SAMTOOLS_URL -O samtools.tar.bz2
dn=`tar -tf samtools.tar.bz2 | head -1 | cut -f1 -d"/"`
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

# subread
echo step 19
wget $SUBREAD_URL -O subread.tar.gz
dn=`tar -tf subread.tar.gz | head -1 | cut -f1 -d"/"`
echo -e "subread=$dn" >> .DirName
tar xzvf subread.tar.gz
cd $dn/src
make -f Makefile.Linux
cd -

# bcftools (needs to compile)
echo step 20
wget $BCFTOOLS_URL -O bcftools.tar.bz2
dn=`tar -tf bcftools.tar.bz2 | head -1 | cut -f1 -d"/"`
echo -e "bcftools=$dn" >> .DirName
tar xjvf bcftools.tar.bz2
cd $dn
make
cd ..

# Picard tool
echo step 21
wget $PICARD_URL -O picard.zip
nline=$(unzip -vl picard.zip | head | grep -n 'CRC-32' | sed 's/^\([0-9]\+\):.*$/\1/')
((nline+=2))
dn=`unzip -vl picard.zip | sed -n "${nline}p" | awk '{print $8}'`
echo -e "picard=$(basename $dn)" >> .DirName
unzip -o picard.zip

# htseq-count (needs to compile)
echo step 22
wget $HTSEQ_URL -O HTSeq.tar.gz
tar xzvf HTSeq.tar.gz
dn=`tar -tf HTSeq.tar.gz | head -1 | cut -f1 -d"/"`
cd $dn
python setup.py build
python setup.py install
cd ..

# fastqc
echo step 23
if [ -f fastqc.zip ]; then
  rm fastqc.zip
fi
wget $FASTQC_URL -O fastqc.zip
echo -e "fastqc=FastQC" >> .DirName
unzip -o fastqc.zip

# snpeff
echo step 24
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
chmod a+w $snpEff/data

# fastx
echo step 25
wget $FASTX_URL -O fastx.tar.bz2
echo -e "trimmer=fastx" >> .DirName
if [ ! -d fastx ]; then
  mkdir fastx
fi
tar -xjvf fastx.tar.bz2 -C fastx

# install python-pip for variant annotation
# note python 2.7.3 on ubuntu 12.04
#      python 2.7.6 on ubuntu 14.04
# apt-get -y install python-pip
# pip install pylatex
echo step 26
apt-get install -y texlive-latex-base
# apt-get install -y texlive-binaries
echo step 27
apt-get install -y texlive-fonts-recommended # ecrm1000 error
echo step 28
apt-get install -y texlive-latex-extra # .sty files
echo step 29
apt-get install -y lmodern # lmodern.sty

# install r-base & rmarkdown
echo step 30
apt-get install -y r-base
R -e "install.packages('rmarkdown', repos='https://cran.rstudio.com')"

# install pandoc
echo step 31
if [[ "$os" == "Linux" ]]; then
  wget $PANDOC_URL -O pandoc-amd64.deb
  dpkg -i pandoc-amd64.deb
  rm pandoc-amd64.deb
fi

# instal lftp for accessing cosmic
echo step 32
apt-get install -y lftp

# install avfs for mounting compressed files
echo step 33
apt-get install -y avfs

# clean up
rm *.zip *.tar.gz *.tar.bz2

chown root:root -R /opt/SeqTools/*
chmod +x /opt/SeqTools/bin/FastQC/fastqc

# read -p "Press [Enter] key to quit."
