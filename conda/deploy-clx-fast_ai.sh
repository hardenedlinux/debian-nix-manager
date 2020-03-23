conda-install
conda create -n clx-fast.ai python=3.6 ipykernel
source activate clx-fast.ai
git clone https://github.com/rapidsai/cuxfilter.git --depth=1q
cd cuxfilter/conda/environments
conda env update -n clx-fast.ai --filecux filter_dev_cuda10.0.yml


python -m ipykernel install --user --name clx-fast.ai --display-name "Python (clx-fast.ai)"
