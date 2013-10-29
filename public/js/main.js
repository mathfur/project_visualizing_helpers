var custom_fields = {
    index: {
               type: 'string',
               handler: function(d){
                   return d.index;
               }
           },
    time: {
              type: 'time',
              handler: function(d){
                  return d.time;
              }
          },
    user: {
              type: 'string',
              handler: function(d){
                  return d.user;
              }
          },
    byte: {
              type: 'number',
              handler: function(d){
                  return d.byte;
              }
          },
    query: {
              type: 'string',
              handler: function(d){
                  return d.query;
              }
           }
}

var from_string = {
    time: function(str){ return (new Date(Date.parse(str))); },
    number: function(str){ return str*1 },
    string: function(str){ return str }
}

var field_handler_s = function(k, d){
    var type = custom_fields[k].type;
    var handler = custom_fields[k].handler;

    return from_string[type](handler(d));
}

var x_coordinate = null;
var y_coordinate = null;

var custom_field_values = function(data, k){
    return _.uniq(_.map(data, _.partial(field_handler_s, k)));
}

var x_values = function(data){
  return custom_field_values(data, x_coordinate);
}

var y_values = function(data){
  return custom_field_values(data, y_coordinate);
}

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
                return (range[1] - range[0]) / values.length;
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

var color = d3.scale.category20();

var data_table = d3.frt.dataTable()
                   .width(900)
                   .height(300)
                   .main_render(function(svg, container, data_, x, y, chartW, chartH){
                        var font_size = 11;


                        render(svg, data_, 'rect', 'cell', function(){
                            this.attr("width",  get_size[custom_fields[x_coordinate].type](data_, [0, chartW]))
                                .attr("height", get_size[custom_fields[y_coordinate].type](data_, [0, chartH]))
                                .attr("fill", "#a00")
                                .attr('x', function(d){ return x(field_handler_s(x_coordinate, d)) })
                                .attr('y', function(d){ return y(field_handler_s(y_coordinate, d)) });
                        });

                        render(svg, data_, 'text', 'x-label', function(){
                            this.attr("text-anchor", "middle")
                                .attr('x', function(d){ return x(field_handler_s(x_coordinate, d)) })
                                .attr('y', (-1)*font_size)
                                .text(function(d){ return field_handler_s(x_coordinate, d) })
                                .on('click', function(){
                                    var text = d3.select(this).text();

                                    var filters = $('#filters').val();
                                    var separator = (filters == '') ? '' : '&';

                                    $('#filters').val(filters + separator + x_coordinate + '=' + text);

                                    update();
                                    x_pop();
                                });
                        });

                        render(svg, data_, 'text', 'y-label', function(){
                            this.attr("text-anchor", "end")
                                .attr('x', 0)
                                .attr('y', function(d){ return y(field_handler_s(y_coordinate, d)) })
                                .text(function(d){ return field_handler_s(y_coordinate, d) })
                                .on('click', function(){
                                    var text = d3.select(this).text();

                                    var filters = $('#filters').val();
                                    var separator = (filters == '') ? '' : '&';

                                    $('#filters').val(filters + separator + y_coordinate + '=' + text);

                                    update();
                                    y_pop();
                                });
                        });
                   })
                   .xScale(function(data_, chartW, chartH){
                       return get_scale(x_values(data_), custom_fields[x_coordinate].type, [0, chartW]);
                   })
                   .yScale(function(data_, chartW, chartH){
                       return get_scale(y_values(data_), custom_fields[y_coordinate].type, [0, chartH]);
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
    d3.csv("/access_logs", function(error, logs){
        d3.csv("/users", function(error, users){
            var filtered_logs = logs;

            var filters = $('#filters').val();

            if(filters != ''){
                _.each(filters.split('&'), function(pair){ // pair == 'foo=bar'
                    var k = pair.split('=')[0];
                    var v = pair.split('=')[1];

                    filtered_logs = _.filter(filtered_logs, function(d){ return field_handler_s(k, d) == v });
                });
            }

            x_coordinate = $('#x-coordinate').val().split("\n")[0];
            y_coordinate = $('#y-coordinate').val().split("\n")[0];

            $('#custom-fields .custom-field').each(function(){
                var k = $(this).find('.key').val();
                var v = $(this).find('.value').val();
                var type = $(this).find('.type').val();

                if(type == ''){
                    type = 'string';
                }

                custom_fields[k] = {
                    type: type,
                    handler: function(d){
                        return eval(v);
                    }
                }
            });

            d3.select('div#base')
              .datum(filtered_logs)
              .call(data_table);
        });
    });
}

d3.select('#update2')
  .on('click', function(){
      update();
  })
