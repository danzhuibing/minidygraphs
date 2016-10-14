HTMLWidgets.widget({

  name: 'minidygraphs',

  type: 'output',

  factory: function(el, width, height) {

    // reference to dygraph
    var dygraph = null;

    return {

      renderValue: function(x) {
        var thiz = this;

        // get dygraph attrs and populate file field
        var attrs = x.attrs;
        attrs.file = x.data; // save data to attrs in order to be accessed from R later.

        // resolve "auto" legend behavior
        if(x.attrs.legend === "auto") {
          if(x.data.length <= 2)
            x.attrs.legend = "onmouseover";
          else
            x.attrs.legend = "always";
        }

        // provide an automatic x value formatter if none is already specified
        if (attrs.axes.x.valueFormatter === undefined)
          attrs.axes.x.valueFormatter = this.xValueFormatter(x.scale);

        attrs.file[0] = attrs.file[0].map(function(value) {
          return thiz.normalizeDateValue(x.scale, value);
        });

        // transpose array
        attrs.file = HTMLWidgets.transposeArray2D(attrs.file);

        dygraph = new Dygraph(el, attrs.file, attrs);


      },

      xValueFormatter: function(scale) {

        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

        return function(millis) {
          var date = new Date(millis);
            if (scale == "yearly")
              return date.getFullYear();
            else if (scale == "monthly" || scale == "quarterly")
              return monthNames[date.getMonth()] + ', ' + date.getFullYear();
            else if (scale == "daily" || scale == "weekly")
              return monthNames[date.getMonth()] + ', ' +
                               date.getDate() + ', ' +
                               date.getFullYear();
            else
              return date.toLocaleString();
        };
      },

      normalizeDateValue: function(scale, value) {
        var date = new Date(value);
        if (scale != "minute" && scale != "hourly" && scale != "seconds") {
          var localAsUTC = date.getTime() + (date.getTimezoneOffset() * 60000);
          date = new Date(localAsUTC);
        }
        return date;
      },

      resize: function(width, height) {

        if(dygraph) {
          dygraph.resize();
        }
      },

      // export dygraph so other code can get a hold of it
      dygraph: dygraph

    };
  }
});
