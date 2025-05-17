# Makefile for Chef HBase cookbook
# Provides standard targets for development and testing

# Variables
KITCHEN_YAML ?= kitchen.yml
BUNDLE_EXEC = bundle exec
KITCHEN_LOG_LEVEL ?= info
DOC_DIR = doc
DOCKER_TAG ?= hbase-cookbook:dev

# Default target
.PHONY: all
all: lint test

# Help target
.PHONY: help
help:
	@echo "HBase Cookbook Development Targets:"
	@echo "  make help          - Show this help message"
	@echo "  make install       - Install dependencies"
	@echo "  make lint          - Run Cookstyle linting"
	@echo "  make test          - Run ChefSpec unit tests"
	@echo "  make kitchen       - Run Test Kitchen with default config (kitchen.yml)"
	@echo "  make kitchen-docker - Run Test Kitchen with Docker driver"
	@echo "  make kitchen-platform PLATFORM=ubuntu-2204 - Test specific platform"
	@echo "  make kitchen-suite SUITE=default - Test specific suite"
	@echo "  make converge      - Run kitchen converge (faster for development)"
	@echo "  make verify        - Run kitchen verify without converge"
	@echo "  make dev-env       - Setup local development environment"
	@echo "  make docs          - Generate documentation"
	@echo "  make docker        - Build Docker container with cookbook"
	@echo "  make bump-patch    - Bump patch version in metadata.rb"
	@echo "  make bump-minor    - Bump minor version in metadata.rb"
	@echo "  make bump-major    - Bump major version in metadata.rb"
	@echo "  make changelog     - Generate changelog from git commits"
	@echo "  make pre-commit    - Run pre-commit hooks"
	@echo "  make release       - Create a release (tag + push)"
	@echo ""
	@echo "Environment variables:"
	@echo "  KITCHEN_YAML       - Kitchen configuration file (default: kitchen.yml)"
	@echo "  KITCHEN_LOG_LEVEL  - Kitchen log level (default: info)"
	@echo "  DOCKER_TAG         - Docker tag for container builds (default: hbase-cookbook:dev)"

# Install dependencies
.PHONY: install
install:
	@echo "==> Installing gems..."
	@gem install bundler
	@$(BUNDLE_EXEC) bundle install

# Linting targets
.PHONY: lint
lint:
	@echo "==> Running Cookstyle..."
	@$(BUNDLE_EXEC) cookstyle --display-cop-names

.PHONY: lint-fix
lint-fix:
	@echo "==> Running Cookstyle with auto-correction..."
	@$(BUNDLE_EXEC) cookstyle --display-cop-names -a

# Test targets
.PHONY: test
test:
	@echo "==> Running ChefSpec tests..."
	@$(BUNDLE_EXEC) rspec spec/unit

# Test Kitchen targets
.PHONY: kitchen
kitchen:
	@echo "==> Running Test Kitchen with $(KITCHEN_YAML)..."
	@KITCHEN_YAML=$(KITCHEN_YAML) $(BUNDLE_EXEC) kitchen test

.PHONY: kitchen-docker
kitchen-docker:
	@echo "==> Running Test Kitchen with Docker..."
	@KITCHEN_YAML=kitchen.docker.yml $(BUNDLE_EXEC) kitchen test

.PHONY: kitchen-platform
kitchen-platform:
	@echo "==> Testing platform: $(PLATFORM)..."
	@KITCHEN_YAML=$(KITCHEN_YAML) $(BUNDLE_EXEC) kitchen test $(PLATFORM)

.PHONY: kitchen-suite
kitchen-suite:
	@echo "==> Testing suite: $(SUITE)..."
	@KITCHEN_YAML=$(KITCHEN_YAML) $(BUNDLE_EXEC) kitchen test $(SUITE)

.PHONY: converge
converge:
	@echo "==> Running kitchen converge..."
	@KITCHEN_YAML=$(KITCHEN_YAML) $(BUNDLE_EXEC) kitchen converge

.PHONY: verify
verify:
	@echo "==> Running kitchen verify..."
	@KITCHEN_YAML=$(KITCHEN_YAML) $(BUNDLE_EXEC) kitchen verify

# Development environment
.PHONY: dev-env
dev-env: install
	@echo "==> Setting up development environment..."
	@pre-commit install
	@echo "==> Development environment ready!"

# Documentation generation
.PHONY: docs
docs:
	@echo "==> Generating documentation..."
	@mkdir -p $(DOC_DIR)
	@$(BUNDLE_EXEC) yard doc --output-dir=$(DOC_DIR) --readme=README.md --title="HBase Cookbook Documentation"
	@echo "==> Documentation generated in $(DOC_DIR) directory"

# Docker targets
.PHONY: docker
docker:
	@echo "==> Building Docker image $(DOCKER_TAG)..."
	@docker build -t $(DOCKER_TAG) -f Dockerfile.kitchen .

# Version bumping
.PHONY: bump-patch
bump-patch:
	@echo "==> Bumping patch version..."
	@ruby -i -e 'content = File.read("metadata.rb"); if content =~ /(version\s+.+)(\d+\.\d+\.)(\d+)(.+)/ then puts content.gsub(/(version\s+.+)(\d+\.\d+\.)(\d+)(.+)/, "\\1\\2#{\\3.to_i + 1}\\4"); else puts content; end' metadata.rb
	@grep -m 1 "version" metadata.rb

.PHONY: bump-minor
bump-minor:
	@echo "==> Bumping minor version..."
	@ruby -i -e 'content = File.read("metadata.rb"); if content =~ /(version\s+.+)(\d+\.)(\d+)(\.\d+)(.+)/ then puts content.gsub(/(version\s+.+)(\d+\.)(\d+)(\.\d+)(.+)/, "\\1\\2#{\\3.to_i + 1}.0\\5"); else puts content; end' metadata.rb
	@grep -m 1 "version" metadata.rb

.PHONY: bump-major
bump-major:
	@echo "==> Bumping major version..."
	@ruby -i -e 'content = File.read("metadata.rb"); if content =~ /(version\s+.+)(\d+)(\.\d+\.\d+)(.+)/ then puts content.gsub(/(version\s+.+)(\d+)(\.\d+\.\d+)(.+)/, "\\1#{\\2.to_i + 1}.0.0\\4"); else puts content; end' metadata.rb
	@grep -m 1 "version" metadata.rb

# Changelog
.PHONY: changelog
changelog:
	@echo "==> Generating changelog..."
	@version=$$(grep -m 1 "version" metadata.rb | sed -E 's/.*version\s+["\x27]([0-9.]+)["\x27].*/\1/g'); \
	echo "## [$$version] - $$(date +%Y-%m-%d)" > .changelog_new.md; \
	echo "" >> .changelog_new.md; \
	git log --pretty=format:"- %s" $$(git describe --tags --abbrev=0 2>/dev/null || echo HEAD~10)..HEAD | grep -v "Merge" >> .changelog_new.md; \
	echo "" >> .changelog_new.md; \
	echo "" >> .changelog_new.md; \
	cat .changelog_new.md CHANGELOG.md > .changelog_merged.md; \
	mv .changelog_merged.md CHANGELOG.md; \
	rm .changelog_new.md; \
	echo "==> Updated CHANGELOG.md with new version $$version"

# Pre-commit hooks
.PHONY: pre-commit
pre-commit:
	@echo "==> Running pre-commit hooks..."
	@pre-commit run --all-files

# Release tasks
.PHONY: release
release: pre-commit
	@echo "==> Preparing release..."
	@version=$$(grep -m 1 "version" metadata.rb | sed -E 's/.*version\s+["\x27]([0-9.]+)["\x27].*/\1/g'); \
	echo "Creating release for version $$version"; \
	git tag -a "v$$version" -m "Release v$$version"; \
	git push origin "v$$version"; \
	echo "==> Release v$$version created and pushed!"

# CI pipeline
.PHONY: ci
ci: lint test kitchen-docker
	@echo "==> CI pipeline completed successfully!"

# Local testing with Chef
.PHONY: chef-local
chef-local:
	@echo "==> Running Chef Infra Client locally..."
	@$(BUNDLE_EXEC) chef-client -z -o "recipe[hbase::default]"

# Clean up
.PHONY: clean
clean:
	@echo "==> Cleaning up..."
	@rm -rf Berksfile.lock .kitchen/
	@rm -rf .bundle/ vendor/ doc/
	@KITCHEN_YAML=$(KITCHEN_YAML) $(BUNDLE_EXEC) kitchen destroy
	@echo "==> Cleanup complete!"