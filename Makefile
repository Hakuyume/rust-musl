REPOSITORY := quay.io/hakuyume/rust-musl

BASE := debian:bullseye-20220125
OPENSSL := 1.1.1m
SCCACHE := 610ddef
TOOLCHAIN := 1.62.0

.PHONY: build
build:
	docker build . \
	--build-arg BASE=$(BASE) \
	--build-arg OPENSSL=$(OPENSSL) \
	--build-arg SCCACHE=$(SCCACHE) \
	--build-arg TOOLCHAIN=$(TOOLCHAIN) \
	--tag $(REPOSITORY):$(TOOLCHAIN)

.PHONY: push
push: build
	docker push $(REPOSITORY):$(TOOLCHAIN)
