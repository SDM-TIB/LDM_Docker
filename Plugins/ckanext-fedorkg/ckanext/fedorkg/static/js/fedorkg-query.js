const yasgui = new Yasgui(document.getElementById("yasgui"), {
    persistenceId: null,
    yasqe: {
        // modify codemirror tab handling to solely use 2 spaces
        tabSize: 2,
        indentUnit: 2,
        // set default query
        value: "SELECT DISTINCT ?concept\nWHERE {\n\t?s a ?concept\n} LIMIT 10"
    },
    extraKeys: {
        Tab: function (cm) {
            var spaces = new Array(cm.getOption("indentUnit") + 1).join(" ");
            cm.replaceSelection(spaces);
        }
    },
    requestConfig: {
        // configuring the endpoint for DeTrusty
        endpoint: window.location.href,
        method: "POST",
        args: [{name: "yasqe", value: true}]
    }
});

let tab = yasgui.getTab();
tab.setName(default_query_name);
tab.setQuery(default_query);

const llm_form = document.getElementById("llm"),
      loader = document.querySelector("#loading");

function displayLoading() {
    loader.classList.add("display");
}

function hideLoading() {
    loader.classList.remove("display");
}

llm_form.onsubmit = async function (event) {
    event.preventDefault();
    displayLoading();

    let data = new FormData();
    data.append("question", document.getElementById("question").value)
    let query = await fetch("/fedorkg/llm", {method: "POST", body: data})
        .then(res => { hideLoading(); return res.text(); })
        .catch(err => console.error(err));

    tab = yasgui.getTab();
    tab.setName("LLM Query");
    tab.setQuery(query);
    tab.query();
};
