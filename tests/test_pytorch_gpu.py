import torch

def test_has_gpu():
    """
    Test to check if a GPU is available for PyTorch.
    """
    # Check if any GPU is available
    gpu_available = torch.cuda.is_available()
    print(f"GPU available: {gpu_available}")
    
    # Assert that at least one GPU is detected
    assert gpu_available, "No GPU detected by PyTorch!"

    # Optional: print GPU details
    if gpu_available:
        num_gpus = torch.cuda.device_count()
        gpu_name = torch.cuda.get_device_name(0)
        print(f"Number of GPUs: {num_gpus}")
        print(f"GPU name: {gpu_name}")
