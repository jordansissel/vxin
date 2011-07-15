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

## Use case example

Ever use Excel? You know how easy it is to make totally arbitrary graphs and pivot tables? I want that.

I want programmable and interactive visuals. I want to be able to take a data
source and ask "What graphs can I make with this?" and then try pie charts, bar
charts, all kinds of silly graphs to see how I can get the data to make sense.

## What?

Example inputs: elasticsearch, websockets, graphite, ganglia, logs, etc

Example filters: mapreduce, "top N", sort, etc

Example outputs: pie charts, line graphs, histograms, flow charts, etc

Some data comes as an unlimited stream, other is queryable and finite. We can
achieve "top N" and "sort" filtration on these streams if we are careful.

"top N" could emit the top N elements every N seconds, or be queryable. The
same goes for sort.  Finite data sets are easier as they can simply emit top N
or sorted results when we are finished reading all the data.

I'm still looking to target both unbounded/unlimited data streams and also
manage finite data sets with the same tools.
