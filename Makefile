IMAGE=keyolk
CONTAINER=keyolk-work
USER=irteam
UID=500
GID=500

build: ## build
	docker build -t $(IMAGE) --build-arg user=$(USER) --build-arg uid=$(UID) --build-arg gid=$(GID) .
build/nocache: ## build
	docker build -t $(IMAGE) --build-arg user=$(USER) --build-arg uid=$(UID) --build-arg gid=$(GID) --no-cache .

clean: ## clean work env
	docker rm -f $(CONTAINER)

run:
	docker run -tid \
		--privileged \
		--pid=host \
		--net=host \
		-e REMOTE_USER=$(USER) \
		-v /etc/ssh/ssh_config:/etc/ssh/ssh_config \
		-v /etc/krb5.conf:/etc/krb5.conf \
		-v /etc/nsswitch.conf:/etc/nsswitch.conf \
		-v /usr/local/sbin/cilookup:/usr/local/sbin/cilookup \
		-v /usr/local/sbin/iplookup:/usr/local/sbin/iplookup \
		-v /naver:/naver \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/run/nscd:/var/run/nscd \
		--name $(CONTAINER) \
		$(IMAGE)

attach: ## attach to work env
	docker attach $(CONTAINER)

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9/_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
