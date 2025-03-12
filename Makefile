gems = $(shell sed -nE "s/.*spec.add_dependency '([^']+)'.*/\1/p" kaching.gemspec)

.PHONY: deps
deps: ## Install dependencies
	gem install bundler -v 2.6.5
	bundle install

.PHONY: test
test: ## Run all tests
test: test-rake test-typecheck

.PHONY: test-rake
test-rake:
	bundle exec rake

.PHONY: test-typecheck
test-typecheck:
	$(foreach _,$(gems),bundle exec yard gems $(_);)
	bundle exec solargraph typecheck --level typed

.PHONY: help
help: ## Show this help text
	$(info usage: make [target])
	$(info )
	$(info Available targets:)
	@awk -F ':.*?## *' '/^[^\t].+?:.*?##/ \
         {printf "  %-24s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
