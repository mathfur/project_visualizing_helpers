var from_string = {
    time: function(str){ return (new Date(Date.parse(str))); },
    number: function(str){ return str*1 },
    string: function(str){ return str }
}

var value_areas = {}

var x_coordinate = null;
var y_coordinate = null;

var x_type = null;
var y_type = null;

var get_scale = function(values, type, range){
    var values = values.map(from_string[type]);

    if(type == 'number'){
        return d3.scale.linear()
                 .domain(d3.extent(values))
                 .range(range);
    }else if(type == 'time'){
        return d3.time.scale()
                 .domain(d3.extent(values))
                 .range(range);
    }else{
        return d3.scale.ordinal()
                 .domain(values)
                 .rangeBands(range);
    }
}

var get_size = {
    number: function(values, range){
                return 10;
            },
    time: function(values, range){
              return 10;
          },
    string: function(values, range){
                var r = ((range[1] - range[0]) / values.length);
                return _.max([r - 2, 1]);
            }
}

var render = function(svg, data, tag, klass, settings){
    var chart = svg.select(".chart-group")
                   .selectAll("." + klass)
                   .data(data);
    chart.enter().append(tag).attr('class', klass).call(settings);
    chart.call(settings);
    chart.exit()
         .transition()
         .style({opacity: 0})
         .remove();
}

var cell_color = d3.scale.linear()
                   .range(["hsl(0, 80%, 20%)", "hsl(0, 80%, 80%)"])
                   .interpolate(d3.interpolateHsl);

var data_table = d3.frt.dataTable()
                   .width(900)
                   .height(300)
                   .main_render(function(svg, container, data_, x, y, chartW, chartH){
                        var font_size = 11;

                        cell_color = cell_color.domain(d3.extent(_.pluck(data_, 'count')));

                        render(svg, data_, 'rect', 'cell', function(){
                            this.attr("width",  get_size[x_type](x_values, [0, chartW]))
                                .attr("height", get_size[y_type](y_values, [0, chartH]))
                                .attr("fill", function(d){ return cell_color(d.count) })
                                .attr('x', function(d){ return x(d[x_coordinate]) })
                                .attr('y', function(d){ return y(d[y_coordinate]) });
                        });

                        render(svg, data_, 'text', 'x-label', function(){
                            this.attr("text-anchor", "middle")
                                .attr('x', function(d){ return x(d[x_coordinate]) })
                                .attr('y', (-1)*font_size)
                                .text(function(d){ return d[x_coordinate] })
                                .on('click', function(){
                                    var text = d3.select(this).text();

                                    var filters = $('#filters').val();
                                    var separator = (filters == '') ? '' : '&';

                                    $('#filters').val(filters + separator + x_coordinate + '=' + text);

                                    x_pop();
                                    update();
                                });
                        });

                        render(svg, data_, 'text', 'y-label', function(){
                            this.attr("text-anchor", "end")
                                .attr('x', 0)
                                .attr('y', function(d){ return y(d[y_coordinate]) })
                                .text(function(d){ return d[y_coordinate] })
                                .on('click', function(){
                                    var text = d3.select(this).text();

                                    var filters = $('#filters').val();
                                    var separator = (filters == '') ? '' : '&';

                                    $('#filters').val(filters + separator + y_coordinate + '=' + text);

                                    y_pop();
                                    update();
                                });
                        });
                   })
                   .xScale(function(data_, chartW, chartH){
                       return get_scale(x_values, x_type, [0, chartW]);
                   })
                   .yScale(function(data_, chartW, chartH){
                       return get_scale(y_values, y_type, [0, chartH]);
                   });

var x_pop = function(){
    var arr = $('#x-coordinate').val().split("\n");
    $('#x-coordinate').val(arr.slice(1).join("\n"));
}

var y_pop = function(){
    var arr = $('#y-coordinate').val().split("\n");
    $('#y-coordinate').val(arr.slice(1).join("\n"));
}

var update = function(){
    var filters = $('#filters').val();

    x_coordinate = $('#x-coordinate').val().split("\n")[0];
    y_coordinate = $('#y-coordinate').val().split("\n")[0];

    filters = filters + "&group[]=" + x_coordinate + "&group[]=" + y_coordinate

    d3.json("/field_types", function(error, field_types){
        x_type = field_types[x_coordinate];
        y_type = field_types[y_coordinate];

        d3.csv("/access_logs?" + filters, function(error, logs){
            if(logs[0]){
                var keys = _.keys(logs[0]);

                var handlers = {};

                _.each(keys, function(k){
                    handlers[k] = from_string[field_types[k]];
                });

                //== convert from string to each type value

                for(var i=0;i < logs.length;i++){
                    _.each(keys, function(k){
                        logs[i][k] = handlers[k](logs[i][k]);
                    });
                }

                //== calculate value areas

                _.each(keys, function(k){
                    value_areas[k] = _.uniq(_.map(logs, function(log){ return handlers[k](log[k]); }));
                })

                x_values = value_areas[x_coordinate];
                y_values = value_areas[y_coordinate];
            }

            d3.select('div#base')
              .datum(logs)
              .call(data_table);
        });
    });
}

d3.select('#update2')
  .on('click', function(){
      update();
  })
