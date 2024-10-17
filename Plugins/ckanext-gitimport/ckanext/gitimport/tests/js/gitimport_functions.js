// Function to clear fields by their IDs
function clearFieldsById(document, fieldIds) {
  fieldIds.forEach(function (fieldId) {
    var field = document.getElementById(fieldId);
    if (field) {
      field.value = "";
    }
  });
}

// Function to clear dynamically named fields with a base pattern and starting index
function clearDynamicFields(document, baseIdPattern, startIndex) {
  var index = startIndex;
  var fieldId, field;
  while ((field = document.getElementById(fieldId = baseIdPattern.replace("${index}", index)))) {
    field.value = "";
    index++;
  }
}

// Function to reset/clear all the GitHub metadata fields
function resetFields(document) {
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
  clearFieldsById(document, metadataFields);

  // Clear dynamic fields for contributors, authors, and topics
  clearDynamicFields(document, "field-extra_contribs-${index}-extra_contrib", 0);
  clearDynamicFields(document, "field-extra_authors-${index}-extra_author", 0);
  clearDynamicFields(document, "field-extra_topics-${index}-extra_topic", 0);
}

// Function to fetch GitHub repository metadata from the endpoint
async function fetchGitHubMetadata(document, repoName) {
  var apiUrl = `/gitimport/fetch?repo_name=${encodeURIComponent(repoName)}`;

  // Make a fetch request to the endpoint
  try {
    const response = await fetch(apiUrl);
    const data = await response.json();
    if (data.error) {
      resetFields(document);
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
      handleTopics(document, data.topics || []);
      handleContributors(document, data.contributors || []);

      // Set README URL
      if (data.readme_url) {
        sessionStorage.setItem("githubReadmeUrl", data.readme_url);
        setReadmeLink(document, data.readme_url);
      } else {
        console.error("README URL not found.");
      }
    }
  } catch (error) {
    resetFields(document);
    console.error("Failed to fetch GitHub metadata from server:", error);
  }
}

function handleAuthors(document, contributors) {
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

function handleContributors(document, contributors) {
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

  handleAuthors(document, contributors);
}

function handleTopics(document, topics) {
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

function setReadmeLink(document, readmeUrl) {
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
}

// Export the functions
export {
  clearFieldsById,
  clearDynamicFields,
  resetFields,
  fetchGitHubMetadata,
  handleAuthors,
  handleContributors,
  handleTopics,
  setReadmeLink
};
