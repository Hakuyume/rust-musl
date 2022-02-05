REPOSITORY := quay.io/hakuyume/rust-musl

BASE := debian:buster-20210721
OPENSSL := 1.1.1k
SCCACHE := 8178903
TOOLCHAIN := 1.58.1

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
