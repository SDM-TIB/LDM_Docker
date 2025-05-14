import urllib.parse
from xml.etree import ElementTree

import requests
from ckanext.tibimport.logic2 import DatasetParser
import json

import time
# pip install selenium webdriver-manager
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import requests
import copy
import traceback

from ckanext.tibimport.open_licenses import open_access_licenses
class LEUPHANA_ParserProfile(DatasetParser):
    '''

    A class defined to access leuphana's Datasets
    using the leuphana's harvesting tool https://pubdata.leuphana.de/oai and parsing the retrieved
    data to dataset_dic as needed by the LDM
    In the particular case of Leuphana not all the needed metadata is present in the results of the harvesting tool, 
    then the approach is to collect the ids for the harvesting tool and search for more metadata for each Dataset in
    the leuphana's website (https://pubdata.leuphana.de/).
    Requirement: import only Datasets and only open (free to access).
    leuphana Harvesting tool docs: https://www.openarchives.org/OAI/openarchivesprotocol.html

    '''

    def __init__(self):
        self.repository_name = "leuphana (The repository of the Leuphana University Lüneburg)"
        self.dataset_title_prefix = "leu-"
        # Ex. https://pubdata.leuphana.de/oai/request?verb=ListRecords&metadataPrefix=oai_dc&set=com_123456789_3
        # This url retrieves all identifiers for Research data (Forschungsdaten), Datasets and others, open or not
        self.leuphana_ListRecords_url = 'https://pubdata.leuphana.de/oai/request?verb=ListRecords'
        
        # REQUIREMENT: import only Datasets and only open (free to access): 
        # Harverster not allowing sets, filtering should be managed programatically 
        self.leuphana_metadata_schema_response = 'oai_dc'
        self.leuphana_metadata_schema_response_prefix = '&metadataPrefix=' + self.leuphana_metadata_schema_response
       
        self.leuphana_ListRecords_url_first_time = self.leuphana_ListRecords_url + self.leuphana_metadata_schema_response_prefix
        # The following set filter for Research Data (Forschungsdaten)
        self.leuphana_ListRecords_url_first_time += '&set=com_123456789_3'

        # URL for searching metadata in leuphana's website
        self.search_metadata_in_website_url = "https://pubdata.leuphana.de/exportjsonld?handle="

        self.current_dataset_schema = "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd"        
        
        # Schema values
        self.ns0 = '{http://www.openarchives.org/OAI/2.0/}'
        self.ns2 = '{http://www.openarchives.org/OAI/2.0/oai_dc/}'
        self.ns3 = '{http://purl.org/dc/elements/1.1/}'

        # Set to True to force update of all datasets
        self.force_update = False

        # Total of datasets available in leuphana
        self.total_leuphana_datasets = 0

        # schema validation report
        self.current_schema_report = {}


        self.log_file_prefix = "LEU_"
        super().__init__()


    def get_all_datasets_dicts(self):
        '''
             Using leuphana's "ListRecords" list get a list of dictionaries with the complete Dataset's
             metadata inside.
             Notice: "ListRecords" retrieves results in XML format and by blocks (pages). Uses "ResumptionToken" to
             continue listing the following records.
             Notice: Dataset's dictionaries must be adapted to CKAN schema

             Returns: an array of  dictionary with the list of datasets or an empty array
        '''

        ds_list = []
        ds_list = self.get_datasets_list()


        dict_list = []
        for dataset in ds_list:
            #dict_list.append(self.parse_leuphana_RECORD_DICT_to_LDM_CKAN_DICT(dataset))
            dict_list.append(dataset)

        return dict_list

    def get_datasets_list(self, ds_list=[], resumption_token=''):
        '''
            Uses the leuphana HARVESTING TOOL to retrieve a list of datasets in a list of dictionaries

            Returns: a list of datasets or an empty list
            Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")

        if not resumption_token:
            # Find first page of Datasets
            url = self.leuphana_ListRecords_url_first_time

        else:
            # Find page from resumption token url
            url = self.leuphana_ListRecords_url+'&resumptionToken=' + resumption_token
        # print("\nURL\n", url)

        # Find page of Datasets
        try:
            response = requests.get(url)
        except requests.exceptions.RequestException as e:  
            self.set_log("error_API", url + " - " + e.__str__())
            return []

        if not response.ok:
            self.set_log("error_api_data", url)
            return []
        xml_tree_data = ElementTree.fromstring(response.content)
        
        # Check for OAI-PMH error
        error = xml_tree_data.find(self.ns0 + 'error')
        if error is not None:
            self.set_log("error_api_data", f"{url} - {error.text}")
            return []

        # get schema data only first time
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report(xml_tree_data)

        if ds_list:
            ds_list.extend(self.parse_leuphana_XML_result_to_DICT(xml_tree_data))
        else:
            ds_list = self.parse_leuphana_XML_result_to_DICT(xml_tree_data)

        
        # GET RESUMPTION TOKEN FROM xml_tree_data
        resumption_token = self._get_leuphana_resumption_token(xml_tree_data)

        if resumption_token['resumptionToken']:
            #print("\nRT:\n", resumption_token)
            self.get_datasets_list(ds_list, resumption_token['resumptionToken'])

        # Filter responses to type "Dataset"
        ds_list = self.filter_dataset_type(ds_list)
        
        # Search for metadata in Leuphana website
        ds_list = self.fetch_multiple_json_data(ds_list)
        
        # Filter responses to open Datasets
        ds_list = self.filter_open_datasets(ds_list)
        
        # Update total of Datasets
        self.total_leuphana_datasets = len(ds_list)
        return ds_list

    def _get_page_of_Datasets(self, url):

        obj_tree = None

        # Find page of Datasets
        try:
            response = requests.get(url)
        except requests.exceptions.RequestException as e:
            self.set_log("error_API", url + " - " + e.__str__())

        if not response.ok:
            self.set_log("error_api_data", url)
        else:
            obj_tree = ElementTree.fromstring(response.content)
        return  obj_tree

    def get_remote_datasets_paged(self, resumption_token=''):
        '''
         Uses the leuphana HARVESTING TOOL to retrieve a list of datasets in a list of dictionaries
         Returns: a list of datasets or an empty list
         Notice: the dictionaries contains metadata NOT in CKAN's schema
        '''
        self.set_log("infos_searching_ds")

        if not resumption_token:
            # Find first page of Datasets
            url = self.leuphana_ListRecords_url

        else:
            # Find page from resumption token url
            url = self.leuphana_ListRecords_url+'&resumptionToken=' + resumption_token

        # Find page of Datasets
        xml_tree_data = self._get_page_of_Datasets(url)
        if xml_tree_data is None:
            return []

        # get schema data only first time
        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report(xml_tree_data)

        ds_list = self.parse_leuphana_XML_result_to_DICT(xml_tree_data)
        # Filter responses to type "Dataset"
        ds_list = self.filter_dataset_type(ds_list)
        
        # Search for metadata in Leuphana website
        ds_list = self.fetch_multiple_json_data(ds_list)
        
        # Filter responses to open Datasets
        ds_list = self.filter_open_datasets(ds_list)

        # Update total of Datasets
        self.total_leuphana_datasets += len(ds_list)
        
        # GET RESUMPTION TOKEN FROM xml_tree_data
        resumption_token = self._get_leuphana_resumption_token(xml_tree_data)

        # Convert dics to LDM-CKAN dicts
        dict_list = []
        for dataset in ds_list:
            dict_list.append(self.parse_leuphana_RECORD_DICT_to_LDM_CKAN_DICT(dataset))

        return {"ds_list": dict_list, "resumptionToken": resumption_token['resumptionToken']}

    def _get_leuphana_resumption_token(self, xml_tree_data):
        r_token = {'resumptionToken': ''}

        for record in xml_tree_data.iter(self.ns0 + 'resumptionToken'):
            if record.text:
                r_token['resumptionToken'] = record.text
                r_token.update(record.attrib)

        if 'completeListSize' in r_token:
            self.total_leuphana_datasets = int(r_token['completeListSize'])

        return r_token

    def is_open_dataset(self, ds_dict):
        # header': {'json_ld': {'license': ['https://creativecommons.org/licenses/by/4.0/legalcode']}} 
        license_list = ds_dict.get('header', {}).get('json_ld', {}).get('license', [])
        is_open = False
        for license in license_list:
            if 'creativecommons.org' in license or 'opendatacommons.org' in license:
                is_open = True
        return is_open

    def is_dataset_type(self, ds_dict):
         # type_list = 'resourceType': [{'type': {'type': 'Dataset'}}]}}}
        ds_types = ds_dict.get('metadata', {}).get('leuphanaDataset', {}).get('resourceType', [])
        for ds_type in ds_types:
            if 'Dataset' in ds_type['type']['type']:
                return True
        #print("\nFALSE DS TYPE:\n", ds_dict)    
        return False

    def filter_dataset_type(self, ds_list):
        ds_list_result = []
        
        for dataset in ds_list:
            if self.is_dataset_type(dataset):
                ds_list_result.append(dataset)
        return ds_list_result   
        
    def filter_open_datasets(self, ds_list):
        
        ds_list_result = []
        
        for dataset in ds_list:
            if self.is_open_dataset(dataset):
                ds_list_result.append(dataset)
        return ds_list_result   

    def parse_leuphana_XML_result_to_DICT(self, xml_tree_data):

        ds_result = []

        for record in xml_tree_data.iter(self.ns0 + 'record'):
            ds_result.append(self.parse_leuphana_XML_RECORD_to_DICT(record))
        
        return ds_result








    def fetch_multiple_json_data(self, datasets_list):
        """
        Takes a list of dataset dictionaries, retrieves JSON data for each identifier,
        and populates the json_ld field in each dictionary.
        
        Args:
            datasets_list (list): List of dictionaries with Dataset information
                [{'header': {'identifier': '20.500.14123/xxx', 'datestamp': '...', 'json_ld': ''}}]
            
        Returns:
            list: The same list with json_ld fields populated where data was successfully retrieved or empty dict in json_ld
        """
        # Create a deep copy to avoid modifying the original
        result_datasets = copy.deepcopy(datasets_list)
        
        # Setup headless Chrome browser
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        
        driver = None
        try:
            # Initialize the browser (only once for all requests)
            print("Initializing browser...")
            # Use try/except for the driver initialization
            try:
                driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
            except Exception as driver_error:
                self.set_log('error_searching_website', f"Error initializing Chrome driver: {driver_error}")
                # Try an alternative approach if the first fails
                try:
                    driver = webdriver.Chrome(options=chrome_options)
                except Exception as alt_error:
                    self.set_log('error_searching_website', f"Alternative driver initialization also failed: {alt_error}")
                    return result_datasets  # Return the original list if we can't initialize a browser
            
            if not driver:
                self.set_log('error_searching_website', "Failed to initialize browser, returning original dataset list")
                return result_datasets
                
            # Create a session for requests
            session = requests.Session()
            
            # Process each dataset
            for i, dataset_item in enumerate(result_datasets):
                try:
                    # Safely extract the identifier
                    if 'header' not in dataset_item:
                        self.set_log('error_searching_website', f"Warning: Item at index {i} does not have a 'Dataset' key")
                        continue
                        
                    dataset = dataset_item['header']
                    if 'identifier' not in dataset:
                        self.set_log('error_searching_website', f"Warning: Dataset at index {i} does not have an 'identifier' key")
                        continue
                        
                    identifier = dataset['identifier']
                    self.set_log_info(f"\nProcessing dataset {i+1}/{len(result_datasets)}: {identifier}")
                    
                    # Visit the handle page
                    handle_url = f"https://pubdata.leuphana.de/handle/{identifier}"
                    self.set_log_info(f"Visiting handle page: {handle_url}")
                    driver.get(handle_url)
                    
                    # Wait for page to load completely
                    time.sleep(3)
                    
                    # Check if we're on the correct page
                    if "Access denied" in driver.page_source or "Forbidden" in driver.page_source:
                        self.set_log('error_searching_website', "Access denied or forbidden error encountered on the handle page")
                        continue
                    
                    # Get all cookies from the browser
                    selenium_cookies = driver.get_cookies()
                    self.set_log_info(f"Got {len(selenium_cookies)} cookies from browser")
                    
                    # Update session cookies
                    session.cookies.clear()
                    for cookie in selenium_cookies:
                        session.cookies.set(cookie['name'], cookie['value'])
                    
                    # Add headers from the browser
                    headers = {
                        'User-Agent': driver.execute_script("return navigator.userAgent"),
                        'Accept': 'application/json, text/javascript, */*; q=0.01',
                        'Accept-Language': 'en-US,en;q=0.9',
                        'Referer': handle_url,
                        'X-Requested-With': 'XMLHttpRequest',
                        'Connection': 'keep-alive',
                        'Sec-Fetch-Dest': 'empty',
                        'Sec-Fetch-Mode': 'cors',
                        'Sec-Fetch-Site': 'same-origin',
                    }
                    
                    # Request the JSON data with the authenticated session
                    json_url = f"https://pubdata.leuphana.de/exportjsonld?handle={identifier}"
                    self.set_log_info(f"Requesting JSON data: {json_url}")
                    
                    json_data = None
                    
                    try:
                        response = session.get(json_url, headers=headers, timeout=15)
                        
                        # Check if the request was successful
                        if response.status_code == 200:
                            try:
                                # Parse JSON response into a Python dictionary
                                json_data = json.loads(response.text)
                            except json.JSONDecodeError as e:
                                self.set_log('error_searching_website', f"Error decoding JSON: {e}")
                        else:
                            self.set_log('error_searching_website', f"Error: Received status code {response.status_code}")
                    except requests.RequestException as e:
                        self.set_log('error_searching_website', f"Request exception: {e}")
                    
                    # If requests method failed, try browser directly
                    if not json_data:
                        try:
                            self.set_log_info("Trying direct browser access...")
                            driver.get(json_url)
                            time.sleep(2)
                            
                            # Try to extract JSON from page source
                            page_source = driver.page_source
                            if page_source:
                                # Clean up the page source if it contains HTML
                                if "<body>" in page_source and "</body>" in page_source:
                                    page_source = page_source.split("<body>")[1].split("</body>")[0].strip()
                                    
                                # Try to parse as JSON
                                try:
                                    json_data = json.loads(page_source)
                                except json.JSONDecodeError:
                                    self.set_log('error_searching_website', "Failed to parse page source as JSON")
                        except Exception as browser_error:
                            self.set_log('error_searching_website', f"Error with direct browser access: {browser_error}")
                    
                    # Update the json_ld field if we got data
                    if json_data:
                        result_datasets[i]['header']['json_ld'] = json_data
                        self.set_log_info(f"Successfully retrieved JSON data for {identifier}")
                    else:
                        result_datasets[i]['header']['json_ld'] = {}
                        self.set_log('error_searching_website', f"Failed to retrieve JSON data for {identifier}")
                    
                except Exception as e:
                    self.set_log('error_searching_website', f"Error processing dataset at index {i}:")
                    self.set_log('error_searching_website', traceback.format_exc())  # Print full traceback for debugging
                    
            # Return the updated list
            return result_datasets
            
        except Exception as e:
            self.set_log('error_searching_website', f"Unexpected error in main process: {e}")
            self.set_log('error_searching_website', traceback.format_exc())  # Print full traceback for debugging
            return result_datasets
        finally:
            # Always close the browser
            if driver:
                try:
                    driver.quit()
                    self.set_log_info("Browser closed")
                except Exception as close_error:
                    self.set_log('error_searching_website', f"Error closing browser: {close_error}")
                    

    # def fetch_json_data(self, id):
    #     """
    #     Retrieves JSON data by first visiting the handle page with Selenium to establish
    #     authentication, then using the authenticated cookies to request the JSON data.
        
    #     Args:
    #         id (str): The identifier to be used in the URL, e.g., "20.500.14123/167"
            
    #     Returns:
    #         dict: Python dictionary containing the JSON data if successful, or an empty string in case of error
    #     """
    #     import json

    #     try:
    #         # Setup headless Chrome browser
    #         chrome_options = Options()
    #         chrome_options.add_argument("--headless")
    #         chrome_options.add_argument("--no-sandbox")
    #         chrome_options.add_argument("--disable-dev-shm-usage")
    #         chrome_options.add_argument("--disable-gpu")
    #         chrome_options.add_argument("--window-size=1920,1080")
    #         chrome_options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
            
    #         # Initialize the browser
    #         print("Initializing browser...")
    #         driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=chrome_options)
            
    #         try:
    #             # Visit the handle page
    #             handle_url = f"https://pubdata.leuphana.de/handle/{id}"
    #             print(f"Visiting handle page: {handle_url}")
    #             driver.get(handle_url)
                
    #             # Wait for page to load completely
    #             time.sleep(5)
                
    #             # Check if we're on the correct page
    #             if "Access denied" in driver.page_source or "Forbidden" in driver.page_source:
    #                 print("Access denied or forbidden error encountered on the handle page")
    #                 return ""
                
    #             # Get all cookies from the browser
    #             selenium_cookies = driver.get_cookies()
    #             print(f"Got {len(selenium_cookies)} cookies from browser")
                
    #             # Create a requests session and add the cookies
    #             session = requests.Session()
    #             for cookie in selenium_cookies:
    #                 session.cookies.set(cookie['name'], cookie['value'])
                
    #             # Add headers from the browser
    #             headers = {
    #                 'User-Agent': driver.execute_script("return navigator.userAgent"),
    #                 'Accept': 'application/json, text/javascript, */*; q=0.01',
    #                 'Accept-Language': 'en-US,en;q=0.9',
    #                 'Referer': handle_url,
    #                 'X-Requested-With': 'XMLHttpRequest',
    #                 'Connection': 'keep-alive',
    #                 'Sec-Fetch-Dest': 'empty',
    #                 'Sec-Fetch-Mode': 'cors',
    #                 'Sec-Fetch-Site': 'same-origin',
    #             }
                
    #             # Check if there are any additional tokens we need to extract from the page
    #             # Uncomment and modify if needed:
    #             # csrf_token = driver.execute_script("return document.querySelector('meta[name=\"csrf-token\"]').getAttribute('content')")
    #             # if csrf_token:
    #             #     headers['X-CSRF-Token'] = csrf_token
                
    #             # Now request the JSON data with the authenticated session
    #             json_url = f"https://pubdata.leuphana.de/exportjsonld?handle={id}"
    #             print(f"Requesting JSON data: {json_url}")
                
    #             response = session.get(json_url, headers=headers, timeout=15)
                
    #             # Check if the request was successful
    #             if response.status_code == 200:
    #                 try:
    #                     # Parse JSON response into a Python dictionary
    #                     json_data = json.loads(response.text)
    #                     return json_data
    #                 except json.JSONDecodeError as e:
    #                     print(f"Error decoding JSON: {e}")
    #                     # If we can't decode the JSON, try using the browser to get it directly
    #                     try:
    #                         print("Trying to fetch JSON directly with browser...")
    #                         driver.get(json_url)
    #                         json_text = driver.page_source
    #                         # Extract just the JSON part from the HTML
    #                         if "<body>" in json_text and "</body>" in json_text:
    #                             json_text = json_text.split("<body>")[1].split("</body>")[0].strip()
    #                         json_data = json.loads(json_text)
    #                         return json_data
    #                     except Exception as e:
    #                         print(f"Error fetching JSON with browser: {e}")
    #                         return ""
    #             else:
    #                 print(f"Error: Received status code {response.status_code}")
    #                 print(f"Response text: {response.text[:200]}...")  # Print first 200 chars of response
                    
    #                 # Try direct browser approach as a fallback
    #                 try:
    #                     print("Trying direct browser access as fallback...")
    #                     driver.get(json_url)
    #                     time.sleep(3)
                        
    #                     if "application/json" in driver.execute_script("return document.contentType"):
    #                         json_text = driver.page_source
    #                         if "<body>" in json_text and "</body>" in json_text:
    #                             json_text = json_text.split("<body>")[1].split("</body>")[0].strip()
    #                         json_data = json.loads(json_text)
    #                         return json_data
    #                     else:
    #                         print(f"Direct browser access failed, content type not JSON")
    #                         return ""
    #                 except Exception as e:
    #                     print(f"Error with direct browser access: {e}")
    #                     return ""
    #         finally:
    #             # Always close the browser
    #             driver.quit()
                
    #     except Exception as e:
    #         print(f"Unexpected error: {e}")
    #         return ""

    
    # def get_json_ld_from_leuphana_website(self, dataset_id):
    #     """
    #     Retrieves JSON data from a URL constructed with the provided ID and converts it to a Python dictionary.
        
    #     Args:
    #         id (str): The identifier to be used in the URL, e.g., "20.500.14123/248"
            
    #     Returns:
    #         dict: Python dictionary containing the JSON data if successful, or an empty string in case of error
    #     """
    #     try:
    #         # Construct the URL with the provided ID
    #         url = f"https://pubdata.leuphana.de/exportjsonld?handle={dataset_id}"
            
    #         # Send a GET request to the URL
    #         response = requests.get(url, timeout=10)
            
    #         # Check if the request was successful
    #         if response.status_code == 200:
    #             try:
    #                 # Parse JSON response into a Python dictionary
    #                 json_data = json.loads(response.text)
    #                 return json_data
    #             except json.JSONDecodeError as e:
    #                 # Handle invalid JSON
    #                 self.set_log('error_searching_website', str(e))
    #                 return ""
    #         else:
    #             # If status code is not 200, return an empty string
    #             self.set_log('error_searching_website', str(response.status_code))
    #             print("\nURL\n:", url)
    #             return ""
            
    #     except requests.RequestException as e:
    #         # Handle any exceptions that occur during the request
    #         self.set_log('error_searching_website', str(e))
    #         return ""
    #     except Exception as e:
    #         # Handle any other exceptions
    #         self.set_log('error_searching_website', str(e))
    #         return ""


    def parse_leuphana_XML_RECORD_to_DICT(self, xml_tree_obj):

        record = xml_tree_obj
        # print("\n\n\nRECORD:\n", xml_tree_obj)
        tags = [elem.tag for elem in xml_tree_obj.iter()]
        print("\n\ntags\n", tags)
        
        ns0 = self.ns0
        ns2 = self.ns2
        ns3 = self.ns3

        #  ['{http://www.openarchives.org/OAI/2.0/}record', 
        #     '{http://www.openarchives.org/OAI/2.0/}header', 
        #         '{http://www.openarchives.org/OAI/2.0/}identifier', 
        #         '{http://www.openarchives.org/OAI/2.0/}datestamp', 
        #         '{http://www.openarchives.org/OAI/2.0/}setSpec', 
        #      '{http://www.openarchives.org/OAI/2.0/}metadata', 
        #         '{http://www.openarchives.org/OAI/2.0/oai_dc/}dc', 
        #                       '{http://purl.org/dc/elements/1.1/}title', 
        #                       '{http://purl.org/dc/elements/1.1/}creator', 
        #                       '{http://purl.org/dc/elements/1.1/}date', 
        #                       '{http://purl.org/dc/elements/1.1/}type', 
        #                       '{http://purl.org/dc/elements/1.1/}identifier', 
        #                       '{http://purl.org/dc/elements/1.1/}format']

        ds_result = {}

        # HEADER
        # <ns0:record>
        #   <ns0:header>
        #       <identifier>oai:doi:10.26249/FK2/48FTWW</identifier>
        #       <datestamp>2024-07-12T00:00:00Z</datestamp>
        #   </ns0:header>
        identifier = record.find('./' + ns0 + 'header/' + ns0 + 'identifier').text
        identifier = identifier.replace('oai:pubdata.leuphana.de:', '')
        datestamp = record.find('./' + ns0 + 'header/' + ns0 + 'datestamp').text
        ds_result['header'] = {'identifier': identifier, 'datestamp': datestamp}
       
        # <ns0:metadata><ns2:leoPARDDataset>
        ds_result['metadata'] = {'leuphanaDataset': {}}

        # METADATA MANDATORY
        
        # METADATA - IDENTIFIER
        ds_result['metadata']['leuphanaDataset']['identifier'] = identifier


        # METADATA - CREATORS
        # <metadata>
        #   <ns2:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:doc="http://www.lyncode.com/xoai" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
        #       <ns3:creator>{"affiliationIdentifierRor":["02w2y2t16"],"organizationName":[""],"ror":[""],"affiliation":["Institut für Nachhaltige Chemie (INSC), Leuphana Universität Lüneburg"],"givenName":["Ann-Kathrin"],"familyName":["Amsel"],"orcid":["0000-0003-1097-4063"],"authorityType":["Person"]}
        #       </ns3parse_json_string:creator>
        #   </ns2:dc>

        path_from_leuphanadataset = ns3 + 'creator'
        subfields = []
        ds_result['metadata']['leuphanaDataset']['creators'] = self._find_metadata_in_record(record, path_from_leuphanadataset, 'creator', subfields)
        # adjust creators content
        creator_list = []
        for creator in ds_result['metadata']['leuphanaDataset']['creators']:
            print("\n\nFIELD:", str(creator['creator']['creator']))
            creator_dict = json.loads(creator['creator']['creator'])
            creator_list.append(creator_dict)
        ds_result['metadata']['leuphanaDataset']['creators'] = creator_list   
        
        # METADATA TITLES
        # <metadata>
        #   <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:doc="http://www.lyncode.com/xoai" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
        #       <dc:title>Studies on biodegradability of ionic liquids_categorised according to methods, 2020, V1</dc:title>
        path_from_leuphanadataset = ns3 + 'title'
        subfields = []
        ds_result['metadata']['leuphanaDataset']['titles'] = self._find_metadata_in_record(record, path_from_leuphanadataset, 'title', subfields)

        # METADATA RESOURCE TYPE
        # <metadata>
        #   <oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:doc="http://www.lyncode.com/xoai" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
        #     <dc:type>Dataset</dc:type>
        path_from_leuphanadataset = ns3 + 'type'
        subfields = []
        ds_result['metadata']['leuphanaDataset']['resourceType'] = self._find_metadata_in_record(record,
                                                                                          path_from_leuphanadataset, 'type', subfields)       

    #     # METADATA PUBLISHER
    #     #     <publisher>leuphana</publisher>
    #     path_from_leuphanadataset = ns2 + 'publisher'
    #     ds_result['metadata']['leuphanaDataset']['publisher'] = self._find_metadata_in_record_simple(record,
    #                                                                                         path_from_leuphanadataset)
                                                                                                                                  
       
    #     # METADATA - PUBLICATION YEAR
    #     #     <publicationYear>2024</publicationYear>
    #     path_from_leuphanadataset = ns2 + 'publicationYear'
    #     ds_result['metadata']['leuphanaDataset']['publicationYear'] = self._find_metadata_in_record_simple(record,
    #                                                                                                     path_from_leuphanadataset)

    #     # METADATA SUBJECT AREAS
    #     # <subjects>
    #     #   <subject>Social Sciences</subject>
    #     #   <subject>Lehrerbildung</subject>
    #     #   <subject>Lehramtsstudium</subject>
    #     # </subjects>
    #     subfields = []
    #     path_from_leuphanadataset = ns2 + 'subjects/' + ns2 + 'subject'
    #     ds_result['metadata']['leuphanaDataset']['subjectAreas'] = self._find_metadata_in_record(record,
    #                                                                                           path_from_leuphanadataset,
    #                                                                                           'subject', subfields)


                                                                                     
                                                                                   
    #     # METADATA RIGHTS
    #     # <rightsList>
    #     #      <rights rightsURI="info:eu-repo/semantics/openAccess"/>
    #     #      <rights rightsURI="https://creativecommons.org/publicdomain/zero/1.0/">CC0 Waiver</rights>
    #     # </rightsList>
    #     subfields = [ns2 + 'rightsList', ns2 + 'rights']
    #     path_from_leuphanadataset = ns2 + 'rightsList'
    #     ds_result['metadata']['leuphanaDataset']['rightsList'] = self._find_metadata_in_record(record,
    #                                                                                     path_from_leuphanadataset,
    #                                                                                     'rights', subfields)
        
    # # OPTIONAL METADATA
    #     # METADATA - DESCRIPTIONS
    #     # <descriptions>
    #     #    <description descriptionType="Abstract">Die Daten stammen aus einer Längsschnittstudie</description>
    #     # </descriptions>
    #     path_from_leuphanadataset = ns2 + 'descriptions/' + ns2 + 'description'
    #     ds_result['metadata']['leuphanaDataset']['descriptions'] = self._find_metadata_in_record(record,
    #                                                                                           path_from_leuphanadataset,
    #                                                                                           'description')

    #     # METADATA - KEYWORDS
    #     # <keywords>
    #     #     <keyword>downy mildew resistance</keyword>
    #     #     <keyword>untargeted metabolomics</keyword>
    #     # </keywords>
    #     path_from_leuphanadataset = ns3 + 'keywords/' + ns3 + 'keyword'
    #     ds_result['metadata']['leuphanaDataset']['keywords'] = self._find_metadata_in_record(record, path_from_leuphanadataset, 'keyword')

    #     # METADATA - CONTRIBUTORS
    #     # <contributors>
    #     #   <contributor contributorType="ContactPerson">
    #     #        <contributorName nameType="Personal">Niehoff, Steffen</contributorName>
    #     #        <givenName>Steffen</givenName>
    #     #        <familyName>Niehoff</familyName>
    #     #        <affiliation>Universität Osnabrück</affiliation>
    #     #   </contributor>
    #     # </contributors>
    #     path_from_leuphanadataset = ns2 + 'contributors/' + ns2 + 'contributor'
    #     subfields = [ns2 + 'contributorName', ns2 + 'givenName', ns2 + 'familyName', ns2 + 'affiliation',
    #                  ns2 + 'nameIdentifier']
    #     ds_result['metadata']['leuphanaDataset']['contributors'] = self._find_metadata_in_record(record,
    #                                                                                       path_from_leuphanadataset,
    #                                                                                       'contributor', subfields)

    #     # METADATA LANGUAGE
    #     #     <language>en</language>
    #     path_from_leuphanadataset = ns2 + 'language'
    #     ds_result['metadata']['leuphanaDataset']['language'] = self._find_metadata_in_record_simple(record,
    #                                                                                              path_from_leuphanadataset)
    #     # METADATA - ALTERNATE IDENTIFIERS
    #     # <alternateIdentifiers>
    #     #   <alternateIdentifier alternateIdentifierType="URL">https://leopard.tu-braunschweig.de/receive/dbbs_mods_00074785</alternateIdentifier>
    #     #   <alternateIdentifier alternateIdentifierType="MyCoRe">dbbs_mods_00074785</alternateIdentifier>
    #     # </alternateIdentifiers>
    #     path_from_leuphanadataset = ns2 + 'alternateIdentifiers/' + ns2 + 'alternateIdentifier'
    #     ds_result['metadata']['leuphanaDataset']['alternateIdentifiers'] = self._find_metadata_in_record(record, path_from_leuphanadataset, 'alternateIdentifier')

    #     # METADATA - RELATED IDENTIFIERS
    #     #  <relatedIdentifiers>
    #     #   	<relatedIdentifier relationType="IsCitedBy" relatedIdentifierType="DOI">10.1080</relatedIdentifier>
    #     #   	<relatedIdentifier relationType="IsCitedBy" relatedIdentifierType="ISSN">1618-8543</relatedIdentifier>
    #     #  </relatedIdentifiers>
    #     # Types =
    #     # - ARK
    #     # - arXiv
    #     # - bibcode
    #     # - DOI
    #     # - EAN13
    #     # - EISSN
    #     # - Handle
    #     # - IGSN
    #     # - ISBN
    #     # - ISSN
    #     # - ISTC
    #     # - LISSN
    #     # - LSID
    #     # - PMID
    #     # - PURL
    #     # - UPC
    #     # - URL
    #     # - URN
    #     # Relation Types:
    #     # - IsCitedBy
    #     # - Cites
    #     # - IsSupplementTo
    #     # - IsSupplementedBy
    #     # - IsContinuedBy
    #     # - Continues
    #     # - HasMetadata
    #     # - Is MetadataFor
    #     # - IsNewVersionOf
    #     # - IsPreviousVersionOf
    #     # - IsPartOf
    #     # - HasPart
    #     # - IsReferencedBy
    #     # - References
    #     # - IsDocumentedBy
    #     # - Documents
    #     # - IsCompiledBy
    #     # - Compiles
    #     # - IsVariantFormOf
    #     # - IsOriginalFormOf
    #     # - IsIdenticalTo
    #     # - IsReviewedBy
    #     # - Reviews
    #     # - IsDerivedFrom
    #     # - IsSourceOf
    #     path_from_leuphanadataset = ns2 + 'relatedIdentifiers/' + ns2 + 'relatedIdentifier'
    #     ds_result['metadata']['leuphanaDataset']['relatedIdentifiers'] = self._find_metadata_in_record(record, path_from_leuphanadataset, 'relatedIdentifier')

 
        return ds_result

    def _find_metadata_in_record_simple(self, record, path, subfields=[]):

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'dc/' + path
        
        metadata = record.find(target)

        result = {}
        name = path.split('}', 1)[1]
        if metadata is not None:
            if metadata.attrib:
                result = {name: metadata.text}
                result.update(metadata.attrib)
            elif metadata.text:
                result = metadata.text
        return result


    def _find_metadata_in_record(self, record, path, metadata_name, subfields=[]):

        target = './' + self.ns0 + 'metadata/' + self.ns2 + 'dc/' + path
        metadata = record.findall(target)

        list_result = []

        for value in metadata:
            result = {}
            if not subfields:
                result[metadata_name] = {metadata_name: value.text}
                result.update(value.attrib)
                list_result.append(result)
            else:
                dict_result = {metadata_name: {}}
                for field in subfields:
                    elem = value.find('./' + field)
                    name = field.split('}',1)[1]
                    if elem != None and elem.attrib:
                        dict_result[metadata_name][name] = {name: elem.text}
                        dict_result[metadata_name][name].update(elem.attrib)
                    elif elem != None:
                        dict_result[metadata_name][name] = elem.text

                if dict_result[metadata_name]:
                    list_result.append(dict_result)
        return list_result


    def parse_leuphana_RECORD_DICT_to_LDM_CKAN_DICT(self, leuphana_dict):

        ldm_dict = self._get_LDM_vdataset_template()
        leuphana_metadata = leuphana_dict['metadata']['leuphanaDataset']
        leuphana_metadata_json = leuphana_dict['header']['json_ld']

        # idenfier
        identifier_type = "DOI"
        identifier = self._get_leuphana_value(leuphana_metadata, ['identifier'])
        datestamp = self._get_leuphana_value(leuphana_dict['header'], ['datestamp'])
        publication_year = self._get_leuphana_value(leuphana_metadata_json, ['datePublished'])
        if not publication_year:
            publication_year = datestamp.split('-')[0]

        if identifier_type == 'DOI':
            ldm_dict['doi'] = identifier
            ldm_dict['doi_date_published'] = publication_year
            ldm_dict['url'] = 'https://doi.org/' + identifier

        # Creation date
        ldm_dict['source_metadata_created'] = publication_year

        # creators
        #print("\n\nDOI:\n", identifier)
        ldm_dict = self._get_leuphana_creators(leuphana_metadata, ldm_dict)

        # title
        title = self._get_leuphana_title(leuphana_metadata, ldm_dict)
        name = self.adjust_dataset_name(identifier_type+'-'+identifier)
        ldm_dict['title'] = title.capitalize()
        ldm_dict['name'] = name

        # rights
        rights = leuphana_metadata_json.get('license', [])
        if rights:
            ldm_dict['license_id'] = rights[0]
            ldm_dict['license_title'] = self._get_license_title(rights[0])

        # descriptions
        ldm_dict = self._get_leuphana_description(leuphana_metadata, ldm_dict)

        # publishers
        ldm_dict = self._get_leuphana_publishers(leuphana_metadata, ldm_dict)

        # publication year
        if publication_year:
            ldm_dict['publication_year'] = publication_year

        # subject areas
        ldm_dict = self._get_leuphana_subject_areas(leuphana_metadata, ldm_dict)

        # resource type
        resource_type = self._get_leuphana_value(leuphana_metadata_json, ['resourceType', 'type', 'type'])
        ldm_dict['resource_type'] = resource_type

        # related identifiers
        #ldm_dict = self._get_leuphana_related_identifiers(leuphana_metadata, ldm_dict)

        return ldm_dict

    def _get_license_title(self, license_id):

        for license in open_access_licenses:
            if license_id in license['url'] or license_id in license['legalcode_url']:
                return license['title']
        return ""    

    def _get_leuphana_title(self, leuphana_metadata, ldm_dict):

        titles = leuphana_metadata.get('titles', {})
        title_txt = ""

        for title in titles:
            title_txt = title.get("title", "").get('title', "")
            break # just take first one
            
        return title_txt
    
    def _get_leuphana_description(self, leuphana_metadata, ldm_dict):

        description_txt = leuphana_metadata.get('header', {}).get('json_ld', {}).get('description', "")
        
        ldm_dict['notes'] = description_txt
        return ldm_dict

    def _get_leuphana_creators(self, leuphana_metadata, ldm_dict):

        creators = leuphana_metadata.get('creators', [])
        extra_authors = []
        pos = 1
        for creator in creators:
            orcid = self._get_leuphana_value(creator, ['orcid'])
            givenName = self._get_leuphana_value(creator, ['givenName'])
            familyName = self._get_leuphana_value(creator, ['familyName'])
            if isinstance(orcid, list) and len(orcid)>0:
                orcid = orcid[0]
            if isinstance(givenName, list) and len(givenName)>0:
                givenName = givenName[0]
            if isinstance(familyName, list) and len(familyName)>0:
                familyName = familyName[0]
                
            name = familyName + ', ' + givenName
                 
            # first is author
            if pos == 1:
                ldm_dict['author'] = name
                ldm_dict['givenName'] = givenName
                ldm_dict['familyName'] = familyName
                ldm_dict['orcid'] = orcid
                if not ldm_dict['givenName'] and not ldm_dict['familyName'] and ldm_dict['author']:
                    ldm_dict['givenName'] = ldm_dict['author'].split(',')[-1].strip()
                    ldm_dict['familyName'] = ldm_dict['author'].split(',')[0].strip()

                pos += 1
            else:
                # following are extra_authors
                extra_author = {"extra_author": name,
                                "givenName": givenName,
                                "familyName": familyName,
                                "orcid": orcid}
                if not extra_author['givenName'] and not extra_author['familyName'] and extra_author['extra_author']:
                       extra_author['givenName'] = extra_author['extra_author'].split(',')[-1].strip()
                       extra_author['familyName'] = extra_author['extra_author'].split(',')[0].strip()
                extra_authors.append(extra_author)
        if extra_authors:
            ldm_dict['extra_authors'] = extra_authors

        return ldm_dict

    def _get_leuphana_keywords(self, leuphana_metadata, ldm_dict):

        keywords = leuphana_metadata.get('keywords', [])
        tag_list = []

        for keyword in keywords:
            tag = self._get_leuphana_value(keyword, ['keyword', 'keyword'])
            # create ckan tag dict
            # some cases are ; separated list of tags
            tag = tag.replace(';', ',')
            # some cases are "·" separated list of tags
            tag = tag.replace('·', ',')
            if ',' in tag: # some cases are comma separated list of tags
                for t in tag.split(','):
                    t = self._adjust_tag(t)
                    if t: # some cases list end with comma ,
                        tag_dict = { "display_name": t,
                                     "name": t,
                                     "state": "active",
                                     "vocabulary_id": None}
                        tag_list.append(tag_dict)
            else:
                tag = self._adjust_tag(tag)
                if tag:
                    tag_dict = {"display_name": tag.strip(),
                                "name": tag.strip(),
                                "state": "active",
                                "vocabulary_id": None}
                    tag_list.append(tag_dict)

        if tag_list:
            ldm_dict['tags'] = tag_list

        return ldm_dict

    def _adjust_tag(self, tag):
        PERMITTED_CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_. "
        tag = tag.replace("/", "-") # some tags have / chars
        tag = "".join(c for c in tag if c in PERMITTED_CHARS)  # some tags has no permitted chars
        tag = tag.strip()
        # In CKAN tags minimum lenght is 2
        if len(tag) < 2:
            tag = ''
        # In CKAN tag long max = 100
        tag = tag[:100]
        return tag

    def _get_leuphana_publishers(self, leuphana_metadata, ldm_dict):

        publisher = "Medien- und Informationszentrum, Leuphana Universität Lüneburg"
        
        ldm_dict['publishers'] = [{'publisher': publisher}]

        return ldm_dict

    def _get_leuphana_subject_areas(self, leuphana_metadata, ldm_dict):

        s_areas = leuphana_metadata.get('keywords', [])
        s_areas_list = []

        for name in s_areas:
            # create ckan subject areas dict
            s_area_dict = {"subject_area_name": name }
            s_areas_list.append(s_area_dict)
        if s_areas_list:
            ldm_dict['subject_areas'] = s_areas_list

        return ldm_dict

    def _get_leuphana_related_identifiers(self, leuphana_metadata, ldm_dict):

        r_identifiers = leuphana_metadata.get('relatedIdentifiers', [])
        r_identifiers_list = []

        for r_id in r_identifiers:
            identifier = self._get_leuphana_value(r_id, ['relatedIdentifier', 'relatedIdentifier'])
            id_type = self._get_leuphana_value(r_id, ['relatedIdentifierType'])
            id_relation = self._get_leuphana_value(r_id, ['relationType'])
            # create ckan related identifiers dict
            r_identifier_dict = { "identifier": identifier,
                            "identifier_type": id_type,
                            "relation_type": id_relation}
            r_identifiers_list.append(r_identifier_dict)
        if r_identifiers_list:
            ldm_dict['related_identifiers'] = r_identifiers_list

        return ldm_dict

    def _get_leuphana_value(self, leuphana_metadata, list_fields=[]):

        mt_dict = leuphana_metadata
        value = ""

        for field in list_fields:
            if isinstance(mt_dict, dict) and field in mt_dict:
                mt_dict = mt_dict[field]
                if not isinstance(mt_dict, dict):
                    value = mt_dict
            elif isinstance(mt_dict, dict):
                value = mt_dict.get(field, "")
            else:
                value = mt_dict   

        return value

    def _get_LDM_vdataset_template(self):
        #datetime.datetime.now().isoformat()



        LDM_imported_vdataset = {
            "repository_name": self.repository_name,
            "type": "vdataset",
            "source_metadata_created": "",
            "source_metadata_modified": "",
            "owner_org": "leuphana",
            "author": "",
            "author_email": "",
        #     "creator_user_id": "17755db4-395a-4b3b-ac09-e8e3484ca700",
             "doi": "",
             "doi_date_published": "",
             "doi_publisher": "",
             "doi_status": "True",
        #     "domain": "https://data.uni-hannover.de",
        #     "have_copyright": "Yes",
        #     "id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
        #     "isopen": False,
             "license_id": "",
             "license_title": "",
        #     "maintainer": "Clemens Huebler",
        #     "maintainer_email": "c.huebler@isd.uni-hannover.de",
        #     "metadata_created": "2021-10-07T09:58:55.243407",
        #     "metadata_modified": "2021-10-07T09:58:55.243416",
             "name": "",
             "notes": "",
        #     "num_resources": 2,
        #     "num_tags": 3,
             "organization": self._get_leuphana_organization_ckan_dict(),
        #         "id": "3d4e7da1-a0ef-4af1-9c07-56cf5e35084d",
        #         "name": "institut-fur-statik-und-dynamik",
        #         "title": "Institut für Statik und Dynamik",
        #         "type": "organization",
        #         "description": "(Institute of Structural Analysis) \r\nAppelstraße 9A \r\n__30167 Hannover (Germany)__\r\n\r\nhttps://www.isd.uni-hannover.de/en/institute/",
        #         "image_url": "",
        #         "created": "2021-10-07T11:46:15.762388",
        #         "is_organization": True,
        #         "approval_status": "approved",
        #         "state": "active"
        #     },
        #     "owner_org": "3d4e7da1-a0ef-4af1-9c07-56cf5e35084d",
        #     "private": False,
        #     "production_year": "2022",
        #     "publication_year": "2022",
        #     "resource_type": "Dataset",
        #     "repository_name": "Leibniz University Hannover",
        #     "services_used_list": "",
        #     "source_metadata_created": "2020-06-29T13:56:20.726566",
        #     "source_metadata_modified": "2021-07-06T09:21:41.322946",
        #     "state": "active",
        #     "terms_of_usage": "Yes",
             "title": "",
        #     "type": "vdataset",
             "url": "",
             "citation": [],
        #     "version": "",
        #     "publishers": [
        #         {
        #             "publisher": "publisher1"
        #         },
        #         {
        #             "publisher": "publisher2"
        #         }
        #     ],
        # #     "resources": [
        #         {
        #             "cache_last_updated": None,
        #             "cache_url": None,
        #             "created": "2020-06-29T13:56:24.253776",
        #             "datastore_active": False,
        #             "description": "",
        #             "downloadall_datapackage_hash": "98b5bd1da7a98e0a79ab9dae7e68f8cd",
        #             "downloadall_metadata_modified": "2021-07-06T09:21:25.079814",
        #             "format": "ZIP",
        #             "hash": "",
        #             "id": "da3a4b40-c6b3-42de-87a4-4ea60c441910",
        #             "last_modified": "2021-07-06T09:21:36.339262",
        #             "metadata_modified": "2021-10-07T09:58:55.231269",
        #             "mimetype": "application/zip",
        #             "mimetype_inner": None,
        #             "name": "All resource data",
        #             "package_id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
        #             "position": 0,
        #             "resource_type": None,
        #             "revision_id": "5b858701-baff-4dff-86a8-06cb0c01f224",
        #             "size": 875,
        #             "state": "active",
        #             "url": "https://data.uni-hannover.de/dataset/7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3/resource/da3a4b40-c6b3-42de-87a4-4ea60c441910/download/windturbine-simulation-for-meta-modelling-otpq81.zip",
        #             "url_type": ""
        #         },
        #         {
        #             "cache_last_updated": None,
        #             "cache_url": None,
        #             "created": "2020-06-29T13:59:45.579275",
        #             "datastore_active": False,
        #             "description": "This data set correlates environmental conditions acting on an offshore wind turbine (inputs) with fatigue loads of the turbine (outputs).\r\nThe investigated wind turbine is the NREL 5MW reference turbine and the OC3 monopile.\r\nEnvironmental conditions are based on FINO3 data (https://www.fino3.de/en/).\r\nTime series of bending moments and shear forces at mudline and blade root bending moments are computed using the FASTv8 simulation code by the NREL.\r\n10.000 simulations for varying environmental conditions (and varying random seeds) were conducted.\r\nShort-term damage equivalent loads (DELs) representing fatigue were calculated for several relevant positions (at mudline and at the blade root).",
        #             "format": "TXT",
        #             "hash": "",
        #             "id": "0f24dea1-53b3-4cb9-afa4-16b342524aa8",
        #             "last_modified": "2020-06-29T13:59:45.533215",
        #             "metadata_modified": "2021-10-07T09:58:55.233372",
        #             "mimetype": "text/plain",
        #             "mimetype_inner": None,
        #             "name": "Metamodeldata.txt",
        #             "package_id": "7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3",
        #             "position": 1,
        #             "resource_type": None,
        #             "revision_id": "f5dad358-82bc-44cd-84a8-5f68f14a774e",
        #             "size": 1142901,
        #             "state": "active",
        #             "url": "https://data.uni-hannover.de/dataset/7e6929b4-0aa0-44b4-9a1c-29d42bb78aa3/resource/0f24dea1-53b3-4cb9-afa4-16b342524aa8/download/metamodeldata.txt",
        #             "url_type": ""
        #         }
        #     ],
        #     "subject_areas": [
        #         {
        #             "subject_area_additional": "addarea1",
        #             "subject_area_name": "area1"
        #         },
        #         {
        #             "subject_area_additional": "addarea2",
        #             "subject_area_name": "area2"
        #         }
        #     ],
        #     "tags": [
        #         {
        #             "display_name": "FAST",
        #             "id": "235ed4d9-3def-4174-bb4d-51950abe8813",
        #             "name": "FAST",
        #             "state": "active",
        #             "vocabulary_id": None
        #         },
        #         {
        #             "display_name": "meta-model",
        #             "id": "2c83feeb-a00e-4821-91b1-c42fb828a3ad",
        #             "name": "meta-model",
        #             "state": "active",
        #             "vocabulary_id": None
        #         },
        #         {
        #             "display_name": "wind energy",
        #             "id": "81223f1d-955d-4ff4-8be0-1fda56b540ba",
        #             "name": "wind energy",
        #             "state": "active",
        #             "vocabulary_id": None
        #         }
        #     ],
        #     "groups": [],
        #     "relationships_as_subject": [],
        #     "relationships_as_object": []
         }
        return LDM_imported_vdataset

    def check_current_schema(self):
        '''
            Using the leuphana harvesting tool determine if the current schema is matching the schema implemented.
            Returning a dict with the results of comparing the metadata schema used in the code
            with the metadata schema retrieved by remote servers

            result = {'status_ok': True,
                      'report': 'Text explaining the results'}
        '''

        if not self.current_schema_report:
            self.current_schema_report = self._get_schema_report()

        return self.current_schema_report


    def _get_schema_report(self, obj_tree=None):

        schema_dataset = None
        schema_dataset_element = None
        
        if obj_tree is None:
            url = self.leuphana_ListRecords_url
            
            # Find page of Datasets
            try:
                response = requests.get(url)
            except requests.exceptions.RequestException as e:  # This is the correct syntax
                self.set_log("error_API", self.leuphana_ListRecords_url + " - " + e.__str__())

            if not response.ok:
                self.set_log("error_api_data", self.leuphana_ListRecords_url)
            else:
                obj_tree = ElementTree.fromstring(response.content)

        if obj_tree is None:
            # Error accessing API
            schema_dataset = None
            schema_dataset_element = None
        else:
            schema_dataset_data = obj_tree.find(self.ns0 + 'ListRecords/' + self.ns0 + 'record/' + self.ns0 + 'metadata/' + self.ns2 + 'resource')
            if schema_dataset_data is not None:
                if schema_dataset_data.attrib:
                    aux = schema_dataset_data.attrib['{http://www.w3.org/2001/XMLSchema-instance}schemaLocation']
                    aux = aux.split(" ")
                    schema_dataset = aux[0]
                    schema_dataset_element = aux[1]
        
        current_schema = {'current_leuphana_schema': self.ns2,
                          'current_dataset_schema': self.current_dataset_schema
                          }
        schema_ok = True

        errors = {}
        # if both elements were found means the schema is correct
        if not schema_dataset:
            errors['dataset_schema'] = 'ERROR: Current Dataset Schema is incorrect.'
            schema_ok = False
        if not schema_dataset_element:
            errors['dataset_element_schema'] = 'ERROR: Current Dataset Element Schema is incorrect.'
            schema_ok = False

        report = {'status_ok': schema_ok,
                  'report': {'current_metadata': current_schema,
                             'errors': errors},
                  }
        return report


    def get_organization(self, name='leuphana'):
        '''
            In leuphana Datasets are no related to a specific organization.
            leuphana's imported datasets allways belongs to leuphana organization in LDM.

            Returns: a dictionary with the organization's metadata
        '''

        self.set_log("infos_searching_org", name)

        org_dict = self._get_leuphana_organization_ckan_dict()

        return org_dict

    def _get_leuphana_organization_ckan_dict(self):

        org_dict = {
        "approval_status": "approved",
        "description": "The repository of the Leuphana University Lüneburg.",
        "display_name": "leuphana (The repository of the Leuphana University Lüneburg)",
        "image_display_url": "logo-leuphana.png",
        "image_url": "logo-leuphana.png",
        "is_organization": True,
        "name": "leuphana",
        "state": "active",
        "title": "Leuphana (The repository of the Leuphana University Lüneburg)",
        "type": "organization",
        }
        return org_dict

    def adjust_dataset_name(self, ds_name):

        specialChars = " /."
        for specialChar in specialChars:
            ds_name = ds_name.replace(specialChar, '-')
        ds_name = ds_name.lower()
        ds_name = self.dataset_title_prefix + ds_name
        # CKAN limits name to 100 chars
        ds_name = (ds_name[:100]).strip()
        # clean possible spetial chars
        ds_name = urllib.parse.quote(ds_name)
        return ds_name


    def should_be_updated(self, local_dataset, remote_dataset):

        if self.force_update:
            return True

        result = False
        exclude_in_comparison = ['owner_org', 'license_title', 'organization', 'subject_areas']

        for field in remote_dataset.keys():

            # special case  tags
            if field == 'subject_areas':
                for tag in remote_dataset['subject_areas']:
                    tag_name = tag['subject_area_name']
                    tag_found = False
                    for tag_local in local_dataset['subject_areas']:
                        if tag_local['subject_area_name'] == tag_name:
                            tag_found = True
                    if not tag_found:
                        result = True
                        break

            #print("\nField: ", field, " L= ", local_dataset.get(field, "KEY ERROR"), " R= ", remote_dataset[field])
            # print("\nField: ", field)

            if field in local_dataset and field not in exclude_in_comparison:
                # print("\nField: ", field, " L= ", local_dataset[field], " R= ", remote_dataset[field])
                if local_dataset[field] != remote_dataset[field]:
                    #print("\nField: ", field)
                    self.logger.message = "\nField: ", field, " L= ", local_dataset[field], " R= ", remote_dataset[field]
                    self.set_log_msg_info()
                    result = True
                    break

        return result


    def adjust_organization_dict(self, org_dict):
        org_dict['image_url'] = org_dict['image_display_url']
        return org_dict

    def adjust_dataset_dict(self, ds_dict):
        # set source url
        ds_dict['url'] = ds_dict['domain'] + '/dataset/' + ds_dict['name']

        # adjust dataset and repository names
        ds_dict['name'] = self.adjust_dataset_name(ds_dict['name'])
        ds_dict['repository_name'] = self.repository_name

        # Save the dataset as virtual dataset (vdataset)
        ds_dict['type'] = "vdataset"

        # save source creation and modification dates
        ds_dict['source_metadata_created'] = ds_dict['metadata_created']
        ds_dict['source_metadata_modified'] = ds_dict['metadata_modified']

        # clean fields
        clean_fields = {"metadata_created", "creator_user_id"}
        for fd in clean_fields:
            ds_dict[fd] = ""

        # clean relationships
        ds_dict["groups"] = []
        ds_dict["relationships_as_subject"] = []
        ds_dict["revision_id"] = ""

        # set organization owner and image
        ds_dict['owner_org'] = ds_dict['organization']['name']

        # Save all resources as URl type for making them virtual
        for resource in ds_dict['resources']:
            resource['url_type'] = ""

        return ds_dict

    def get_remote_dataset_schema(self):
        ds_dicts = self.get_all_datasets_dicts()

        dataset_keys = []
        resource_keys = []
        resource_types = []

        for dataset in ds_dicts:
            for key, value in dataset.items():
                if not key in dataset_keys:
                    dataset_keys.append(key)
                if key=='resources' and not dataset['resources']==[]:
                    for resource in dataset['resources']:
                        for key2, value2 in resource.items():
                            if not key2 in resource_keys:
                                resource_keys.append(key2)
                            if key2=='format':
                                if not value2 in resource_types:
                                    resource_types.append(value2)
        return { "dataset_keys": dataset_keys, "resource_keys": resource_keys, "resource_types": resource_types}


# LOGGER METHODS
# **************


    def set_log(self, op, data=""):

        self.logger.message = ""

        def infos_searching_ds(data):
            self.logger.message = "Searching Datasets in leuphana's harvesting tool."

        def error_API(data):
            self.logger.message = "Error Connecting leuphana's harvesting tool: " + data

        def error_api_data(data):
            self.logger.message = "Error retrieving data from API: " + data

        def error_searching_website(data):
            self.logger.message = "Error retrieving data from Leuphana's Website: " + data

        def infos_ds_found(data):
            self.logger.message = "Number of Datasets found: " + data

        def infos_ds_metadata_found(data):
            self.logger.message = "Metadata found with name: " + data

        def infos_searching_org(data):
            self.logger.message = "Searching Organizaion in leuphana API. Name: " + data

        def infos_org_found(data):
            self.logger.message = "Organization found: " + data

        def infos_summary_log(data):
            self.logger.message = self.get_summary_log()

        result = {
            'infos_searching_ds': infos_searching_ds,
            'error_API': error_API,
            'error_api_data': error_api_data,
            'error_searching_website': error_searching_website,
            'infos_ds_found': infos_ds_found,
            'infos_ds_metadata_found': infos_ds_metadata_found,
            'infos_searching_org': infos_searching_org,
            'infos_org_found': infos_org_found,
            'infos_org_found': infos_summary_log
        }.get(op)(data)

        if op[0:5]=='infos':
            self.set_log_msg_info()
        elif op[0:5]=='error':
            self.set_log_msg_error()
    
    def set_log_info(self, msg):
        self.logger.message = msg
        self.set_log_msg_info()
