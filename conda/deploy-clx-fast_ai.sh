conda-install
conda create -n clx-fast.ai python=3.6 ipykernel
conda activate clx-fast.ai
pip install seaborn s3fs

##cuxfilter
git clone https://github.com/rapidsai/cuxfilter.git --depth=1
conda env update -n clx-fast.ai --file cuxfilter/conda/environments/cuxfilter_dev_cuda10.0.yml
pip install -e cuxfilter/python

##cudf
git clone https://github.com/rapidsai/cudf.git --depth=1
conda env update -n clx-fast.ai --file  cudf/conda/environments/cudf_dev_cuda10.0.yml
pip install -e cudf/python/cudf
pip install -e cudf/python/dask_cudf

## clx
git clone https://github.com/rapidsai/clx.git --depth=1
pip install -e clx/.

#install kernal
python -m ipykernel install --user --name clx-fast.ai --display-name "Python (clx-fast.ai)"
