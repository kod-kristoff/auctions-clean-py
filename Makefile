.PHONY: venv help test run-all-tests run-all-tests-w-coverage check-pylint check-mypy

.default: help

help:
	@echo "usage:"

PLATFORM := ${shell uname -o}
INVENV_PATH = ${shell which invenv}

ifeq (${VIRTUAL_ENV},)
  VENV_NAME = .venv
else
  VENV_NAME = ${VIRTUAL_ENV}
endif

${info Platform: ${PLATFORM}}
${info Using ${VENV_NAME}}
${info invenv: ${INVENV_PATH}}

VENV_BIN = ${VENV_NAME}/bin

ifeq (${INVENV_PATH},)
  INVENV = export VIRTUAL_ENV="${VENV_NAME}"; export PATH="${VENV_BIN}:${PATH}"; unset PYTHON_HOME;
else
  INVENV = invenv -C ${VENV_NAME}
endif

ifeq (${PLATFORM}, Android)
  FLAKE8_FLAGS = --jobs=1
else
  FLAKE8_FLAGS = --jobs=auto
endif

PYTHON = ${VENV_BIN}/python

# order of libs is meaningful. First, we install libs without internal dependencies that other libs depend on.
libs := foundation auctions  # shipping db_infrastructure web_app_models auctions_infrastructure shipping_infrastructure customer_relationship payments processes main web_app

define install_dev
	${INVENV} pip install -e auctions_platform/$(1)

endef

.PHONY: dev
dev: venv
	${INVENV} pip install  -r auctions_platform/requirements.txt -r auctions_platform/requirements-dev.txt
	$(foreach lib,$(libs),$(call install_dev,$(lib)))


venv: ${VENV_NAME}/venv.created

${VENV_NAME}/venv.created:
	test -d ${VENV_NAME} || python -m venv ${VENV_NAME}
	@touch $@

${VENV_NAME}/dev.installed: setup.py setup.cfg requirements.txt
	${INVENV} python -m pip install -Ue .[dev]
	@touch $@

install-dev: venv upgrade-pip ${VENV_NAME}/dev.installed
install-orjson: venv
	${INVENV} pip install -U orjson

install-ujson: venv
	${INVENV} pip install -U ujson

upgrade-pip: venv
	${INVENV} pip install --upgrade pip

test: run-all-tests
run-all-tests:
	${INVENV} pytest -vv auctions_platform

run-all-tests-w-coverage: install-dev
	${INVENV} pytest -vv --cov=json_streams  --cov-report=term-missing tests

check-mypy: install-dev
	${INVENV} mypy json_streams tests

check-pylint: install-dev
	${INVENV}  pylint --rcfile=.pylintrc json_streams tests

check-pylint-refactorings: install-dev
	${INVENV} pylint --disable=C,W,E --enable=R json_streams tests

bumpversion-major: install-dev
	${INVENV} bump2version major

bumpversion-minor: install-dev
	${INVENV} bump2version minor

bumpversion: install-dev
	${INVENV} bump2version patch
