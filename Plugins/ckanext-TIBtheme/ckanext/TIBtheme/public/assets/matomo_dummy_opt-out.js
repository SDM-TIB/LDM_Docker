$(document).ready(function(){

  function setOptOutText(element) {
      document.querySelector('label[for=optout] strong').innerText = $("#optout").is(':checked')
        ? $('#optout').attr("opted_out_msg")
        : $('#optout').attr("opted_in_msg");
      }

      var optOut = $("#optout");

      optOut.click(function() {
            setOptOutText(optOut);
        });

      setOptOutText(optOut);
});