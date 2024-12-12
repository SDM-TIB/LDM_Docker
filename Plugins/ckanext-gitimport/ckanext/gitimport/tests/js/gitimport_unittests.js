import { JSDOM } from "jsdom";
import sinon from "sinon";
import { expect } from "chai";
import {
  clearFieldsById,
  clearDynamicFields,
  resetFields,
  fetchGitHubMetadata,
  handleAuthors,
  handleContributors,
  handleTopics,
  setReadmeLink
} from "./gitimport_functions.js";

// Set up the DOM environment
const { window } = new JSDOM("<!doctype html><html><body></body></html>");
const { document } = window;

describe("clearFieldsById", () => {
  it("clears fields by ID", () => {
    // Arrange
    document.body.innerHTML = `
      <input id="field-repo_name" value="SDM-TIB/InterpretME">
      <input id="field-github_owner" value="SDM-TIB">
      <input id="field-github_contributor" value="prohde">
    `;

    // Act
    clearFieldsById(document, ["field-github_owner", "field-github_contributor"]);

    // Assert
    expect(document.getElementById("field-repo_name").value).to.equal("SDM-TIB/InterpretME");
    expect(document.getElementById("field-github_owner").value).to.equal("");
    expect(document.getElementById("field-github_contributor").value).to.equal("");
  });
});

describe("clearDynamicFields", () => {
  it("clears dynamic fields", () => {
    // Arrange
    document.body.innerHTML = `
      <input id="field-extra_contribs-0-extra_contrib" value="dishaa19">
      <input id="field-extra_contribs-1-extra_contrib" value="yashrajchudasama26">
      <input id="field-extra_contribs-2-extra_contrib" value="JulianLoewe">
    `;

    // Act
    clearDynamicFields(document, "field-extra_contribs-${index}-extra_contrib", 0);

    // Assert
    expect(document.getElementById("field-extra_contribs-0-extra_contrib").value).to.equal("");
    expect(document.getElementById("field-extra_contribs-1-extra_contrib").value).to.equal("");
    expect(document.getElementById("field-extra_contribs-2-extra_contrib").value).to.equal("");
  });
});

describe("resetFields", () => {
  it("resets all GitHub metadata fields", () => {
    // Arrange
    document.body.innerHTML = `
      <input id="field-github_owner" value="SDM-TIB">
      <input id="field-github_contributor" value="prohde">
      <input id="field-extra_contribs-0-extra_contrib" value="dishaa19">
      <input id="field-extra_contribs-1-extra_contrib" value="yashrajchudasama26">
      <input id="field-extra_contribs-2-extra_contrib" value="JulianLoewe"> 
    `;

    // Act
    resetFields(document);

    // Assert
    expect(document.getElementById("field-github_owner").value).to.equal("");
    expect(document.getElementById("field-github_contributor").value).to.equal("");
    expect(document.getElementById("field-extra_contribs-0-extra_contrib").value).to.equal("");
    expect(document.getElementById("field-extra_contribs-1-extra_contrib").value).to.equal("");
    expect(document.getElementById("field-extra_contribs-2-extra_contrib").value).to.equal("");
  });
});

describe("fetchGitHubMetadata", () => {
  let sandbox;
  let fetchStub;

  beforeEach(() => {
    sandbox = sinon.createSandbox();
    fetchStub = sandbox.stub(global, "fetch");

    // Mock sessionStorage
    global.sessionStorage = {
      setItem: sinon.spy()
    };
  });

  afterEach(() => {
    sandbox.restore();
    delete global.sessionStorage;
  });

  it("populates fields with fetched data and stores README URL", async () => {
    // Arrange
    const mockMetaData = {
      repoName: "SDM-TIB/InterpretME",
      owner: "SDM-TIB",
      license: "MIT license",
      description: "An interpretable machine learning pipeline over knowledge graphs",
      stars: 23,
      forks: 2,
      programming_language: "Jupyter Notebook",
      readme_url: "https://github.com/SDM-TIB/InterpretME/readme"
    };
    fetchStub.resolves({ json: () => Promise.resolve(mockMetaData) });
    document.body.innerHTML = `
      <input id="field-github_owner">
      <input id="field-license">
      <input id="field-github_description">
      <input id="field-repository_stars">
      <input id="field-repository_forks">
      <input id="field-programming_language">
    `;

    // Act
    await fetchGitHubMetadata(document, "SDM-TIB/InterpretME");

    // Assert
    expect(document.getElementById("field-github_owner").value).to.equal("SDM-TIB");
    expect(document.getElementById("field-license").value).to.equal("MIT license");
    expect(document.getElementById("field-github_description").value).to.equal("An interpretable machine learning pipeline over knowledge graphs");
    expect(document.getElementById("field-repository_stars").value).to.equal("23");
    expect(document.getElementById("field-repository_forks").value).to.equal("2");
    expect(document.getElementById("field-programming_language").value).to.equal("Jupyter Notebook");
    expect(global.sessionStorage.setItem.calledWith("githubReadmeUrl", "https://github.com/SDM-TIB/InterpretME/readme")).to.be.true;
  });
});


describe("handleAuthors", () => {
  it("populates author fields correctly and creates dynamic fields for additional authors", (done) => {
    // Arrange
    const authors = [{ name: "Philipp D. Rohde" }, { name: "Disha Purohit" }, { name: "Yashrajsinh Chudasama" }, { name: "Julian Gercke" }];

    document.body.innerHTML = `
      <input id="field-github_author">
      <button class="btn btn-link" name="repeating-add"></button>
    `;

    // Simulate the click button by adding additional author fields to DOM
    authors.slice(1).forEach((_, index) => {
      document.body.insertAdjacentHTML("beforeend", `<input id="field-extra_authors-${index}-extra_author">`);
    });

    // Act
    handleAuthors(document, authors);

    // Since handleAuthors uses setTimeout, we wait before making assertions
    setTimeout(() => {
      // Assert
      expect(document.getElementById("field-github_author").value).to.equal("Philipp D. Rohde");
      expect(document.getElementById("field-extra_authors-0-extra_author").value).to.equal("Disha Purohit");
      expect(document.getElementById("field-extra_authors-1-extra_author").value).to.equal("Yashrajsinh Chudasama");
      expect(document.getElementById("field-extra_authors-2-extra_author").value).to.equal("Julian Gercke");

      done();
    }, 10);
  });
});

describe("handleContributors", () => {
  it("creates and populates contributor fields correctly", () => {
    // Arrange
    const contributors = [{ login: "prohde" }, { login: "dishaa19" }, { login: "yashrajchudasama26" }, { login: "JulianLoewe" }];
    document.body.innerHTML = `
      <input id="field-github_contributor">
      <button class="btn btn-link" name="repeating-add"></button>
    `;

    // Simulate the click button by adding additional contributor fields to DOM
    contributors.slice(1).forEach((_, index) => {
      document.body.insertAdjacentHTML('beforeend', `<input id="field-extra_contribs-${index}-extra_contrib">`);
    });

    // Act
    handleContributors(document, contributors);

    // Assert
    expect(document.getElementById("field-github_contributor").value).to.equal("prohde");
    expect(document.getElementById("field-extra_contribs-0-extra_contrib").value).to.equal("dishaa19");
    expect(document.getElementById("field-extra_contribs-1-extra_contrib").value).to.equal("yashrajchudasama26");
    expect(document.getElementById("field-extra_contribs-2-extra_contrib").value).to.equal("JulianLoewe");
  });
});

describe("handleTopics", () => {
  it("creates and populates topic fields correctly", () => {
    // Arrange
    const topics = ["knowledge-graph", "ontologies", "shacl", "interpretability", "machine-learning-models", "machine-learning-interpretability"];
    document.body.innerHTML = `
      <input id="field-repository_topics">
      <button class="btn btn-link" name="repeating-add"></button>
    `;

    // Manually add additional topic fields to DOM
    topics.slice(1).forEach((_, index) => {
      document.body.insertAdjacentHTML('beforeend', `<input id="field-extra_topics-${index}-extra_topic">`);
    });

    // Act
    handleTopics(document, topics);

    // Assert
    expect(document.getElementById("field-repository_topics").value).to.equal("knowledge-graph");
    expect(document.getElementById("field-extra_topics-0-extra_topic").value).to.equal("ontologies");
    expect(document.getElementById("field-extra_topics-1-extra_topic").value).to.equal("shacl");
    expect(document.getElementById("field-extra_topics-2-extra_topic").value).to.equal("interpretability");
    expect(document.getElementById("field-extra_topics-3-extra_topic").value).to.equal("machine-learning-models");
    expect(document.getElementById("field-extra_topics-4-extra_topic").value).to.equal("machine-learning-interpretability");
  });
});

describe("setReadmeLink", () => {
  it("sets the README link in the input field", (done) => {
    // Arrange
    const readmeUrl = "https://github.com/SDM-TIB/InterpretME/readme";
    document.body.innerHTML = `
      <button id="resource-link-button"></button>
      <input id="field-resource-url">
    `;

    // Act
    setReadmeLink(document, readmeUrl);

    // Since setReadmeLink uses setTimeout, we wait before making assertions
    setTimeout(() => {
      // Assert
      const urlInputField = document.getElementById("field-resource-url");
      expect(urlInputField.value).to.equal(readmeUrl);

      done();
    }, 100);
  });
});
