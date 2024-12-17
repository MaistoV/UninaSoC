# Author: Stefano Mercogliano 	<stefano.mercogliano@unina.it>
# Description:
#   This is a global makefile for the System-on-Chip software projects.
#	It can be used to compile all examples and create new projects based 
#	on our provided template.

# Environment check
ifndef ROOT_DIR
$(error Setup script settings.sh has not been sourced, aborting)
endif

EXAMPLES_NAMES	:= $(shell basename --multiple $(SW_ROOT)/SoC/examples/*)
EXAMPLES_LIST	:= $(foreach ip,${EXAMPLES_NAMES},$(SW_ROOT)/SoC/examples/${ip})

PROJECT_NAME ?= dummy

all: cbuild_examples

# Create a new project out of the template
create_project:
	@echo "Create a new project in $(SW_ROOT)/SoC/projects/$(PROJECT_NAME)"
	@cp -r $(SW_ROOT)/SoC/examples/template $(SW_ROOT)/SoC/projects/$(PROJECT_NAME)

# Create a new example out of the template
create_example:
	cp -r $(SW_ROOT)/SoC/examples/template $(SW_ROOT)/SoC/examples/$(PROJECT_NAME)

# Compile all examples in the example dir
build_examples: 
	@echo "[Make] Compile all the example project"
	@for example in ${EXAMPLES_LIST}; do \
		echo "[Make] Compiling project $$example" ; \
        ${MAKE} -C $$example ; \
		echo "\n[Make] Done\n" ; \
    done
#${MAKE} -C SoC/examples/virtual_uart_hello_world


.PHONY: create_project build_examples create_example
