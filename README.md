# MLOps CI/CD with Self-Hosted GitHub Runner (GPU-enabled)
### Adriano A. Santos

This project sets up a **self-hosted GitHub Actions runner with GPU support** using Docker and NVIDIA CUDA.  
It is designed for **CI/CD workflows** in machine learning projects that require GPU acceleration, such as **PyTorch-based deep learning models**.

---

## 📂 Project Structure

```
├── .env                       # Environment variables for the GitHub runner
├── .github
│   └── workflows
│       └── ci.yml             # GitHub Actions workflow for CI/CD
├── data
│   └── runner                 # Persistent runner data/configuration
├── LICENSE
├── pytest.ini                 # Pytest configuration
├── README.md
├── requirements.txt           # Python dependencies
├── src                        # Source code
├── start_runner.sh            # Runner initialization script
├── docker-compose.yml         # Docker runner setup
└── tests
    └── test_pytorch_gpu.py    # GPU availability test with PyTorch
```
---

## ⚙️ Configuration

### Environment Variables (`.env`)

Fill in the required values in your `.env` file:

```ini
# GitHub Runner
REPO_URL=https://github.com/<your-user>/<your-repo>
RUNNER_TOKEN=<your-registration-token>
RUNNER_NAME=pytorch-runner
RUNNER_LABELS=gpu,pytorch
RUNNER_WORKDIR=/runner/_work
```

- `REPO_URL` → Your GitHub repository URL  
- `RUNNER_TOKEN` → Registration token from GitHub (repository settings → Actions → Runners → New self-hosted runner)  
- `RUNNER_NAME` → Custom runner name  
- `RUNNER_LABELS` → Labels used to match workflow jobs (`gpu`, `pytorch`)  
- `RUNNER_WORKDIR` → Work directory inside the container  

---

## 🐳 Running the Self-Hosted Runner

This project uses **Docker Compose** with GPU support.

### Prerequisites
- Docker with NVIDIA GPU support (`nvidia-docker2` or newer runtime)
- NVIDIA drivers installed
- Access to create an external Docker network (`adrianosantosnet` in this case)

### Start the runner

```bash
docker-compose up -d
```

### Stop the runner

```bash
docker-compose down
```

The runner will automatically reconnect to GitHub on restart.

---

## 🚀 CI/CD Workflow

The workflow file [`ci.yml`](.github/workflows/ci.yml) defines the CI/CD pipeline:

### Triggered on
- Push to the `main` branch
- Pull requests targeting `main`

### Steps
1. **Checkout repository**  
2. **Fix PATH** for Conda and local binaries  
3. **Verify Python version**  
4. **Install dependencies** (from `requirements.txt` + `pytest`)  
5. **Run tests** with `pytest`  
6. **Verify GPU availability** with `nvidia-smi` and `torch.cuda.is_available()`  

---

## ✅ Testing GPU with PyTorch

A simple GPU test is provided in `tests/test_pytorch_gpu.py`:

```python
import torch

def test_gpu_available():
    """Check if a CUDA-enabled GPU is available for PyTorch."""
    assert torch.cuda.is_available(), "CUDA GPU is not available"
```

This ensures that the runner correctly detects the GPU during CI/CD runs.

---

## 🔒 Branch Protection

It is recommended to **protect the `main` branch** in GitHub:
- Require pull requests before merging  
- Require status checks to pass (tests, GPU availability)  
- Restrict who can push directly to `main`  

This enforces contributions through **Merge Requests (PRs)** with automated testing.

---

## 🔑 How to Generate the Runner Token

1. Go to your GitHub repository.  
2. Navigate to **Settings → Actions → Runners**.  
3. Click **New self-hosted runner**.  
4. Select **Linux → x64 → self-hosted**.  
5. Copy the **Registration Token** provided by GitHub.  
6. Paste the token into your `.env` file under `RUNNER_TOKEN`.  

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).

---

## 🙌 Acknowledgments

- [GitHub Actions self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [NVIDIA CUDA Docker images](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/pytorch)