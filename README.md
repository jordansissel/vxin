# vxin

vxin, pronounced "vixen," is a project aimed at doing general purpose data
visualization.

The goal of this project is to solve the visual needs and experiments of
[logstash](http://logstash.net/), but aims to be general purpose. Like logstash
is a general purpose log/event pipeline and management tool, I want vxin to of
the same wide purpose.

Tentatively, the design will follow logstash's model of inputs, filters, and
outputs. The one catch is that in this case code could be server side or
browser/client side, so you could do fun stuff like having a query from a
server be filtered and displayed on the browser. Alternately, input, filter,
and output could happen entirely on the server-side (say, for generating
reports to email out)

An example below is of an elasticsearch term facet query (input) and outputting
a pie chart and a data table. The pie data uses log scale to make it easy to
see the whole data set.

![example pie chart](https://github.com/jordansissel/vxin/raw/master/media/elasticsearch-logstash-piesnacking.png)
