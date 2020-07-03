FROM rocker/r-ver:4.0.0
ENV RENV_VERSION 0.10.0
ENV CRAN_REPO https://packagemanager.rstudio.com/all/__linux__/bionic/latest
# Copy the entirety of the context into the image. This should be the R package source.
ADD . / /model-package/
WORKDIR /model-package

# Install system dependencies. I couldn't get sysreqs to work here, since python-minimal
# isn't available on this implementation of rocker. Curl is required to download Miniconda.
RUN apt-get -y update && \
    apt-get install -y curl libgit2-dev libssl-dev zlib1g-dev \
    pandoc pandoc-citeproc make libxml2-dev libgmp-dev \
    libcurl4-openssl-dev libssh2-1-dev libglpk-dev git-core

# renv::restore can be a bit buggy if .Rprofile and the renv directory exist
RUN rm -f .Rprofile
RUN rm -rf renv
RUN R -e "install.packages('remotes', repos = c(CRAN = Sys.getenv('CRAN_REPO')))"
RUN R -e "remotes::install_github('rstudio/renv', ref = Sys.getenv('RENV_VERSION'))"
RUN Rscript -e "renv::restore('/model-package', repos = c(CRAN = Sys.getenv('CRAN_REPO')))"

# Install miniconda to /miniconda and install mlflow
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN pip install mlflow

RUN Rscript -e "if (!require('devtools')) install.packages('devtools', repos = Sys.getenv('CRAN_REPO'))"
RUN Rscript -e "devtools::install('model-package', dependencies = FALSE)"
