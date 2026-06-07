analyze:
	flutter analyze

test:
	flutter test --coverage

coverage:
	genhtml coverage/lcov.info -o coverage/html

clean:
	flutter clean
	flutter pub get
