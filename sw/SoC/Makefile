# Author: Stefano Mercogliano 	<stefano.mercogliano@unina.it>
# Description:
#   This is a global makefile for the System-on-Chip software projects.
#	It can be used to compile all defaul examples

# Environment check
ifndef ROOT_DIR
$(error Setup script settings.sh has not been sourced, aborting)
endif

EXAMPLES_NAMES	:= $(shell basename --multiple $(SW_ROOT)/SoC/examples/*)
EXAMPLES_LIST	:= $(foreach ip,${EXAMPLES_NAMES},$(SW_ROOT)/SoC/examples/${ip})

PROJECT_NAME ?= dummy

all: build_examples

# Compile all examples in the example dir
build_examples: 
	@echo "[Make] Compile all the example project"
	@for example in ${EXAMPLES_LIST}; do \
		echo "[Make] Compiling project $$example" ; \
        ${MAKE} -C $$example ; \
		echo "\n[Make] Done\n" ; \
    done

.PHONY: build_examples
