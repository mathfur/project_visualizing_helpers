$(function(){
    var keys = _.keys(data[0]);
    var x_coordinate = keys[0];
    var y_coordinate = keys[1];

    var x_values = _.uniq(_.pluck(data, x_coordinate));
    var y_values = _.uniq(_.pluck(data, y_coordinate));

    var data_table = d3.pvh.dataTable()
                       .width(900)
                       .height(300)
                       .main_render(function(svg, container, data_, x, y, chartW, chartH){
                            var font_size = 11;

                            this.render(svg, data_, 'rect', 'cell', function(){
                                this.attr("width",  _.max([chartW / x_values.length - 1, 1]))
                                    .attr("height", _.max([chartH / y_values.length - 1, 1]))
                                    .attr("fill", function(d){ return '#600' })
                                    .attr('x', function(d){ return x(d[x_coordinate]) })
                                    .attr('y', function(d){ return y(d[y_coordinate]) })
                                    .on('mouseover', function(d){
                                      d3.select('div#base')
                                        .append('div')
                                        .attr('class', 'cell_data')
                                        .text(function(){ return JSON.stringify(_.omit(d, x_coordinate, y_coordinate)) });
                                    })
                                    .on('mouseout', function(d){
                                      d3.select('div.cell_data').remove();
                                    });
                            });

                            this.render(svg, data_, 'text', 'x-label', function(){
                                this.attr("text-anchor", "middle")
                                    .attr('x', function(d){ return x(d[x_coordinate]) })
                                    .attr('y', 0)
                                    .text(function(d){ return d[x_coordinate] })
                            });

                            this.render(svg, data_, 'text', 'y-label', function(){
                                this.attr("text-anchor", "end")
                                    .attr('x', 0)
                                    .attr('y', function(d){ return y(d[y_coordinate]) })
                                    .text(function(d){ return d[y_coordinate] })
                            });
                       })
                       .xScale(function(data_, chartW, chartH){
                           return d3.scale.ordinal()
                                    .domain(x_values)
                                    .rangeBands([0, chartW]);
                       })
                       .yScale(function(data_, chartW, chartH){
                           return d3.scale.ordinal()
                                    .domain(y_values)
                                    .rangeBands([0, chartH]);
                       });


    d3.select('div#base')
      .datum(data)
      .call(data_table);
});
