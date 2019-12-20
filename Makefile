CONFIG=https://github.com/keyolk/config
SECRET=https://github.com/keyolk/secret
IMAGE=keyolk/workspace

CONTAINER=workspace
USER=keyolk
UID=500
GID=500

build: ## build
	docker build -t $(IMAGE) --build-arg user=$(USER) --build-arg uid=$(UID) --build-arg gid=$(GID) -f arch/Dockerfile .
build/nocache: ## build
	docker build -t $(IMAGE) --build-arg user=$(USER) --build-arg uid=$(UID) --build-arg gid=$(GID) -f arch/Dockerfile --no-cache .

push:
	docker push $(IMAGE)

clean: ## clean work env
	docker rm -f $(CONTAINER)

run: ## run container
	docker run -tid \
		--privileged \
		--pid=host \
		--net=host \
		-e REMOTE_USER=$(USER) \
		-v /etc/ssh/ssh_config:/etc/ssh/ssh_config \
		-v /etc/nsswitch.conf:/etc/nsswitch.conf \
		-v /lib/modules:/lib/modules \
		-v /sys/fs/cgroup:/sys/fs/cgroup \
		--name $(CONTAINER) \
		$(IMAGE)

attach: ## attach to work env
	-docker start $(CONTAINER)
	docker attach $(CONTAINER)

sync: ## sync repo
	git add -A && git commit -m "updated" && git push -u origin master

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9/_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
