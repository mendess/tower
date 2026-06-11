.DEFAULT_GOAL = install

include .env
include ../foundations.mk

.PHONY: install alto-marr

install: alto-marr dirs

alto-marr:
	cd ../alto-marr && $(MAKE)
