clean:
	rm -rf _output
	rm -rf .up
	rm -rf ~/.up/cache

build:
	up project build

render: render-enterprise

render-all: render-individual render-individual-step-1 render-enterprise render-enterprise-step-1 render-enterprise-step-2

render-individual:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/individual.yaml

render-individual-step-1:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/individual.yaml --observed-resources=examples/observed-resources/individual/steps/1/

render-enterprise:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/enterprise.yaml

render-enterprise-step-1:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/enterprise.yaml --observed-resources=examples/observed-resources/enterprise/steps/1/

render-enterprise-step-2:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/enterprise.yaml --observed-resources=examples/observed-resources/enterprise/steps/2/

test:
	up test run tests/test*

validate: validate-composition-individual validate-composition-individual-step-1 validate-composition-enterprise-step-1 validate-composition-enterprise-step-2 validate-example

validate-composition-individual:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/individual.yaml --include-full-xr --quiet | crossplane beta validate apis/organizations --error-on-missing-schemas -

validate-composition-individual-step-1:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/individual.yaml --observed-resources=examples/observed-resources/individual/steps/1/ --include-full-xr --quiet | crossplane beta validate apis/organizations --error-on-missing-schemas -

validate-composition-enterprise-step-1:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/enterprise.yaml --observed-resources=examples/observed-resources/enterprise/steps/1/ --include-full-xr --quiet | crossplane beta validate apis/organizations --error-on-missing-schemas -

validate-composition-enterprise-step-2:
	up composition render --xrd=apis/organizations/definition.yaml apis/organizations/composition.yaml examples/organizations/enterprise.yaml --observed-resources=examples/observed-resources/enterprise/steps/2/ --include-full-xr --quiet | crossplane beta validate apis/organizations --error-on-missing-schemas -

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
