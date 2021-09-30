FROM solr:8
MAINTAINER Open Knowledge

RUN echo "Config Solr"

# Adding Files
ADD ./solr8/config/* /var/solr/data/

# SetUp EntryPoint
COPY ./solr8/solr-entrypoint.sh /var/solr/data/
ENTRYPOINT ["sh", "/var/solr/data/solr-entrypoint.sh"]
