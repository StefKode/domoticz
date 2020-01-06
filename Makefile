include vars.env

# build
BLDDIR= build
DFILE = $(BLDDIR)/Dockerfile
DTPL  = templates/Dockerfile.tmpl

# compose
CFILE = docker-compose.yml
CTPL  = templates/docker-compose.yml.tmpl 

# entry
ETPL  = templates/docker-entrypoint.sh.tmpl
ENTRY = contents/docker-entrypoint.sh

all:	build run

build:	files
	sudo docker build -t $(IMAGE_NAME):$(VERSION) -f build/Dockerfile contents

files:	$(DFILE) $(CFILE) $(ENTRY)

$(DFILE): $(DTPL) vars.env
	mkdir -p $(BLDDIR)
	tool/create_dfile $(DTPL) $(BLDDIR) $(ARCH) $(IPORT) $(CONF_ON_CONT) $(PROXY)

$(CFILE): $(CTPL) vars.env
	tool/create_cfile $(CTPL) $(IMAGE_NAME) $(VERSION) $(CFILE) $(CONF_ON_HOST) $(CONF_ON_CONT) $(CONTAINER_NAME) $(EPORT) $(IPORT)

$(ENTRY): $(ETPL)
	mkdir -p contents
	tool/create_efile $(ETPL) $(ENTRY) $(CONF_ON_CONT) $(IPORT)

run:	files
	sudo docker-compose up -d

list:
	sudo docker container list -a
	sudo docker image list

attach:
	sudo tool/attach $(CONTAINER_NAME) 

clean:
	rm -f $(CFILE) $(DFILE) $(SMBCF) $(ENTRY)
	rmdir $(BLDDIR)
