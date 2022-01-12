//===- xten_to_linalg_conv2d_lrelu_pad_maxpool.mlir -------------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2021 Xilinx Inc.
//
//===----------------------------------------------------------------------===//

// RUN: aten-opt %s -xten-to-linalg | FileCheck %s
//CHECK:linalg.conv_2d_lrelu_maxpool {dilation = dense<1> : tensor<2xi64>, layer_name = "conv2d_lrelu_pad_maxpool0", mp_dilation = dense<1> : tensor<2xi64>, mp_kernel_size = dense<2> : tensor<2xi64>, mp_padding = dense<[0, 1, 0, 1]> : tensor<4xi64>, mp_stride = dense<2> : tensor<2xi64>, stride = dense<1> : tensor<2xi64>} ins({{.*}}, {{.*}}, {{.*}}, {{.*}} : tensor<1x3x130x130xf32>, tensor<16x3x3x3xf32>, tensor<16xf32>, f32) outs({{.*}} : tensor<1x16x64x64xf32>) -> tensor<1x16x64x64xf32>
module attributes {torch.debug_module_name = "HelloWorld"}  {
  func @forward(%arg0: !torch.vtensor<[1,3,128,128],f32>) -> !torch.vtensor<[1,16,64,64],f32> {
    %0 = torch.vtensor.literal(dense<1.000000e+00> : tensor<16xf32>) : !torch.vtensor<[16],f32>
    %1 = torch.vtensor.literal(dense<1.000000e+00> : tensor<16x3x3x3xf32>) : !torch.vtensor<[16,3,3,3],f32>
    %float1.000000e-01 = torch.constant.float 1.000000e-01
    %int0 = torch.constant.int 0
    %int1 = torch.constant.int 1
    %int2 = torch.constant.int 2
    %false = torch.constant.bool false
    %float-Inf = torch.constant.float 0xFFF0000000000000
    %2 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<!torch.int>
    %3 = torch.prim.ListConstruct %int2, %int2 : (!torch.int, !torch.int) -> !torch.list<!torch.int>
    %4 = torch.prim.ListConstruct %int0, %int0 : (!torch.int, !torch.int) -> !torch.list<!torch.int>
    %5 = torch.prim.ListConstruct %int0, %int1, %int0, %int1 : (!torch.int, !torch.int, !torch.int, !torch.int) -> !torch.list<!torch.int>
    %6 = "xten.conv2d_lrelu_pad_maxpool"(%arg0, %1, %0, %2, %2, %2, %int1, %float1.000000e-01, %5, %float-Inf, %3, %3, %4, %2, %false) {layer_name = "conv2d_lrelu_pad_maxpool0"} : (!torch.vtensor<[1,3,128,128],f32>, !torch.vtensor<[16,3,3,3],f32>, !torch.vtensor<[16],f32>, !torch.list<!torch.int>, !torch.list<!torch.int>, !torch.list<!torch.int>, !torch.int, !torch.float, !torch.list<!torch.int>, !torch.float, !torch.list<!torch.int>, !torch.list<!torch.int>, !torch.list<!torch.int>, !torch.list<!torch.int>, !torch.bool) -> !torch.vtensor<[1,16,64,64],f32>
    return %6 : !torch.vtensor<[1,16,64,64],f32>
  }
}

