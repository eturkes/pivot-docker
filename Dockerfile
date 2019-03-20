# PIVOT-docker - Docker container for the PIVOT transcriptomics platform
# Copyright (C) 2019  Emir Turkes
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

FROM rocker/verse:3.5.3

COPY install.R /tmp/

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo \
        gdebi-core \
        pandoc \
        pandoc-citeproc \
        libcurl4-gnutls-dev \
        libcairo2-dev \
        libxt-dev \
        wget \
    && wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" \
    && VERSION=$(cat version.txt) \
    && wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb \
    && gdebi -n ss-latest.deb \
    && rm -f version.txt ss-latest.deb \
    && . /etc/environment \
    && R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" \
    && cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/ \
    && R -f /tmp/install.R \
    && apt-get clean \
    && rm -Rf /var/lib/apt/lists/ \
        /tmp/downloaded_packages/ \
        /tmp/*.rds \
        /tmp/install.R

COPY shiny-server.conf  /etc/shiny-server/
COPY PIVOT/inst/app/ /srv/shiny-server/
COPY shiny-server.sh /usr/bin/

EXPOSE 80

CMD ["/usr/bin/shiny-server.sh"]
