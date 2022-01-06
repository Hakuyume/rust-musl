REPOSITORY := quay.io/hakuyume/rust-musl

BASE := debian:buster-20210721
OPENSSL := 1.1.1k
TOOLCHAIN := 1.57.0

.PHONY: build
build:
	docker build . \
	--build-arg BASE=$(BASE) \
	--build-arg OPENSSL=$(OPENSSL) \
	--build-arg TOOLCHAIN=$(TOOLCHAIN) \
	--tag $(REPOSITORY):$(TOOLCHAIN)

.PHONY: push
push: build
	docker push $(REPOSITORY):$(TOOLCHAIN)
