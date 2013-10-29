$(function(){
    d3.select('#add-field')
      .on('click', function(){
          var field = d3.select('#custom-fields')
                        .append('div')
                        .attr('id', 'custom-field');

          field.append('button')
               .attr('class', 'delete-field')
               .text('x');

          field.append('input')
               .property('type', 'text')
               .attr('class', 'key');

          field.append('input')
               .property('type', 'text')
               .attr('class', 'type');

          field.append('input')
               .property('type', 'text')
               .attr('class', 'value');
      });
});
