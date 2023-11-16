#!/bin/bash

wr_latency=10
#trace_dir="../sim.bak/cutlass_full/cutlass/11.0/cutlass_perf_test/"
trace_dir="../sim.bak/traces/"

#trace_list=(__seed_2020___dist_0____m_2560___n_16___k_2560___kernels_wmma_gemm_nn____iterations_5___providers_cutlass)
#trace_list+=(__seed_2020___dist_0____m_2560___n_32___k_2560___kernels_wmma_gemm_nn____iterations_5___providers_cutlass)
#trace_list+=(__seed_2020___dist_0____m_2560___n_64___k_2560___kernels_wmma_gemm_nn____iterations_5___providers_cutlass)
#trace_list+=(__seed_2020___dist_0____m_2560___n_128___k_2560___kernels_wmma_gemm_nn____iterations_5___providers_cutlass)
#trace_list+=(__seed_2020___dist_0____m_4096___n_16___k_4096___kernels_wmma_gemm_nn____iterations_5___providers_cutlass)
#trace_list+=(__seed_2020___dist_0____m_4096___n_32___k_4096___kernels_wmma_gemm_nn____iterations_5___providers_cutlass)
#trace_list+=(__seed_2020___dist_0____m_4096___n_64___k_4096___kernels_wmma_gemm_nn____iterations_5___providers_cutlass)
#trace_list+=(__seed_2020___dist_0____m_4096___n_128___k_4096___kernels_wmma_gemm_nn____iterations_5___providers_cutlass)

#trace_list=(traces/vecadd5/ traces/vecadd/)
#trace_list=(vecadd5)
#trace_list=(00_basic_2048_32_20480)
#trace_list=(00_basic_1024_128_5120)
trace_list=(00_basic_1024_64_2048)
#trace_list+=(00_basic_1024_128_5120)
#trace_list+=(00_basic_1024_64_2048)
#trace_list+=(00_basic_1024_32_2048)
#trace_list+=(00_basic_1024_32_1024)
#trace_list+=(00_basic_2048_32_4096)

config1=./gpu-simulator/gpgpu-sim/configs/tested-cfgs/SM7_QV100/gpgpusim.config
config2=./gpu-simulator/configs/tested-cfgs/SM7_QV100/trace.config

#for l in ${trace_list[@]}; do
#  echo $trace_dir"/"$l"/traces/kernelslist.g"
#done
#exit
##################################
###### 128B baseline
##################################
sed -i "57s/.*/CXXFLAGS += -DCOMP_LATENCY=0/g" ./gpu-simulator/gpgpu-sim/src/gpgpu-sim/Makefile
make clean -j -C ./gpu-simulator/
make -j -C ./gpu-simulator/
for l in ${trace_list[@]}; do
  trace_name=$trace_dir$l
  ./gpu-simulator/bin/release/accel-sim.out -trace ${trace_name}/kernelslist.g -config $config1 -config $config2 | tee ${l}"_128B.log"
done

##################################
###### 128B + WR Latency
##################################
sed -i "57s/.*/CXXFLAGS += -DCOMP_LATENCY=$wr_latency/g" ./gpu-simulator/gpgpu-sim/src/gpgpu-sim/Makefile
make clean -j -C ./gpu-simulator/
make -j -C ./gpu-simulator/
for l in ${trace_list[@]}; do
  trace_name=$trace_dir$l
  ./gpu-simulator/bin/release/accel-sim.out -trace ${trace_name}/kernelslist.g -config $config1 -config $config2 | tee ${l}"_128B_lat"$wr_latency".log"
done

##################################
###### 64B
##################################
sed -i "57s/.*/CXXFLAGS += -DCOMP_LATENCY=0 -DWR_TRAFFIC_HALF_EN=1/g" ./gpu-simulator/gpgpu-sim/src/gpgpu-sim/Makefile
make clean -j -C ./gpu-simulator/
make -j -C ./gpu-simulator/
for l in ${trace_list[@]}; do
  trace_name=$trace_dir$l
  ./gpu-simulator/bin/release/accel-sim.out -trace ${trace_name}/kernelslist.g -config $config1 -config $config2 | tee ${l}"_64B.log"
done

##################################
###### 64B + WR LATENCY
##################################
sed -i "57s/.*/CXXFLAGS += -DCOMP_LATENCY=$wr_latency -DWR_TRAFFIC_HALF_EN=1/g" ./gpu-simulator/gpgpu-sim/src/gpgpu-sim/Makefile
make clean -j -C ./gpu-simulator/
make -j -C ./gpu-simulator/
for l in ${trace_list[@]}; do
  trace_name=$trace_dir$l
  ./gpu-simulator/bin/release/accel-sim.out -trace ${trace_name}/kernelslist.g -config $config1 -config $config2 | tee ${l}"_64B_lat"$wr_latency".log"
done
