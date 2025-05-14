import requests
import json
from urllib.parse import quote_plus


class dataCite_API_Search():


    def __init__(self, publisher_name, resource_type="Dataset", filter_open_licenses=False, page_size=50, max_pages=10):
        self.publisher_name = publisher_name
        self.resource_type = resource_type
        self.filter_open_licenses = filter_open_licenses
        
        # records for page retrieved by API
        self.page_size = page_size
        self.max_pages = max_pages
        
        self.dataCite_API_URL = "https://api.datacite.org/dois"

    
    def get_doi_metadata(self, doi):
        """
        Retrieve metadata for a specific DOI from the DataCite API.
        
        Args:
            doi (str): The DOI to retrieve metadata for
            
        Returns:
            dict: The metadata for the DOI, or None if not found
        """
        # Construct the URL for the specific DOI
        url = f"{self.dataCite_API_URL}/{doi}"
        
        # Optional parameters
        params = {
            'affiliation': 'true',  # Include affiliation data
            'publisher': 'true',    # Include publisher data
            'detail': 'true'        # Include additional attributes
        }
        
        # print(f"Requesting metadata for DOI: {doi}")
        # print(f"API URL: {url}")
        
        # Make the request
        response = requests.get(url, params=params)
        
        # Check if the request was successful
        if response.status_code == 200:
            data = response.json()
            return data
        elif response.status_code == 404:
            # print(f"Error: DOI {doi} not found in DataCite")
            return None
        else:
            # print(f"Error: Received status code {response.status_code}")
            # print(response.text)
            return None
    
    def extract_key_metadata(self, data):
        """
        Extract key metadata from the DataCite API response.
        
        Args:
            data (dict): The full API response
            
        Returns:
            dict: A dictionary with key metadata fields
        """
        if not data or 'data' not in data:
            return None
            
        metadata = data.get('data', {}).get('attributes', {})
        
        # Extract key metadata fields
        key_metadata = {
            'doi': metadata.get('doi'),
            'title': metadata.get('titles', [{}])[0].get('title') if metadata.get('titles') else None,
            'publisher': metadata.get('publisher'),
            'publicationYear': metadata.get('publicationYear'),
            'resourceType': metadata.get('types', {}).get('resourceTypeGeneral'),
            'creators': metadata.get('creators'),
            'contributors': metadata.get('contributors'),
            'descriptions': metadata.get('descriptions'),
            'subjects': metadata.get('subjects'),
            'dates': metadata.get('dates'),
            'language': metadata.get('language'),
            'relatedIdentifiers': metadata.get('relatedIdentifiers'),
            'rightsList': metadata.get('rightsList'),
            'geoLocations': metadata.get('geoLocations'),
            'fundingReferences': metadata.get('fundingReferences'),
            'url': metadata.get('url'),
            'schemaVersion': metadata.get('schemaVersion'),
            'state': metadata.get('state'),
            'created': metadata.get('created'),
            'registered': metadata.get('registered'),
            'updated': metadata.get('updated')
        }
        
        return key_metadata    

    def get_key_doi_metadata(self, doi):
        return self.extract_key_metadata(self.get_doi_metadata(doi))

    def get_dois_page(self, page=1):
        """
        Retrieve a single page of DOIs from DataCite API filtered by publisher, resource type, and license.
        
        Args:
            page (int): Page number to retrieve
        
        Using class Args:
            publisher_name (str): Name of the publisher to filter by
            resource_type (str): Resource type to filter by (e.g., Dataset, Text)
            filter_open_licenses (bool): If True, filter for open licenses
            page_size (int): Number of results per page (default is 25, max is 1000)
        
        Returns:
            tuple: (doi_records, total_records, total_pages)
        """
        base_url = self.dataCite_API_URL
        
        # Build the query string to filter by publisher, resource type, and license
        query = f'publisher.name:"{self.publisher_name}" AND types.resourceTypeGeneral:{self.resource_type}'
        
        # Add license filter if requested
        if self.filter_open_licenses:
            # This will search for common open license terms in the rightsList.rights field
            license_query = ' AND (rightsList.rightsUri:*creativecommons* OR rightsList.rights:*Creative Commons* OR rightsList.rights:*CC-BY* OR rightsList.rights:*Open* OR rightsList.rights:*Public Domain* OR rightsList.rightsIdentifier:*cc-*)'
            query += license_query
        
        encoded_query = quote_plus(query)
        
        # Parameters for the API request
        params = {
            'query': encoded_query,
            'page[size]': self.page_size,
            'page[number]': page,
            'sort': '-created',
            'affiliation': 'true'
        }
        
        api_url = f"{base_url}?query={encoded_query}&page[size]={self.page_size}&page[number]={page}&sort=-created&affiliation=true"
        print(f"API Query URL: {api_url}")
        
        response = requests.get(api_url)
        
        # Add detailed debugging
        print(f"Full response headers: {response.headers}")
        
        # Check if the request was successful
        if response.status_code != 200:
            print(f"Error: Received status code {response.status_code}")
            print(response.text)
            return [], 0, 0
        
        # Parse the JSON response
        data = response.json()
        
        # Print raw data for debugging
        print(f"Response data keys: {data.keys()}")
        print(f"Meta information: {data.get('meta', {})}")

        # Get records from this page
        doi_records = data.get('data', [])
        
        # Get metadata about the results
        meta = data.get('meta', {})
        total_records = meta.get('total', 0)
        total_pages = meta.get('totalPages', 1)
        
        print(f"Retrieved {len(doi_records)} records (Page {page} of {total_pages}, Total: {total_records})")
        
        return doi_records, total_records, total_pages

    def get_dois_by_publisher_and_type(self):
        """
        Retrieve DOIs from DataCite API filtered by publisher, resource type, and license.
        
        Args:
            publisher_name (str): Name of the publisher to filter by
            resource_type (str): Resource type to filter by (e.g., Dataset, Text)
            filter_open_licenses (bool): If True, filter for open licenses
            max_pages (int): Maximum number of pages to retrieve
            page_size (int): Number of results per page (default is 25, max is 1000)
        
        Returns:
            list: List of DOI records matching the criteria
        """
        all_results = []
        
        # Get the first page to determine total pages
        first_page_results, total_records, total_pages = self.get_dois_page()
        
        # Add the first page results to our collection
        all_results.extend(first_page_results)
        # Determine how many more pages to fetch
        pages_to_fetch = min(total_pages, self.max_pages)
        
        print(f"Retrieved {len(all_results)} records total (from {pages_to_fetch} of {total_pages} pages)")
        
        # Fetch the remaining pages
        for page in range(2, pages_to_fetch + 1):
            page_results, _, _ = self.get_dois_page(page=page)
            
            # Add the results to our collection
            all_results.extend(page_results)
        
        print(f"Retrieved {len(all_results)} records total (from {pages_to_fetch} of {total_pages} pages)")
        return all_results

    def display_doi_info(self, doi_records):
        """Display basic information about each DOI."""
        if not doi_records:
            print("No DOIs found matching the criteria.")
            return
        
        print(f"\nFound {len(doi_records)} DOIs:\n")
        print("-" * 80)
        
        for i, record in enumerate(doi_records, 1):
            attrs = record.get('attributes', {})
            doi = attrs.get('doi', 'Unknown DOI')
            title = attrs.get('titles', [{}])[0].get('title', 'No title') if attrs.get('titles') else 'No title'
            publication_year = attrs.get('publicationYear', 'Unknown year')
            resource_type = attrs.get('types', {}).get('resourceTypeGeneral', 'Unknown type')
            
            # Get license information if available
            rights_list = attrs.get('rightsList', [])
            license_info = "No license information" if not rights_list else rights_list[0].get('rights', 'Unknown license')
            
            print(f"{i}. DOI: {doi}")
            print(f"   Title: {title}")
            print(f"   Year: {publication_year}")
            print(f"   Type: {resource_type}")
            print(f"   License: {license_info}")
            print(f"   URL: https://doi.org/{doi}")
            print("-" * 80)

    def save_to_file(self, doi_records, filename="datacite_dois.json"):
        """Save the DOI records to a JSON file."""
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(doi_records, f, indent=2)
        print(f"Saved {len(doi_records)} DOI records to {filename}")

