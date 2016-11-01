#!/bin/bash

set -e

codename=$(lsb_release -s -c)
if [ $codename == "rafaela" ] || [ $codename == "rosa" ]; then
  codename="trusty"
fi

# For R
if [ -d ~/.gnupg ]; then
  chown -R root:root ~/.gnupg
fi
add-apt-repository "deb https://cran.rstudio.com/bin/linux/ubuntu $codename/"
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | apt-key add -

# update repository
apt-get update

# install r-base & rmarkdown
apt-get install -y r-base
R -e "install.packages('rmarkdown', repos='https://cran.rstudio.com')"

# download packages for samtools
apt-get -y install zlib1g-dev
apt-get -y install libncurses5-dev

echo
# read -p "Press [Enter] key to quit."
