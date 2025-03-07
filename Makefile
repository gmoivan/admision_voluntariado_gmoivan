submissions: \
    pollos_petrel/example_python_submission.csv

pollos_petrel/gmo_python_submission.csv: setup_python src/gmo_submission.py
	@echo "Creating Python submission Guillermo."
	src/gmo_submission.py


module = pollos_petrel

define lint
	pylint \
        --disable=bad-continuation \
        --disable=missing-class-docstring \
        --disable=missing-function-docstring \
        --disable=missing-module-docstring \
        ${1}
endef

.PHONY: \
	check \
	clean \
	coverage \
	coverage_python \
	coverage_r \
	format \
	init \
	init_python \
	init_r \
	install_python \
	install_r \
	linter \
	mutants \
	mutants_python \
	mutants_r \
	setup \
	setup_python \
	setup_r \
	submissions \
	tests \
	tests_python \
	tests_r


check:
	R -e "library(styler)" \
      -e "resumen <- style_dir('R')" \
      -e "resumen <- rbind(resumen, style_dir('src'))" \
      -e "resumen <- rbind(resumen, style_dir('tests'))" \
      -e "any(resumen[[2]])" \
      | grep FALSE
	black --check --line-length 100 ${module}
	black --check --line-length 100 src
	black --check --line-length 100 tests
	flake8 --max-line-length 100 ${module}
	flake8 --max-line-length 100 src
	flake8 --max-line-length 100 tests
	mypy ${module}
	mypy src
	mypy tests

clean:
	rm --force --recursive ${module}.egg-info
	rm --force --recursive ${module}/__pycache__
	rm --force --recursive .*_cache
	rm --force --recursive SeleccionAnalista2022.Rcheck
	rm --force --recursive tests/__pycache__
	rm --force --recursive tests/testthat/_snaps
	rm --force .mutmut-cache
	rm --force NAMESPACE
	rm --force SeleccionAnalista2022_*.tar.gz
	rm --force coverage.xml
	rm --force pollos_petrel/example_*_submission.csv

coverage: coverage_python coverage_r

coverage_python: setup_python
	pytest --cov=${module} --cov-report=term-missing --verbose

coverage_r: setup_r
	Rscript tests/testthat/coverage.R

format:
	black --line-length 100 ${module}
	black --line-length 100 src
	black --line-length 100 tests
	R -e "library(styler)" \
      -e "style_dir('R')" \
      -e "style_dir('src')" \
      -e "style_dir('tests')"

init:
	@echo "⛔ Please use 'make init_python' or 'make init_r' instead ⛔"

init_python: setup_python tests_python

init_r: setup_r tests_r

install_python:
	pip install --editable .

install_r:
	R -e "devtools::document()" && \
    R CMD build . && \
    R CMD check SeleccionAnalista2022_0.1.0.tar.gz && \
    R CMD INSTALL SeleccionAnalista2022_0.1.0.tar.gz


linter:
	$(call lint, ${module})
	$(call lint, tests)

mutants: mutants_python mutants_r

mutants_python: setup_python tests_python
	mutmut run --paths-to-mutate ${module}
	mutmut run --paths-to-mutate src

mutants_r: setup_r tests_r
	@echo "🙁🏹 No mutation testing on R 👾🎉👾"

setup: setup_python setup_r

setup_python: clean install_python

setup_r: clean install_r

tests: tests_python tests_r

tests_python:
	pytest --verbose

tests_r:
	Rscript -e "devtools::test(stop_on_failure = TRUE)"
