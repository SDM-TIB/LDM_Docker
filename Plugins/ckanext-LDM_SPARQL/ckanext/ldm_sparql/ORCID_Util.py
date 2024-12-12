
import requests
import xml.etree.ElementTree as ET

class ORCID_Util:

    def __init__(self):

        # SEARCH URL
        # Ex. https://pub.orcid.org/v3.0/search?q=family-name:Brunet+AND+given-names:Mauricio
        self.orcid_search_url = "https://pub.orcid.org/v3.0/search?q="

        self.search_options = []

    def _get_search_options(self, names_str):
        names = names_str.split(" ")
        search_options = []

        n_names = len(names)

        # Options for 2,3 and 4 names provides
        if n_names == 2:
            # Surname - Name
            search_options = [{"surname": names[0], "names": names[1]},
                                 # Name - Surname
                                 {"surname": names[1], "names": names[0]}
                                 ]
        elif n_names == 3:
            # Name1 - Name2 - Surname
            search_options = [{"surname": names[2], "names": names[0] + " " + names[1]},
                                 # Name - Surname1 - Surname2
                                 {"surname": names[1] + " " + names[2], "names": names[0]},
                                 # Surname - Name1 - Name2
                                 {"surname": names[0], "names": names[1] + " " + names[2]},
                                 # Surname1 - Surname2 - Name
                                 {"surname": names[0] + " " + names[1], "names": names[2]}
                                 ]
        elif n_names == 4:
            # Surname1 - Surname2 - Name1 - Name2
            search_options = [{"surname": names[0] + " " + names[1], "names": names[2] + " " + names[3]},
                                 # Name1 - Name2 - Surname1 - Surname2
                                 {"surname": names[2] + " " + names[3], "names": names[0] + " " + names[1]}
                                 ]
        return search_options

    def search_orcid(self, author):

        search_strings = self._get_search_strings(author)
        orcid = ""

        for s_str in search_strings:
            r = requests.get(s_str)
            root = ET.fromstring(r.content)

            n_results = count = sum(1 for _ in root.iter('{http://www.orcid.org/ns/common}uri'))
            if n_results == 1:
                for child in root.iter('{http://www.orcid.org/ns/common}uri'):
                    orcid = child.text
            if orcid:
                break

        return orcid

    def _get_search_strings(self, names_str):
        search_list = self._get_search_options(names_str)
        search_strings = []
        for item in search_list:
            if item:
                search_str = self.orcid_search_url + 'family-name:' + item['surname'] + '+AND+given-names:' + item['names']
                search_strings.append(search_str)
        return search_strings
