FILES=$(shell find ./ -name '*.coffee' 2> /dev/null)
STATIC+=views/ public/ app.js
OBJECTS=$(addprefix $(BUILDDIR)/, $(subst .coffee,.js,$(FILES)))
# TODO(sissel): put versions in the DEPS string
DEPS=express socket.io jade coffee-script sass http-proxy
DEPS_OBJECTS=$(addprefix $(BUILDDIR)/node_modules/, $(DEPS))

STATIC_FILES=$(shell find $(STATIC) -type f 2> /dev/null | egrep '\.(css|js|jade|jpg|sass)$$')
STATIC_OBJECTS=$(addprefix $(BUILDDIR)/, $(STATIC_FILES))

COFFEE=./$(BUILDDIR)/node_modules/coffee-script/bin/coffee
VPATH=src
QUIET=@
BUILDDIR=build

default: all
all: compile static

$(BUILDDIR)/node_modules/coffee-script: VERSION=1.1.1

clean:
	rm -f $(OBJECTS) $(STATIC_OBJECTS)

superclean:
	rm -fr $(BUILDDIR)/

coffee-script: $(BUILDDIR)/node_modules/coffee-script

%.coffee: Makefile

$(BUILDDIR)/%.js: %.coffee | $(BUILDDIR) coffee-script
	@echo "Compiling $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)$(COFFEE) -c -o $(shell dirname $@) $<

$(BUILDDIR)/%.css: %.css | $(BUILDDIR)
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

$(BUILDDIR)/%.sass: %.sass | $(BUILDDIR)
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

$(BUILDDIR)/%.js: %.js | $(BUILDDIR)
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

$(BUILDDIR)/%.jade: %.jade | $(BUILDDIR)
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

$(BUILDDIR)/%.jpg: %.jpg | $(BUILDDIR)
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

$(BUILDDIR): 
	$(QUIET)mkdir $(BUILDDIR)

.PHONY: debug
debug:
	echo $(VERSION)

static: $(STATIC_OBJECTS)
compile: deps $(OBJECTS)

$(BUILDDIR)/node_modules: | $(BUILDDIR)
	$(QUIET)mkdir $@

$(BUILDDIR)/node_modules/%: VERSIONSPEC=$(shell [ ! -z "$(VERSION)" ] && echo "@$(VERSION)")
$(BUILDDIR)/node_modules/%: NAME=$(shell basename $@)
$(BUILDDIR)/node_modules/%: | $(BUILDDIR)/node_modules
	@echo "Installing $(NAME)$(VERSIONSPEC)"
	$(QUIET)(cd $(BUILDDIR); npm install $(NAME)$(VERSIONSPEC))

deps: $(DEPS_OBJECTS)

$(BUILDDIR)/vxin-loggly-full.js: compile
	cat \
	$(BUILDDIR)/public/javascripts/d3/d3.js \
	$(BUILDDIR)/public/javascripts/d3/d3.geom.js \
	$(BUILDDIR)/public/javascripts/d3/d3.behavior.js \
	$(BUILDDIR)/public/javascripts/d3/d3.layout.js \
	$(BUILDDIR)/public/javascripts/d3/d3.csv.js \
	$(BUILDDIR)/public/javascripts/d3/d3.time.js \
	$(BUILDDIR)/public/javascripts/d3/d3.chart.js \
	$(BUILDDIR)/public/javascripts/d3/d3.geo.js \
	$(BUILDDIR)/public/javascripts/inputs/*.js \
	$(BUILDDIR)/public/javascripts/outputs/*.js \
	$(BUILDDIR)/public/javascripts/widget.js \
	$(BUILDDIR)/public/javascripts/vxin-loggly.js \
	> $@
