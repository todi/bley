sdist:
	python setup.py sdist

test: 	test-sqlite	# test-psql test-mysql test-sqlite
	pep8 --ignore=E501,E221,E226,E225 ./bley .
	make test-clean

test-sqlite: test-setup-sqlite
	trial test
	[ ! -f ./test/bley_test.pid ] || kill $$(cat ./test/bley_test.pid)
	./bleygraph -c ./test/bley_sqlite.conf -d ./test/bleygraphout
	make test-clean

test-setup-sqlite: test-clean
	sed "s#.*DBPORT##;s#DBTYPE#sqlite3#;s#DBNAME#./test/bley_sqlite.db#" ./test/bley_test.conf.in > ./test/bley_sqlite.conf
	./bley -c ./test/bley_sqlite.conf -p ./test/bley_test.pid

test-psql:
	pg_virtualenv make test-psql-real

test-psql-real: test-setup-psql
	trial test
	[ ! -f ./test/bley_test.pid ] || kill $$(cat ./test/bley_test.pid)
	./bleygraph -c ./test/bley_psql.conf -d ./test/bleygraphout
	make test-clean

test-setup-psql: test-clean
	sed "s#DBHOST#$$PGHOST#;s#DBPORT#$$PGPORT#;s#DBUSER#$$PGUSER#;s#DBPASS#$$PGPASSWORD#;s#DBTYPE#pgsql#;s#DBNAME#bley_test#" ./test/bley_test.conf.in > ./test/bley_psql.conf
	createdb bley_test
	./bley -c ./test/bley_psql.conf -p ./test/bley_test.pid

test-mysql:
	my_virtualenv make test-mysql-real

test-mysql-real: test-setup-mysql
	trial test
	[ ! -f ./test/bley_test.pid ] || kill $$(cat ./test/bley_test.pid)
	./bleygraph -c ./test/bley_mysql.conf -d ./test/bleygraphout
	make test-clean

test-setup-mysql: test-clean
	sed "s#DBHOST#$$MYSQL_HOST#;s#DBPORT#$$MYSQL_TCP_PORT#;s#DBUSER#$$MYSQL_USER#;s#DBPASS#$$MYSQL_PWD#;s#DBTYPE#mysql#;s#DBNAME#bley_test#" ./test/bley_test.conf.in > ./test/bley_mysql.conf
	echo "CREATE DATABASE bley_test;" | mysql
	./bley -c ./test/bley_mysql.conf -p ./test/bley_test.pid

test-clean:
	[ ! -f ./test/bley_test.pid ] || kill $$(cat ./test/bley_test.pid)
	rm -f ./test/bley_sqlite.db ./test/bley_sqlite.conf ./test/bley_psql.conf ./test/bley_mysql.conf
	rm -rf ./test/bleygraphout/

.PHONY: sdist test

install:
	python setup.py install --force --root=$(DESTDIR) --no-compile -O0 --install-layout=deb
