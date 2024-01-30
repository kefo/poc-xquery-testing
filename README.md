
```bash

git clone https://github.com/kefo/poc-xquery-testing.git
cd poc-xquery-testing
# Deal with this oddity:
# https://github.com/kefo/poc-xquery-testing/blob/main/bin/basex#L3
# I.e. set your JAVA_HOME correctly.
# Then...
./bin/install.sh
./bin/run_tests.sh https://id.loc.gov

```
