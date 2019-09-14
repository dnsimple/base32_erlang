REBAR:=$(shell which rebar3 || echo ./rebar3)
REBAR_URL:="https://s3.amazonaws.com/rebar3/rebar3"

all: deps compile

$(REBAR):
	wget $(REBAR_URL) && chmod +x rebar3

compile: $(REBAR)
	@$(REBAR) compile

deps: $(REBAR)
	@$(REBAR) get-deps

doc: $(REBAR)
	@$(REBAR) doc skip_deps=true

clean: $(REBAR)
	@$(REBAR) clean
	@rm -fr doc/*

fresh:
	rm -fr _build/*

test: $(REBAR) all
	@$(REBAR) eunit skip_deps=true
