var fields = {
    index: {
               type: 'string',
           },
    time: {
              type: 'time',
          },
    user: {
              type: 'string',
          },
    byte: {
              type: 'number',
          },
    req: {
              type: 'string',
           }
}

var from_string = {
    time: function(str){ return (new Date(Date.parse(str))); },
    number: function(str){ return str*1 },
    string: function(str){ return str }
}

var field_handler_s = function(k, d){
    var type = fields[k].type;

    return from_string[type](d[k]);
}

var other_field_handler = function(k, d){
    var type = other_fields[k].type;
    var handler = other_fields[k].handler;

    return from_string[type](handler(d));
}

var other_fields = {};

var value_area_h = function(data, k){
    return _.uniq(_.map(data, _.partial(field_handler_s, k)));
}

var value_areas = {}

var x_coordinate = null;
var y_coordinate = null;
var x_prefix = '#';
var y_prefix = '#';

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

var color = d3.scale.category20();

var data_table = d3.frt.dataTable()
                   .width(900)
                   .height(300)
                   .main_render(function(svg, container, data_, x, y, chartW, chartH){
                        var font_size = 11;

                        render(svg, data_, 'rect', 'cell', function(){
                            this.attr("width",  get_size[fields[x_coordinate].type](value_areas[x_coordinate], [0, chartW]))
                                .attr("height", get_size[fields[y_coordinate].type](value_areas[y_coordinate], [0, chartH]))
                                .attr("fill", "#a00")
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

                                    update();
                                    x_pop();
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

                                    update();
                                    y_pop();
                                });
                        });
                   })
                   .xScale(function(data_, chartW, chartH){
                       return get_scale(value_areas[x_coordinate], fields[x_coordinate].type, [0, chartW]);
                   })
                   .yScale(function(data_, chartW, chartH){
                       return get_scale(value_areas[y_coordinate], fields[y_coordinate].type, [0, chartH]);
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
            x_coordinate = $('#x-coordinate').val().split("\n")[0];
            y_coordinate = $('#y-coordinate').val().split("\n")[0];

            x_prefix = x_coordinate.slice(0, 1);
            y_prefix = y_coordinate.slice(0, 1);

            x_coordinate = x_coordinate.slice(1);
            y_coordinate = y_coordinate.slice(1);

            $('#custom-fields .custom-field').each(function(){
                var k = $(this).find('.key').val();
                var v = $(this).find('.value').val();
                var type = $(this).find('.type').val();

                if(type == ''){
                    type = 'string';
                }

                other_fields[k] = {
                    type: type,
                    handler: function(d){
                        return eval(v);
                    }
                }

                fields[k] = {
                    type: type
                }
            });

            if(!_.has(fields, x_coordinate) && !_.has(other_fields, x_coordinate)){
                alert(x_coordinate + 'is wrong key. [x]');
                return;
            }

            if(!_.has(fields, y_coordinate) && !_.has(other_fields, y_coordinate)){
                alert(y_coordinate + 'is wrong key. [y]');
                return;
            }

            //== calculate custom field values

            for(var i=0;i < logs.length;i++){
                _.each(_.keys(other_fields), function(k){
                    logs[i][k] = other_field_handler(k, logs[i])
                });
            }

            //== convert from string to each type value

            for(var i=0;i < logs.length;i++){
                _.each(_.keys(logs[i]), function(k){
                    logs[i][k] = field_handler_s(k, logs[i]);
                });
            }

            var filters = $('#filters').val();

            var filtered_logs = logs;

            if(filters != ''){
                _.each(filters.split('&'), function(pair){ // pair == 'foo=bar'
                    var k = pair.split('=')[0];
                    var v = pair.split('=')[1];

                    filtered_logs = _.filter(filtered_logs, function(d){ return d[k] == v });
                });
            }

            //== calculate value areas

            _.each(_.keys(logs[0]), function(k){
                value_areas[k] = value_area_h(filtered_logs, k);
            })

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
