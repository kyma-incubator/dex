APP_NAME = dex
APP_PATH = /
BUILDPACK = eu.gcr.io/kyma-project/test-infra/buildpack-golang-toolbox:v20190913-65b55d1

IMG_NAME := $(DOCKER_PUSH_REPOSITORY)$(DOCKER_PUSH_DIRECTORY)/$(APP_NAME)
TAG := $(DOCKER_TAG)

VERIFY_IGNORE := /vendor\|/automock
DIRS_TO_CHECK = go list ./... | grep -v "$(VERIFY_IGNORE)"
FILES_TO_CHECK = find . -type f -name "*.go" | grep -v "$(VERIFY_IGNORE)"

release: test vet check-fmt build-image push-image

test:
	go test -v ./...

vet:
	go vet $$($(DIRS_TO_CHECK))

check-fmt:
	exit $(shell gofmt -l $$($(FILES_TO_CHECK)) | wc -l | xargs)

build-image: pull-licenses
	docker build -t $(IMG_NAME) .

push-image:
	docker tag $(IMG_NAME) $(IMG_NAME):$(TAG)
	docker push $(IMG_NAME):$(TAG)

pull-licenses:
ifdef LICENSE_PULLER_PATH
	bash $(LICENSE_PULLER_PATH)
else
	mkdir -p licenses
endif