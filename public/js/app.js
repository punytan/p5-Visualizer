function Visualizer($, Morris, Moment) {
  this.getQueryParameters = function() {
    var pairs = (location.href.split("?")[1] || '').split("&");

    var rs = {};
    for (var i = 0; i < pairs.length; i++) {
      var kv  = pairs[i].split("=");
      var key = kv[0], value = kv[1];
      rs[key] = value;
    }

    return rs;
  };

  this.getBaseDate = function() {
    var query = this.getQueryParameters();
    var today = Moment();
    var base  = Moment({
      year:  query.year     || today.year(),
      month: query.month -1 || today.month(),
      day:   query.day      || today.date(),
      hour:  query.hour     || today.hour(),
    });

    return {
      y:    base.format('YYYY'),
      ym:   base.format('YYYY-MM'),
      ymd:  base.format('YYYY-MM-DD'),
      ymdh: base.format('YYYY-MM-DD HH:00:00'),
      base: base,
    };
  };

  this.render = function(name, chartType, aggregator) {
    // chartType:  Line, Area, Bar, Donut
    // aggregator: sum, count, avg, min, max
    if (!aggregator) {
      aggregator = 'sum';
    }

    var renderChart = function(chartType, aggregator, res) {
      var renderer = Morris[chartType || 'Bar'];
      if (!renderer) {
        throw Error("Unknown chartType: " + chartType);
      }

      if (res.length == 0) {
        $('div#mychart').text("No data");
        return;
      }
      new renderer({
        element: 'mychart',
        data:    res,
        xkey:    'datetime',
        ykeys:   [aggregator],
        labels:  [aggregator],
      });
    };

    var renderData = function(res) {
      var mydata = $('div#mydata');

      res.forEach(function(item) {
        var row = $('<div>').addClass('row');
        var datetime = $('<div>').addClass('cell').text(item.datetime),
            sum      = $('<div>').addClass('cell right').text(item.sum),
            min      = $('<div>').addClass('cell right').text(item.min),
            max      = $('<div>').addClass('cell right').text(item.max),
            avg      = $('<div>').addClass('cell right').text(item.avg),
            count    = $('<div>').addClass('cell right').text(item.count);

        row.append(datetime, sum, min, max, avg, count);
        mydata.append(row);
      })
    };

    var query = this.getQueryParameters();
    var spanPath = [ 'year', 'month', 'day', 'hour' ]
      .map(function(i) { return query[i] })
      .reduce(function(a, b) { return Number.isNaN(Number(b)) ? a : a + '/' + b; }, "");

    $.getJSON('/api/metrics/' + name + spanPath)
      .success(function(res) {
        renderChart(chartType, aggregator, res);
        renderData(res);
      })
      .fail(function(res) {
        $('div#mychart').text(res.status + ' ' + res.statusText);
        console.log(res);
      });
  };

  this.getMetricsTitle = function() {
    var query = this.getQueryParameters(),
        spanPath = [ 'year', 'month', 'day' ]
          .filter(function(i) { return !Number.isNaN(Number(query[i])) })
          .map(function(i) { return query[i] })
          .join('-');

    return [ query.name, spanPath,  (query.aggregator || 'sum').toUpperCase() ].join(' ');
  };

  this.onClickChartResolution = function(resolution) {
    var query     = this.getQueryParameters();
    var nextDate  = this.getBaseDate().base.clone();
    switch(resolution) {
      case 'prev-year':
        nextDate.subtract('years', 1);
        break;
      case 'year':
        break;
      case 'next-year':
        nextDate.add('years', 1);
        break;
      case 'prev-month':
        nextDate.subtract('months', 1);
        break;
      case 'month':
        break;
      case 'next-month':
        nextDate.add('months', 1);
        break;
      case 'prev-day':
        nextDate.subtract('days', 1);
        break;
      case 'day':
        break;
      case 'next-day':
        nextDate.add('days', 1);
        break;
    }

    query.year  = nextDate.format('YYYY');
    query.month = nextDate.format('MM');
    query.day   = nextDate.format('DD');

    var purgeKeys = [];
    if (resolution.match(/year/)) {
      purgeKeys.push('month', 'day', 'hour');
    } else if (resolution.match(/month/)) {
      purgeKeys.push('day', 'hour');
    } else if (resolution.match(/day/)) {
      purgeKeys.push('hour');
    }

    purgeKeys.forEach(function(key) {
      delete query[key];
    });

    return  '/metrics.html?' + $.param(query);
  };

  this.onClickChartType = function(type) {
    var query = this.getQueryParameters();
    query['type'] = type;
    return  '/metrics.html?' + $.param(query);
  };

  this.onClickChartAggregator = function(aggregator) {
    var query = this.getQueryParameters();
    query['aggregator'] = aggregator;
    return '/metrics.html?' + $.param(query);
  };

  this.showMetricsList = function(selector) {
    var renderMetricsList = function(res) {
      var items = res.map(function(item) {
        var row = $('<div>').addClass('row');

        var link = $('<div>')
          .addClass('cell left')
          .append(
            $('<a>', {
              href: '/metrics.html?' + $.param({
                year: (new Date()).getFullYear(),
                name: item.metrics_name,
              })
            })
            .text(item.metrics_name)
          );

        var description = $('<div>')
          .addClass('cell left')
          .text(item.description);

        row.append(link, description);
        return row;
      });

      $(selector).append(items);
    };

    $.getJSON('/api/metrics')
      .success(renderMetricsList)
      .fail(function(res) {
        $(selector).text(res.status + ' ' + res.statusText);
        console.log(res);
      });
  };
}

