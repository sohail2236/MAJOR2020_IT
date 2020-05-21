#FROM rocker/shiny:3.5.1
FROM continuumio/miniconda3:4.5.11


#COPY ./* /
#WORKDIR /


RUN apt-get update -y; apt-get upgrade -y; \
    apt-get install -y vim-tiny vim-athena ssh \
    build-essential gcc gfortran g++



COPY environment.yml environment.yml
RUN conda env create -f environment.yml
RUN echo "alias l='ls -lah'" >> ~/.bashrc


RUN echo "source activate r-shiny" >> ~/.bashrc

ENV CONDA_EXE /opt/conda/bin/conda                                                                                                                                                                           
ENV CONDA_PREFIX /opt/conda/envs/r-shiny                                                                                                                                                                     
ENV CONDA_PYTHON_EXE /opt/conda/bin/python                                                                                                                                                                   
ENV CONDA_PROMPT_MODIFIER (r-shiny)                                                                                                                                                                          
ENV CONDA_DEFAULT_ENV r-shiny                                                                                                                                                                                
ENV PATH /opt/conda/envs/r-shiny/bin:/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin   


RUN apt-get update && apt-get install libcurl4-openssl-dev libv8-3.14-dev -y &&\
    mkdir -p /var/lib/shiny-server/bookmarks/shiny
RUN apt-get update && apt-get install libcurl4-openssl-dev libv8-3.14-dev -y &&\
  mkdir -p /var/lib/shiny-server/bookmarks/shiny
  
  
#RUN ln -s /usr/bin/python3 /usr/bin/python && \
    #ln -s /usr/bin/pip3 /usr/bin/pip
RUN apt-get update
RUN apt-get install -y libssl-dev                                                                                                                                                                            
RUN apt-get install -y libpython-dev                                                                                                                                                                         
RUN apt-get install -y libpython3-dev                                                                                                                                                                        
                                                                                                                                                                                                             
# Download and install library                                                                                                                                                                               
RUN R -e "install.packages(c('shinydashboard', 'shinyjs','httr', 'shiny', 'ggplot2', 'keras', 'dplyr', 'idx2r', 'chron', 'R.filesets'))"                                                                     
                                                                                                                                                                                                             
                                                                                                                                                                                                             
                                                                                                                                                                                                             
                                                                                                                                                                                                             
                                                                                                                                                                                                             
#mono install                                                                                                                                                                                                
RUN apt-get update                                                                                                                                                                                           
RUN apt-get install -y apt-transport-https ca-certificates gnupg                                                                                                                                             
#RUN apt install -y curl                                                                                                                                                                                     
RUN curl https://download.mono-project.com/repo/xamarin.gpg | apt-key add -                                                                                                                                  
RUN echo "deb https://download.mono-project.com/repo/debian stable-stretch main" |  tee /etc/apt/sources.list.d/mono-official-stable.list                                                                    
RUN apt-get update
RUN apt-get install -y mono-devel
#RUN apt-get install -y nohup

RUN apt-get install -y python3-pip  
RUN pip install -r requirements.txt
RUN nohup bash -c "python tornado_server.py > tornado.log" & sleep 7

COPY app.R  ./

RUN chmod 777 app.R

RUN R -e "keras::install_keras()"

#COPY Rprofile.site /usr/local/lib/R/etc/Rprofile.site

EXPOSE 3838

#CMD ["R", "-e", "shiny::runApp('app.R', port=3838)"]


CMD ["/bin/bash", "-c", "./app.R"]


##installing R and Rstudio
#RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
#RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
#RUN apt update
#RUN apt install -y r-base
#RUN apt install gdebi-core
