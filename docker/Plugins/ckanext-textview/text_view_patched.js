ckan.module('text_view', function (jQuery) {
  return {
    options: {
      parameters: {
        json: {
          contentType: 'application/json',
          dataType: 'json',
          dataConverter: function (data) { return JSON.stringify(data, null, 2); },
          language: 'json'
        },
        jsonp: {
          contentType: 'application/javascript',
          dataType: 'jsonp',
          dataConverter: function (data) { return JSON.stringify(data, null, 2); },
          language: 'json'
        },
        xml: {
          contentType: 'text/xml',
          dataType: 'text',
          language: 'xml'
        },
        text: {
          contentType: 'text/plain',
          dataType: 'text',
          language: ''
        }
      }
    },
    initialize: function () {
      var self = this;
      var format = preload_resource['format'].toLowerCase();

      var TEXT_FORMATS = preview_metadata['text_formats'];
      var XML_FORMATS = preview_metadata['xml_formats'];
      var JSON_FORMATS = preview_metadata['json_formats'];
      var JSONP_FORMATS = preview_metadata['jsonp_formats'];

      var p;

      if (JSON_FORMATS.indexOf(format) !== -1) {
        p = this.options.parameters.json;
      } else if (JSONP_FORMATS.indexOf(format) !== -1) {
        p = this.options.parameters.jsonp;
      } else if(XML_FORMATS.indexOf(format) !== -1) {
        p = this.options.parameters.xml;
      } else {
        p = this.options.parameters.text;
      }

error_div_409 = '<div id="sec-download" class="sec-head" style="background:#ffe8de;font-family:Helvetica !important; padding:20px">\
<h2 style="border-bottom: 1px solid #000;">PREVIEW NOTES</h2>\
<p><img loading="lazy" class="alignleft" src="https://code-boxx.com/wp-content/uploads/2019/08/ico-download.svg" width="80" height="80">\
</p><p>Content is too large to be proxied.</p><p>Allowedfile size: 1048576.</p></div>';

error_div_other = '<div id="sec-download" class="sec-head" style="background:#ffe8de;font-family:Helvetica !important; padding:20px">\
<h2 style="border-bottom: 1px solid #000;">PREVIEW NOTES</h2>\
<p><img loading="lazy" class="alignleft" src="https://code-boxx.com/wp-content/uploads/2019/08/ico-download.svg" width="80" height="80">\
</p><p>There was a problem accessing to the file.</div>';

      jQuery.ajax(resource_url, {
        type: 'GET',
        contentType: p.contentType,
        dataType: p.dataType,
        success: function(data, textStatus, jqXHR) {
          data = p.dataConverter ? p.dataConverter(data) : data;
          var highlighted;

          if (p.language) {
            highlighted = hljs.highlight(p.language, data, true).value;
          } else {
            highlighted = '<pre>' + data + '</pre>';
          }

          self.el[0].innerHTML = highlighted;
        },
        error: function(jqXHR, textStatus, errorThrown) {
          if (textStatus == 'error' && jqXHR.responseText) {
            if(jqXHR.status==409) self.el.html(error_div_409);
            else self.el.html(error_div_other);
            //self.el.html(jqXHR.responseText);
          } else {
            self.el.html(self._(
              'An error occured during AJAX request. Could not load view.')
            );
          }
        }
      });
    }
  };
});
