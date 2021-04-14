REPOSITORY := quay.io/hakuyume/rust-musl
OPENSSL := 1.1.1k
TOOLCHAIN := 1.51.0

.PHONY: build
build:
	docker build . --build-arg OPENSSL=$(OPENSSL) --build-arg TOOLCHAIN=$(TOOLCHAIN) --tag $(REPOSITORY):$(TOOLCHAIN)

.PHONY: push
push: build
	docker push $(REPOSITORY):$(TOOLCHAIN)
