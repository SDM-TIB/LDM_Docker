from flask import Blueprint, jsonify
from ckan.common import config, request
import requests

def get_github_access_token():
    return config.get("ckanext.gitImport.github_access_token", None)

gitimport = Blueprint("gitimport", __name__)

# Defining a Route for "gitimport"
@gitimport.route("/gitimport/fetch", methods=["GET"])
def fetch_github_metadata():
    repo_name = request.args.get("repo_name")
    if not repo_name:
        return jsonify({"error": "Repository name is required"}), 400

    access_token = get_github_access_token()
    headers = {"Authorization": f"token {access_token}"} if access_token else {}

    # Base URL for GitHub API requests
    base_url = f"https://api.github.com/repos/{repo_name}"
    metadata = {}

    # Function to safely extract data from GitHub API responses
    def safe_extract(response_data, key, default="Not found"):
        return response_data.get(key, default) if response_data else default

    # Fetch main repository metadata
    repo_response = requests.get(base_url, headers=headers)
    if repo_response.status_code == 200:
        repo_data = repo_response.json()
        metadata["owner"] = safe_extract(repo_data.get("owner", {}), "login", "Owner not found")
        metadata["license"] = safe_extract(repo_data.get("license", {}), "name", "License not found")
        metadata["description"] = safe_extract(repo_data, "description", "Description not found")
        metadata["stars"] = safe_extract(repo_data, "stargazers_count", 0)
        metadata["forks"] = safe_extract(repo_data, "forks_count", 0)
        metadata["programming_language"] = safe_extract(repo_data, "language", "No programming language found")

        # Fetch repository topics
        topics_response = requests.get(f"{base_url}/topics", headers=headers)
        if topics_response.status_code == 200:
            topics_data = topics_response.json()
            metadata["topics"] = topics_data.get("names", [])
        
        # Fetch contributors with their full name if available
        contributors_response = requests.get(f"{base_url}/contributors", headers=headers)
        if contributors_response.status_code != 200:
            return jsonify({"error": "Failed to fetch contributors"}), contributors_response.status_code

        contributors_data = contributors_response.json()
        contributors_info = []

        for contributor in contributors_data:
            contributor_login = contributor.get("login", "Unknown")
            user_response = requests.get(f"https://api.github.com/users/{contributor_login}", headers=headers)
            if user_response.status_code == 200:
                user_data = user_response.json()
                contributors_info.append({
                    "login": contributor_login,
                    "name": user_data.get("name", "Name not found"),
                })

        metadata["contributors"] = contributors_info

        # Fetch README URL
        readme_response = requests.get(f"{base_url}/readme", headers=headers)
        if readme_response.status_code == 200:
            readme_data = readme_response.json()
            download_url = readme_data.get("download_url", None)
    
            if download_url:
                # Fetch the raw README content
                raw_readme_response = requests.get(download_url)
                if raw_readme_response.status_code == 200:
                    metadata["readme_content"] = raw_readme_response.text  # Store the raw text content
                else:
                    metadata["readme_content"] = "Failed to fetch README content"
            else:
                metadata["readme_content"] = "README not available for download"
        else:
            metadata["readme_content"] = "README content not available"
    else:
        metadata["error"] = "Failed to fetch repository metadata"

    return jsonify(metadata)

