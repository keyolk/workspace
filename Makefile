IMAGE=keyolk/workspace
CONTAINER=workspace
USER=irteam
UID=500
GID=500
SHARED=/naver

build: ## build
	docker build -t $(IMAGE) --build-arg user=$(USER) --build-arg uid=$(UID) --build-arg gid=$(GID) .
build/nocache: ## build
	docker build -t $(IMAGE) --build-arg user=$(USER) --build-arg uid=$(UID) --build-arg gid=$(GID) --no-cache .

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
		-e GOROOT=/usr/lib/go \
		-e GOPATH=/naver/go \
		-v /etc/ssh/ssh_config:/etc/ssh/ssh_config \
		-v /etc/krb5.conf:/etc/krb5.conf \
		-v /etc/nsswitch.conf:/etc/nsswitch.conf \
		-v /usr/local/sbin:/usr/local/sbin \
		-v /opt/nbp:/opt/nbp \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/run/nscd:/var/run/nscd \
		-v /lib/modules:/lib/modules \
		-v /sys/fs/cgroup:/sys/fs/cgroup \
		-v $(SHARED):$(SHARED) \
		--name $(CONTAINER) \
		$(IMAGE)

attach: ## attach to work env
	-docker start $(CONTAINER)
	docker attach $(CONTAINER)

sync: ## sync repo
	git add -A && git commit -m "updated" && git push -u origin master

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9/_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
