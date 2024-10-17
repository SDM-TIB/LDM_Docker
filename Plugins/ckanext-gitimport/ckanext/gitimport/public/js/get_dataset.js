document.addEventListener("DOMContentLoaded", function() {
    var githubLinkButton = document.getElementById("githubLinkButton");
    if (githubLinkButton) {
        githubLinkButton.addEventListener("click", function() {
            window.location.href = "/ldmservice/github/";
        });
    }
});