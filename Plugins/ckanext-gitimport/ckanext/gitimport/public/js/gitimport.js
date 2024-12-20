document.addEventListener("DOMContentLoaded", function () {
  if (window.location.href.indexOf("/github/new") !== -1) {

    // Function to clear fields by their IDs
    function clearFieldsById(fieldIds) {
      fieldIds.forEach(function (fieldId) {
        var field = document.getElementById(fieldId);
        if (field) {
          field.value = "";
        }
      });
    }

    // Function to clear dynamically named fields with a base pattern and starting index
    function clearDynamicFields(baseIdPattern, startIndex) {
      var index = startIndex;
      var fieldId, field;
      while (field = document.getElementById(fieldId = baseIdPattern.replace('${index}', index))) {
        field.value = "";
        index++;
      }
    }

    // Function to reset/clear all the GitHub metadata fields
    function resetFields() {
      var metadataFields = [
        "field-github_owner",
        "field-github_contributor",
        "field-github_author",
        "field-repository_topics",
        "field-license",
        "field-github_description",
        "field-repository_stars",
        "field-repository_forks",
        "field-programming_language",
      ];

      // Clear metadata fields
      clearFieldsById(metadataFields);

      // Clear dynamic fields for contributors, authors, and topics
      clearDynamicFields('field-extra_contribs-${index}-extra_contrib', 0);
      clearDynamicFields('field-extra_authors-${index}-extra_author', 0);
      clearDynamicFields('field-extra_topics-${index}-extra_topic', 0);
    }

    // Function to fetch GitHub repository metadata from the endpoint
    function fetchGitHubMetadata(repoName) {
          // Get the full current URL and split it before '/github/new'
		  var baseUrl = window.location.href.split('/github/new')[0];
		  var apiUrl = `${baseUrl}/gitimport/fetch?repo_name=${encodeURIComponent(repoName)}`;
		
      // Make a fetch request to the endpoint
      return fetch(apiUrl)
        .then(function (response) {
          return response.json();
        })
        .then(function (data) {
          if (data.error) {
            resetFields();
            console.error("Error fetching metadata from server:", data.error);
          } else {
            // Populate metadata fields
            document.getElementById("field-github_owner").value = data.owner || "Owner not found";
            document.getElementById("field-license").value = data.license || "License not found";
            document.getElementById("field-github_description").value = data.description || "Description not found";
            document.getElementById("field-repository_stars").value = data.stars || 0;
            document.getElementById("field-repository_forks").value = data.forks || 0;
            document.getElementById("field-programming_language").value = data.programming_language || "No programming language found";
             
    
            // Handle topics and contributors
            handleTopics(data.topics || []);
            handleContributors(data.contributors || []);
    
            // Set README URL
            if (data.readme_content) {
              // Populate the README content into the "notes" field
              document.getElementById("field-notes").value = data.readme_content;
            } else {
              console.error("README content not found.");
            }
           
                
            /*if (data.readme_url) {
              sessionStorage.setItem("githubReadmeUrl", data.readme_url);
              setReadmeLink(data.readme_url);
            } else {
              console.error("README URL not found.");
            }*/
          }
        })
        .catch(function (error) {
          resetFields();
          console.error("Failed to fetch GitHub metadata from server:", error);
        });
    }

    function handleAuthors(contributors) {
      var authors = contributors.map(contributor => contributor.name).filter(name => name);
    
      if (authors.length > 0) {
        document.getElementById("field-github_author").value = authors[0];
      }
    
      for (var i = 1; i < authors.length; i++) {
        var fieldId = `field-extra_authors-${i-1}-extra_author`;
        var existingField = document.getElementById(fieldId);
    
        // Check if the field already exists before adding new ones
        if (existingField) {
          existingField.value = authors[i];
        } else {
          var addButton = document.querySelectorAll('.btn.btn-link[name="repeating-add"]')[1];
          addButton.click();
          setTimeout(function() {
            var newField = document.getElementById(`field-extra_authors-${i-1}-extra_author`);
            if (newField) {
              newField.value = authors[i];
            }
          }, 10);
        }
      }
    }
    
    function handleContributors(contributors) {
      contributors.forEach((contributor, index) => {
        var fieldId = index === 0 ? "field-github_contributor" : `field-extra_contribs-${index-1}-extra_contrib`;
        var existingField = document.getElementById(fieldId);
    
        // Check if the field already exists before adding new ones
        if (!existingField) {
          var addButton = document.querySelector('.btn.btn-link[name="repeating-add"]');
          addButton.click();
          existingField = document.getElementById(fieldId);
        }
    
        if (existingField) {
          existingField.value = contributor.login;
        }
      });
    
      handleAuthors(contributors);
    }
    
    function handleTopics(topics) {
      topics.forEach((topic, index) => {
        var fieldId = index === 0 ? "field-repository_topics" : `field-extra_topics-${index-1}-extra_topic`;
        var existingField = document.getElementById(fieldId);
    
        // Check if the field already exists before adding new ones
        if (!existingField) {
          var addButton = document.querySelectorAll('.btn.btn-link[name="repeating-add"]')[2];
          addButton.click();
          existingField = document.getElementById(fieldId);
        }
    
        if (existingField) {
          existingField.value = topic;
        }
      });
    }

    // Main logic
    var repoInput = document.getElementById("field-github_repo");
    var originalRepoName = "";
    var fetchButton;

    if (repoInput) {
      // Create and insert the fetch button next to the repo input
      fetchButton = document.createElement("button");
      fetchButton.innerText = "Fetch Metadata";
      fetchButton.style.display = "inline";
      fetchButton.onclick = function(event) {
        event.preventDefault();
        
        var repoName = repoInput.value.trim();
        if (repoName) {
          resetFields();
          fetchGitHubMetadata(repoName);
          originalRepoName = repoName; // Update the originalRepoName after fetching
        }
      };
      repoInput.parentNode.insertBefore(fetchButton, repoInput.nextSibling);

      // Event listener for "input" events
      repoInput.addEventListener("input", function () {
        var repoName = this.value.trim();
      
        // If the user erases the repoName, reload the page
        if (repoName === "") {
          resetFields();
          originalRepoName = "";
          window.location.reload();
          return;
        }
      
        // If the repo name changes, we reset all fields
        if (repoName !== originalRepoName) {
          resetFields();
          originalRepoName = repoName;
        }
      });

      // Event listener for "paste" events
      repoInput.addEventListener("paste", function (event) {
        event.preventDefault();
        var pastedText = (event.clipboardData || window.clipboardData).getData("text");
        var newRepoName = pastedText.trim();
        this.value = newRepoName;
      
        resetFields(); 
      });
    }
  }
});

// Function to set the README link in the input field
window.setReadmeLink = function(readmeUrl) {
  var linkButton = document.getElementById("resource-link-button");
  if (linkButton) {
    linkButton.click();
  }

  setTimeout(function() {
    var urlInputField = document.getElementById("field-resource-url");
    if (urlInputField) {
      urlInputField.value = readmeUrl;
    }
  }, 100);
};

document.addEventListener("DOMContentLoaded", function() {
  var urlPattern = /\/github\/[^\/]+\/resource\/new/;
  if (urlPattern.test(window.location.href)) {
    var readmeUrl = sessionStorage.getItem("githubReadmeUrl");
    if (readmeUrl) {
      setReadmeLink(readmeUrl);
      console.log("Retrieved README URL from sessionStorage and set in input field:", readmeUrl);
    } else {
      console.log("No README URL found in sessionStorage");
    }
  }
});
