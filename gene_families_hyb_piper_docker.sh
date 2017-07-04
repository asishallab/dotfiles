FROM debian:stretch

MAINTAINER Dr. Asis Hallab <asis.hallab@gmail.com>

# update debian package list
RUN apt-get update

# install R and java
RUN apt-get install -y r-base openjdk-8-jre openjdk-8-jdk

# install personal packages
RUN apt-get install -y ssh zsh tmux python-pip virtualenvwrapper curl sudo \
  locales locate less wget git exuberant-ctags

# install indispensable packages
RUN apt-get install -y mcl fasttree mafft ncbi-blast+ wget hyphy-mpi \
  libssl-dev libcurl4-openssl-dev libxml2-dev python3 exonerate spades \
  parallel bwa samtools time

# install Biopython
RUN pip install biopython

# Accept licence of GNU parallel
RUN echo 'will cite' | parallel --bibtex 

# install HybPiper
RUN git clone https://github.com/mossmatters/HybPiper.git /opt/HybPiper 
RUN cp /opt/HybPiper/*.py /usr/local/bin
RUN rm -rf /opt/HybPiper


# add Debian sid repo 
RUN echo 'deb http://deb.debian.org/debian sid main' >>  /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y diamond-aligner/unstable paml/unstable neovim/unstable
RUN apt-get clean


# install CAFE
RUN wget -O /opt/cafe https://downloads.sourceforge.net/project/cafehahnlab/cafe.linux.x86_64  
RUN chmod +x /opt/cafe 
RUN cp /opt/cafe /usr/local/bin/

# download, compile and install Blat
RUN wget -O /opt/blatSrc35.zip https://users.soe.ucsc.edu/~kent/src/blatSrc35.zip
RUN unzip /opt/blatSrc35.zip -d /opt/blatSrc

ENV MACHTYPE x86_64
RUN mkdir -p /root/bin/$MACHTYPE/ 
RUN make -C /opt/blatSrc/blatSrc
RUN cp /root/bin/$MACHTYPE/* /usr/local/bin/
RUN rm -rf /root/bin

# install and configure locales
RUN apt-get install -y locales
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale

RUN dpkg-reconfigure --frontend=noninteractive locales
RUN update-locale LANG=en_US.UTF-8

# regular user env
RUN su - -c 'sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"'
RUN su - -c 'wget -O /root/dotfiles.zip https://github.com/asishallab/dotfiles/archive/gene_families.zip'
RUN su - -c 'unzip /root/dotfiles.zip -d /root/'
RUN su - -c 'ln -fs /root/dotfiles-gene_families/.zshrc /root'
RUN su - -c 'ln -fs /root/dotfiles-gene_families/.tmux.conf /root'
RUN su - -c 'ln -fs /root/dotfiles-gene_families/.ctags /root'

# install R packages
RUN su - -c 'mkdir /root/R_libs'
ENV R_LIBS '/root/R_libs'
ENV R_LIBS_USER '/root/R_libs'
RUN su - -c 'wget -O /root/install_GeneFamilies.R https://raw.githubusercontent.com/asishallab/GeneFamilies/master/exec/install_script.R'
RUN su - -c 'R -f /root/install_GeneFamilies.R'
RUN echo 'install.packages("roxygen2", repos="http://cran.us.r-project.org"); install.packages("formatR", repos="http://cran.us.r-project.org");' > /root/install_R_pkgs.R
RUN su - -c 'R -f /root/install_R_pkgs.R'
RUN su - -c 'rm /root/install_GeneFamilies.R'

# we love neovim
RUN su - -c 'source /usr/share/virtualenvwrapper/virtualenvwrapper.sh && mkvirtualenv neovim && pip install neovim'
RUN su - -c 'mkdir -p /root/.nvim/tmp/backup'
RUN su - -c 'mkdir /root/.config'
RUN su - -c 'wget -O /tmp/nvim_conf.zip https://github.com/asishallab/neovim_config/archive/master.zip'
RUN su - -c 'unzip /tmp/nvim_conf.zip -d /tmp'
RUN su - -c 'cp -r /tmp/neovim_config-master /root/.config/nvim'
#RUN su - -c 'nvim -c ":PlugInstall | :qa" > /dev/null'

# allow root login
RUN echo 'root:poiuyt098' | chpasswd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# run ssh server
RUN mkdir /var/run/sshd
EXPOSE 22
CMD /usr/sbin/sshd -D

RUN echo "DONE"
