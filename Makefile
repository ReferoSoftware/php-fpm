ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

build: guard-image
	docker build -t $(image) .

build-nocache: guard-image
	docker build --no-cache -t $(image) .

push: guard-image
	docker push $(image)

# If an image is not supplied to some scripts we wanna stop right there
# This is a bit weird but does the trick
# I'll find a better solution at some point
guard-image:
	@echo "Using image: $${image:?}"
