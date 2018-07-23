#!/bin/bash

# python lib path
# export PYTHONPATH=/home/Peterou/Desktop/usr/code/caffe2/pytorch/build/libinstall/usr/local:/home/Peterou/Desktop/usr/code/caffe2/pytorch/build/libinstall/usr/local/lib/python2.7/site-packages:/home/Peterou/Desktop/usr/code/caffe2/detectron
# export LD_LIBRARY_PATH=/home/Peterou/Desktop/usr/code/caffe2/pytorch/build/libinstall/usr/local/lib:/usr/local/cudnn_v6/lib64:/usr/local/cuda-8.0/lib64


# ./run.sh False Release

make_build_dir()
{
    buildPath=$1
    rebuild=$2

    if [ -d "$buildPath" ] && [ "$rebuild" = True ]
    then
	rm -rf "$buildPath"
    fi

    if [ ! -d "$buildPath" ]
    then
	mkdir -p "$buildPath"
    fi
    
}

buildPath=build
rebuild=$1
buildType=$2
make_build_dir "$buildPath" "$rebuild"
cd "$buildPath"

source ~/anaconda3/bin/activate caffe2
export PATH=/usr/local/cuda-8.0/bin:$PATH
export CUDA_VISIBLE_DEVICES=1
export LD_LIBRARY_PATH=/usr/local/cudnn_v6/lib64:/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH

if [ $3 = cmake ]
then
cmake -DCUDA_TOOLKIT_ROOT_DIR="/usr/local/cuda-8.0" \
      -DCMAKE_PREFIX_PATH="/usr/local/cudnn_v6" \
      -DPYTHON_LIBRARY=$(python2 -c "from distutils import sysconfig; print(sysconfig.get_python_lib())") \
      -DPYTHON_INCLUDE_DIR=$(python2 -c "from distutils import sysconfig; print(sysconfig.get_python_inc())") \
      -DUSE_NATIVE_ARCH=ON \
      -DCMAKE_BUILD_TYPE="$buildType" ..
fi

libinstall="libinstall"
mkdir libinstall
make -j8
make DESTDIR="$libinstall" install


python2 -c 'from caffe2.python import workspace; print(workspace.NumCudaDevices())'
