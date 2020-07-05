FROM rocker/r-ver:4.0.0
ENV RENV_VERSION 0.10.0
ENV CRAN_REPO https://packagemanager.rstudio.com/all/__linux__/focal/latest
ENV MINICONDA_INSTALLER Miniconda3-py38_4.8.3-Linux-x86_64.sh
# Copy the entirety of the context into the image. This should be the R package source.
ADD renv.lock /

# Install system dependencies. I couldn't get sysreqs to work here, since python-minimal
# isn't available on this implementation of rocker. Curl is required to download Miniconda.
RUN apt-get -y update && \
    apt-get install -y curl libgit2-dev libssl-dev zlib1g-dev \
    pandoc pandoc-citeproc make libxml2-dev libgmp-dev libgfortran4 \
    libcurl4-openssl-dev libssh2-1-dev libglpk-dev git-core

RUN Rscript -e "install.packages('remotes', repos = c(CRAN = Sys.getenv('CRAN_REPO')))"
RUN Rscript -e "remotes::install_github('rstudio/renv', ref = Sys.getenv('RENV_VERSION'))"
RUN Rscript -e "renv::restore(repos = c(CRAN = Sys.getenv('CRAN_REPO')))"

# Install miniconda to /miniconda and install mlflow
RUN curl -LO https://repo.anaconda.com/miniconda/$MINICONDA_INSTALLER
RUN bash $MINICONDA_INSTALLER -p /miniconda -b
RUN rm $MINICONDA_INSTALLER
ENV PATH=/miniconda/bin:${PATH}
RUN pip install mlflow
ENV MLFLOW_BIN /miniconda/bin/mlflow
ENV MLFLOW_PYTHON_BIN /miniconda/bin/python

ENTRYPOINT ["/usr/bin/env"]