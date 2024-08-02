
import requests, simplejson


class Falcon_Util:
    '''
    https://github.com/SDM-TIB/falcon2.0

    curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"text":"Who painted The Storm on the Sea of Galilee?"}' \
  https://labs.tib.eu/falcon/falcon2/api?mode=long

  https://labs.tib.eu/falcon/
    '''
    def __init__(self):

        self.Falcon2_API_URL = 'https://labs.tib.eu/falcon/falcon2/api?mode=long' # Wikidata
        self.Falcon1_API_URL = 'https://labs.tib.eu/falcon/api?mode=long' # DBpedia

    def call_to_Falcon1_API(self, text):
        return self.call_to_Falcon_API(text, 1)


    def call_to_Falcon2_API(self, text):
        return self.call_to_Falcon_API(text, 2)

    def call_to_Falcon_API(self, text, F_version):

        # data to be sent to api
        data = '{"text":"'+text+'"}'
        #data = '{"text":"Who painted The Storm on the Sea of Galilee?"}'
        if F_version == 2:
            api_url = self.Falcon2_API_URL
        else:
            api_url = self.Falcon1_API_URL
        headers = {'content-type': 'application/json', 'Accept-Charset': 'UTF-8'}
        try:
            response = requests.post(api_url, headers=headers, data=data)
        except requests.exceptions.RequestException as e:  # This is the correct syntax
            print("\nERROR: ", api_url + " - " + e.__str__())
            return {}
        try:
            response_data = response.json()
        except simplejson.scanner.JSONDecodeError:
            response_data = {}

        response.close()
        return response_data

    def _get_entity_link_from_result(self, res, field):
        e_link = ''
        if field in res:
            if len(res[field]):
                e_link = res[field][0].get('URI', '')
        return e_link

    def get_entity_link_from_result(self, res):
        e_link = ''
        # Falcon 1 - DBpedia
        e_link = self._get_entity_link_from_result(res, 'entities')
        # Falcon 2 - Wikidata
        if not e_link:
            e_link = self._get_entity_link_from_result(res, 'entities_wikidata')
        return e_link

    def get_wikidata_link_from_keyword(self, keyword_txt):
        wd_link_res = self.call_to_Falcon2_API(keyword_txt)
        wd_link = self.get_entity_link_from_result(wd_link_res)
        return wd_link

    def get_dbpedia_link_from_keyword(self, keyword_txt):
        wd_link_res = self.call_to_Falcon1_API(keyword_txt)
        wd_link = self.get_entity_link_from_result(wd_link_res)
        return wd_link

#headers = {'content-type': 'application/sparql-query', 'Accept-Charset': 'UTF-8'}
#         auth = (self.virtuosoUser, self.virtuosoPass)
#         data = sql
#
#         from requests.auth import HTTPBasicAuth
#
#         basic = HTTPBasicAuth('dba', 'mysecret')
#
#
#         try:
#             response = requests.post(self.virtuosoGraph+'/sparql-auth', headers=headers, auth=basic, data=data)