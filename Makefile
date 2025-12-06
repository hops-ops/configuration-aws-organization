clean:
	rm -rf _output
	rm -rf .up
	rm -rf ~/.up/cache

build:
	up project build

render: render-example-minimal

render-all: render-example-minimal render-example-standard render-example-delegated-admin

render-example-minimal:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/example-minimal.yaml

render-example-standard:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/example-standard.yaml

render-example-delegated-admin:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/example-delegated-admin.yaml

test:
	up test run tests/test*

validate: validate-composition validate-example

validate-composition:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/example-minimal.yaml --include-full-xr --quiet | crossplane beta validate apis/organizations --error-on-missing-schemas -

validate-example:
	crossplane beta validate apis/organizations examples/organizations

publish:
	@if [ -z "$(tag)" ]; then echo "Error: tag is not set. Usage: make publish tag=<version>"; exit 1; fi
	up project build --push --tag $(tag)

generate-definitions:
	up xrd generate examples/organizations/example-minimal.yaml

generate-function:
	up function generate --language=go-templating render apis/organizations/composition.yaml

e2e:
	up test run tests/e2etest* --e2e
