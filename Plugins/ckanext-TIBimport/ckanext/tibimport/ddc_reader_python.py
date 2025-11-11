#!/usr/bin/env python3
"""
DDC (Dewey Decimal Classification) Reader
A Python script to read DDC classification data from JSON and extract text descriptions by ID.
"""

import json
import os
from typing import Optional, Dict, Any
from ckanext.tibimport.ddc_classification import ddc_classification

class DDCReader:
    """
    A class to handle DDC (Dewey Decimal Classification) data operations.
    """
    
    def __init__(self):
        """
        Initialize the DDC Reader with data from JSON file.
        
        Args:
            json_file_path (str): Path to the DDC JSON file
        """
        self.ddc_data = None
        self.load_data()
    
    def load_data(self) -> None:
        """
        Load DDC data from python file.
        
        """
        self.ddc_data = ddc_classification

    def get_text_by_id(self, ddc_id: str) -> Optional[str]:
        """
        Extract the text description for a given DDC ID number.
        
        Args:
            ddc_id (str): The DDC classification number (e.g., "625", "388", "711")
        
        Returns:
            str: The text description if found, None otherwise
        
        Examples:
            >>> reader = DDCReader()
            >>> reader.get_text_by_id("625")
            'Engineering of railroads & roads'
            >>> reader.get_text_by_id("388")
            'Transportation; ground transportation'
            >>> reader.get_text_by_id("711")
            'Area planning'
        """
        if not self.ddc_data:
            print("❌ DDC data not loaded. Call load_data() first.")
            return None
        
        # Normalize the input (remove leading zeros, handle various formats)
        normalized_id = ddc_id # not normalize
        
        # Search in sections first (most specific)
        if normalized_id in self.ddc_data.get("sections", {}):
            return self.ddc_data["sections"][normalized_id]
        
        # Search in divisions
        if normalized_id in self.ddc_data.get("divisions", {}):
            return self.ddc_data["divisions"][normalized_id]
        
        # Search in main classes
        if normalized_id in self.ddc_data.get("main_classes", {}):
            return self.ddc_data["main_classes"][normalized_id]
        
        return ""
    
    def _normalize_ddc_id(self, ddc_id: str) -> str:
        """
        Normalize DDC ID to standard format.
        
        Args:
            ddc_id (str): Raw DDC ID input
            
        Returns:
            str: Normalized DDC ID
        """
        # Remove any non-numeric characters except decimal point
        import re
        cleaned_id = re.sub(r'[^\d.]', '', str(ddc_id))
        
        # Handle decimal numbers by taking the integer part
        if '.' in cleaned_id:
            cleaned_id = cleaned_id.split('.')[0]
        
        # Pad with zeros to at least 3 digits for main classes
        if len(cleaned_id) <= 3:
            cleaned_id = cleaned_id.zfill(3)
        
        return cleaned_id
    
    def search_by_keyword(self, keyword: str, case_sensitive: bool = False) -> Dict[str, str]:
        """
        Search for DDC entries containing a specific keyword.
        
        Args:
            keyword (str): Keyword to search for
            case_sensitive (bool): Whether search should be case sensitive
            
        Returns:
            dict: Dictionary of DDC ID -> description pairs matching the keyword
        """
        if not self.ddc_data:
            print("❌ DDC data not loaded. Call load_data() first.")
            return {}
        
        results = {}
        search_term = keyword if case_sensitive else keyword.lower()
        
        # Search through all sections
        for section_name in ["main_classes", "divisions", "sections"]:
            section_data = self.ddc_data.get(section_name, {})
            for ddc_id, description in section_data.items():
                search_text = description if case_sensitive else description.lower()
                if search_term in search_text:
                    results[ddc_id] = description
        
        return results
    
    def get_hierarchy(self, ddc_id: str) -> Dict[str, str]:
        """
        Get the hierarchical context of a DDC number.
        
        Args:
            ddc_id (str): The DDC classification number
            
        Returns:
            dict: Dictionary showing the hierarchy (main_class, division, section)
        """
        normalized_id = self._normalize_ddc_id(ddc_id)
        hierarchy = {}
        
        if len(normalized_id) >= 3:
            # Main class (first digit + "00")
            main_class_id = normalized_id[0] + "00"
            if main_class_id in self.ddc_data.get("main_classes", {}):
                hierarchy["main_class"] = {
                    "id": main_class_id,
                    "text": self.ddc_data["main_classes"][main_class_id]
                }
            
            # Division (first two digits + "0")
            if len(normalized_id) >= 2:
                division_id = normalized_id[:2] + "0"
                if division_id in self.ddc_data.get("divisions", {}):
                    hierarchy["division"] = {
                        "id": division_id,
                        "text": self.ddc_data["divisions"][division_id]
                    }
            
            # Section (exact match)
            if normalized_id in self.ddc_data.get("sections", {}):
                hierarchy["section"] = {
                    "id": normalized_id,
                    "text": self.ddc_data["sections"][normalized_id]
                }
        
        return hierarchy
    
    def print_metadata(self) -> None:
        """Print metadata information about the DDC data."""
        if not self.ddc_data:
            print("❌ DDC data not loaded.")
            return
        
        metadata = self.ddc_data.get("metadata", {})
        print("📚 DDC Classification Information:")
        print(f"   Title: {metadata.get('title', 'N/A')}")
        print(f"   Source: {metadata.get('source', 'N/A')}")
        print(f"   Copyright: {metadata.get('copyright', 'N/A')}")
        
        levels = metadata.get("levels", {})
        print("📊 Coverage:")
        for level, description in levels.items():
            print(f"   {level.replace('_', ' ').title()}: {description}")


# def main():
#     """
#     Main function demonstrating the DDC Reader functionality.
#     """
#     # Initialize the DDC Reader
#     try:
#         reader = DDCReader("ddc_classification.json")
#     except (FileNotFoundError, json.JSONDecodeError) as e:
#         print(f"❌ Error: {e}")
#         return
    
#     # Print metadata
#     reader.print_metadata()
#     print()
    
#     # Example usage - your specific DDC numbers
#     test_ids = ["625", "388", "711", "600", "001", "999"]
    
#     print("🔍 Testing DDC ID lookups:")
#     for ddc_id in test_ids:
#         result = reader.get_text_by_id(ddc_id)
#         if result:
#             print(f"   {ddc_id}: {result}")
#         else:
#             print(f"   {ddc_id}: ❌ Not found")
    
#     print()
    
#     # Example hierarchy lookup
#     print("🏗️  Hierarchy for DDC 625:")
#     hierarchy = reader.get_hierarchy("625")
#     for level, info in hierarchy.items():
#         print(f"   {level.replace('_', ' ').title()}: {info['id']} - {info['text']}")
    
#     print()
    
#     # Example keyword search
#     print("🔎 Searching for 'transportation':")
#     search_results = reader.search_by_keyword("transportation")
#     for ddc_id, description in list(search_results.items())[:5]:  # Show first 5 results
#         print(f"   {ddc_id}: {description}")
    
#     print()
    
#     # Interactive mode
#     print("💬 Interactive mode - Enter DDC numbers to look up (or 'quit' to exit):")
#     while True:
#         try:
#             user_input = input("Enter DDC ID: ").strip()
#             if user_input.lower() in ['quit', 'exit', 'q']:
#                 break
            
#             if not user_input:
#                 continue
            
#             result = reader.get_text_by_id(user_input)
#             if result:
#                 print(f"✅ {user_input}: {result}")
                
#                 # Show hierarchy if available
#                 hierarchy = reader.get_hierarchy(user_input)
#                 if len(hierarchy) > 1:
#                     print("   Hierarchy:")
#                     for level, info in hierarchy.items():
#                         print(f"     {level.replace('_', ' ').title()}: {info['text']}")
#             else:
#                 print(f"❌ {user_input}: Not found")
                
#                 # Suggest similar numbers
#                 similar = reader.search_by_keyword(user_input[:2])
#                 if similar:
#                     print(f"   💡 Similar numbers found:")
#                     for sim_id, sim_desc in list(similar.items())[:3]:
#                         print(f"     {sim_id}: {sim_desc}")
            
#             print()
            
#         except KeyboardInterrupt:
#             print("\n👋 Goodbye!")
#             break
#         except Exception as e:
#             print(f"❌ Error: {e}")


# # Standalone function for easy import
# def get_ddc_text(ddc_id: str, json_file_path: str = "ddc_classification.json") -> Optional[str]:
#     """
#     Standalone function to get DDC text by ID.
    
#     Args:
#         ddc_id (str): The DDC classification number
#         json_file_path (str): Path to the DDC JSON file
        
#     Returns:
#         str: The text description if found, None otherwise
    
#     Example:
#         >>> text = get_ddc_text("625")
#         >>> print(text)  # "Engineering of railroads & roads"
#     """
#     try:
#         reader = DDCReader(json_file_path)
#         return reader.get_text_by_id(ddc_id)
#     except Exception as e:
#         print(f"Error loading DDC data: {e}")
#         return None


# if __name__ == "__main__":
#     main()
