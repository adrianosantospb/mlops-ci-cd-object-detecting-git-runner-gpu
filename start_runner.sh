#!/bin/bash
set -e

echo "--- Starting GitHub Actions Runner initialization script ---"

if [ "$(id -u)" = "0" ]; then
    echo "Running as root. Installing dependencies and creating 'runner' user..."

    # Install essential dependencies
    apt-get update
    apt-get install -y --no-install-recommends \
        curl \
        git \
        jq \
        libicu-dev \
        sudo
    rm -rf /var/lib/apt/lists/*

    # Create runner user if it does not exist
    if ! id -u runner >/dev/null 2>&1; then
        useradd -m runner
    fi

    # Ensure /runner is owned by the runner user
    chown -R runner:runner /runner

    # Re-run this script as runner user
    exec su runner -c "/bin/bash /start_runner.sh"
fi

# --------------------------
# From this point: run as runner user
# --------------------------

echo "Running as user runner ($(whoami))"

# --- DEBUG: list contents of the directory ---
echo "--- Contents of /runner ---"
ls -la /runner
echo "------------------------------------------"

# 1. Remove old runner configuration (if it exists)
if [ -f "/runner/config.sh" ]; then
    echo "Removing old runner configuration (if it exists)..."
    pushd "/runner" > /dev/null
    ./config.sh remove --token "$RUNNER_TOKEN" --unattended || true
    popd > /dev/null
    echo "Old configuration removed (if applicable)."
fi

# 2. Configure the runner
echo "Configuring the GitHub Actions Runner..."
pushd "/runner" > /dev/null
./config.sh \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --labels "$RUNNER_LABELS" \
  --work "$RUNNER_WORKDIR" \
  --unattended \
  --replace
popd > /dev/null
echo "Runner successfully configured."

# 3. Start the runner
echo "Starting the GitHub Actions Runner..."
pushd "/runner" > /dev/null
exec ./run.sh
popd > /dev/null

echo "Error: runner did not start."
