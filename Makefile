FILES=$(shell find ./ -name '*.coffee' 2> /dev/null)
STATIC+=views/ public/ app.js
OBJECTS=$(addprefix build/, $(subst .coffee,.js,$(FILES)))
# TODO(sissel): put versions in the DEPS string
DEPS=express socket.io jade coffee-script sass
DEPS_OBJECTS=$(addprefix build/node_modules/, $(DEPS))

STATIC_FILES=$(shell find $(STATIC) -type f 2> /dev/null | egrep '\.(css|js|jade|jpg|sass)$$')
STATIC_OBJECTS=$(addprefix build/, $(STATIC_FILES))

COFFEE=./build/node_modules/coffee-script/bin/coffee
VPATH=src
QUIET=@

default: all
all: compile static

build/node_modules/coffee-script: VERSION=1.1.1

clean:
	rm -f $(OBJECTS) $(STATIC_OBJECTS)

superclean:
	rm -fr build/

coffee-script: build/node_modules/coffee-script

%.coffee: Makefile

build/%.js: %.coffee | build coffee-script
	@echo "Compiling $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)$(COFFEE) -c -o $(shell dirname $@) $<

build/%.css: %.css | build
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

build/%.sass: %.sass | build
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

build/%.js: %.js | build
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

build/%.jade: %.jade | build
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

build/%.jpg: %.jpg | build
	@echo "Copying $< (to $@)"
	$(QUIET)[ -d $(shell dirname $@) ] || mkdir -p $(shell dirname $@)
	$(QUIET)cp $< $@

build: 
	$(QUIET)mkdir build

.PHONY: debug
debug:
	echo $(VERSION)

static: $(STATIC_OBJECTS)
compile: deps $(OBJECTS)

build/node_modules: | build
	$(QUIET)mkdir $@

build/node_modules/%: VERSIONSPEC=$(shell [ ! -z "$(VERSION)" ] && echo "@$(VERSION)")
build/node_modules/%: NAME=$(shell basename $@)
build/node_modules/%: | build/node_modules
	@echo "Installing $(NAME)$(VERSIONSPEC)"
	$(QUIET)(cd build; npm install $(NAME)$(VERSIONSPEC))

deps: $(DEPS_OBJECTS)

