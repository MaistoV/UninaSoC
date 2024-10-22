# Environment check
ifndef ROOT_DIR
$(error Setup script settings.sh has not been sourced, aborting)
endif

SHELL := /bin/bash

IP_RTL_LIST	= $(shell basename --multiple ${HW_UNITS_ROOT}/custom_*)

all: units

units: $(addsuffix /rtl, ${IP_RTL_LIST})

# Fetch sources for all IPs without local rtl
custom_%/rtl:
	cd ${HW_UNITS_ROOT}/custom_$*; source fetch_sources.sh

# Remove all RTL dirs (TBD)
clean:


.PHONY: clean