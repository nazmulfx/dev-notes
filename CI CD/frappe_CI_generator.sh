#!/bin/bash

echo "================================="
echo "      ERPNext CI Generator"
echo "================================="

read -p "App Name: " APP_NAME
read -p "Frappe Branch (version-14/version-15/version-16)[version-16]: " FRAPPE_VERSION
FRAPPE_VERSION=${FRAPPE_VERSION:-version-16}
read -p "ERPNext Branch (version-14/version-15/version-16)[version-16]: " ERPNEXT_VERSION
ERPNEXT_VERSION=${ERPNEXT_VERSION:-version-16}
read -p "CI Branches (comma separated): " BRANCHES

case "$FRAPPE_VERSION" in
    version-16)
        PYTHON_VERSION="3.14"
        NODE_VERSION="24"
        ;;
    version-15)
        PYTHON_VERSION="3.12"
        NODE_VERSION="22"
        ;;
    version-14)
        PYTHON_VERSION="3.10"
        NODE_VERSION="20"
        ;;
    *)
        echo "Unsupported Frappe version"
        exit 1
        ;;
esac

BRANCH_YAML=""
IFS=',' read -ra BRANCH_LIST <<< "$BRANCHES"

for branch in "${BRANCH_LIST[@]}"
do
    branch=$(echo "$branch" | xargs)
    BRANCH_YAML="${BRANCH_YAML}      - ${branch}"$'\n'
done

mkdir -p .github/workflows

cat > .github/workflows/ci.yml <<EOF
name: CI

on:
  push:
    branches:
$(echo "$BRANCH_YAML")
  pull_request:

concurrency:
  group: main-${APP_NAME}-\${{ github.event.number }}
  cancel-in-progress: true

jobs:
  tests:
    runs-on: ubuntu-latest

    strategy:
      fail-fast: false

    name: Server

    services:
      redis-cache:
        image: redis:alpine
        ports:
          - 13000:6379

      redis-queue:
        image: redis:alpine
        ports:
          - 11000:6379

      mariadb:
        image: mariadb:10.6
        env:
          MYSQL_ROOT_PASSWORD: root
        ports:
          - 3306:3306
        options: --health-cmd="mariadb-admin ping" --health-interval=5s --health-timeout=2s --health-retries=3

    steps:
      - name: Clone
        uses: actions/checkout@v3

      - name: Find tests
        run: |
          echo "Finding tests"
          grep -rn "def test" > /dev/null

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '${PYTHON_VERSION}'

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: ${NODE_VERSION}
          check-latest: true

      - name: Cache pip
        uses: actions/cache@v4
        with:
          path: ~/.cache/pip
          key: \${{ runner.os }}-pip-\${{ hashFiles('**/*requirements.txt', '**/pyproject.toml', '**/setup.py', '**/setup.cfg') }}
          restore-keys: |
            \${{ runner.os }}-pip-
            \${{ runner.os }}-

      - name: Get yarn cache directory path
        id: yarn-cache-dir-path
        run: 'echo "dir=\$(yarn cache dir)" >> \$GITHUB_OUTPUT'

      - uses: actions/cache@v4
        id: yarn-cache
        with:
          path: \${{ steps.yarn-cache-dir-path.outputs.dir }}
          key: \${{ runner.os }}-yarn-\${{ hashFiles('**/yarn.lock') }}
          restore-keys: |
            \${{ runner.os }}-yarn-

      - name: Install MariaDB Client
        run: |
          sudo apt update
          sudo apt-get install -y mariadb-client

      - name: Setup
        run: |
          pip install frappe-bench
          bench init --skip-redis-config-generation --skip-assets --python "\$(which python)" ~/frappe-bench --frappe-branch ${FRAPPE_VERSION}
          mariadb --host 127.0.0.1 --port 3306 -u root -proot -e "SET GLOBAL character_set_server = 'utf8mb4'"
          mariadb --host 127.0.0.1 --port 3306 -u root -proot -e "SET GLOBAL collation_server = 'utf8mb4_unicode_ci'"

      - name: Install
        working-directory: /home/runner/frappe-bench
        run: |
          bench get-app erpnext --branch ${ERPNEXT_VERSION}
          bench get-app ${APP_NAME} \$GITHUB_WORKSPACE
          bench setup requirements --dev
          bench new-site --db-root-password root --admin-password admin test_site
          bench --site test_site install-app erpnext
          bench --site test_site install-app ${APP_NAME}
          bench build
        env:
          CI: 'Yes'

      - name: Run Tests
        working-directory: /home/runner/frappe-bench
        run: |
          bench --site test_site set-config allow_tests true
          bench --site test_site run-tests --app ${APP_NAME}
        env:
          TYPE: server
EOF

echo ""
echo "Generated: .github/workflows/ci.yml"
echo "Python : ${PYTHON_VERSION}"
echo "Node   : ${NODE_VERSION}"
echo "Done."
