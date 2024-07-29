FROM python:3.8
FROM jupyter/datascience-notebook:2022-08-01
# Build-time variables specified by docker-compose.yml / .env
ARG CKAN_STORAGE_PATH
ARG CKAN_SITE_URL

RUN python -m pip install --upgrade pip

USER root

# Create directories for nbextensions 
# and configuration original files
# ***********************************

RUN rm -r -f /jupyter_contrib_nbextensions
RUN mkdir -p /jupyter_contrib_nbextensions &&\
	mkdir -p /LDM_Notebooks_config
RUN chown -R `whoami` /jupyter_contrib_nbextensions &&\
#	chown -R `whoami` $CKAN_STORAGE_PATH/notebook &&\
	chown -R `whoami` /LDM_Notebooks_config
	
# Install Jupyternotebooks extensions
# ***********************************
#RUN pip install --upgrade ipykernel
RUN pip install jupyter-latex-envs
RUN git clone https://github.com/ipython-contrib/jupyter_contrib_nbextensions.git /jupyter_contrib_nbextensions
WORKDIR "/jupyter_contrib_nbextensions"
RUN git reset --hard 2248f6e15753d0eb4339215313ae21ba09cbdf74
ADD ./readonly /jupyter_contrib_nbextensions/src/jupyter_contrib_nbextensions/nbextensions/readonly
RUN pip install -e /jupyter_contrib_nbextensions

RUN jupyter contrib nbextension install --user

# Copy Jupyternotebooks configuration files
# *****************************************

ADD ./config_files /LDM_Notebooks_config/config_files

RUN cp /LDM_Notebooks_config/config_files/jupyter_nbconvert_config.json   /home/jovyan/.jupyter/jupyter_nbconvert_config.json
RUN cp /LDM_Notebooks_config/config_files/jupyter_notebook_config.json   /home/jovyan/.jupyter/jupyter_notebook_config.json
RUN cp /LDM_Notebooks_config/config_files/jupyter_notebook_config.py   /home/jovyan/.jupyter/jupyter_notebook_config.py
RUN cp /LDM_Notebooks_config/config_files/nbconfig/common.json   /home/jovyan/.jupyter/nbconfig/common.json
RUN cp /LDM_Notebooks_config/config_files/nbconfig/notebook.json   /home/jovyan/.jupyter/nbconfig/notebook.json
RUN cp /LDM_Notebooks_config/config_files/nbconfig/tree.json   /home/jovyan/.jupyter/nbconfig/tree.json


EXPOSE 8000

CMD ["jupyter","notebook"]