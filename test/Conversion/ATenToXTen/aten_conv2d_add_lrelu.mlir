//===- aten_conv2d_nobias.mlir ---------------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2019 Xilinx Inc.
//
//===----------------------------------------------------------------------===//

// RUN: aten-opt %s -aten-to-xten | FileCheck %s
// CHECK: %5 = "xten.conv2d_tensoradd_lrelu"(%4, %0, %none, %1, %2, %3, %int1, %float4.000000e-01, %arg0) : (!torch.vtensor<[1,2,128,128],f32>, !torch.vtensor<[16,2,3,3],f32>, !torch.none, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.float, !torch.vtensor<[1,2,128,128],f32>) -> !torch.vtensor<[1,2,128,128],f32>
module attributes {torch.debug_module_name = "model"}  {
  func @forward(%arg0: !torch.vtensor<[1,2,128,128],f32>) -> !torch.vtensor<[1,2,128,128],f32> {
    %int1 = torch.constant.int 1
    %alpha = torch.constant.float 0.4
    %0 = torch.vtensor.literal(dense<"0xDEADBEEF"> : tensor<16x2x3x3xf32>) : !torch.vtensor<[16,2,3,3],f32>
    %none = torch.constant.none
    %1 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
    %2 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
    %3 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
    %4 = torch.aten.conv2d %arg0, %0, %none, %1, %2, %3, %int1 : !torch.vtensor<[1,2,128,128],f32>, !torch.vtensor<[16,2,3,3],f32>, !torch.none, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int -> !torch.vtensor<[1,2,128,128],f32>
    %5 = torch.aten.relu %4 : !torch.vtensor<[1,2,128,128],f32> -> !torch.vtensor<[1,2,128,128],f32>


    %6 = torch.aten.conv2d %5, %0, %none, %1, %2, %3, %int1 : !torch.vtensor<[1,2,128,128],f32>, !torch.vtensor<[16,2,3,3],f32>, !torch.none, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int -> !torch.vtensor<[1,2,128,128],f32>
    %7 = torch.aten.add.Tensor %6, %arg0, %int1 : !torch.vtensor<[1,2,128,128],f32>, !torch.vtensor<[1,2,128,128],f32>, !torch.int ->  !torch.vtensor<[1,2,128,128],f32>
    %8 = torch.aten.leaky_relu %7, %alpha : !torch.vtensor<[1,2,128,128],f32>, !torch.float -> !torch.vtensor<[1,2,128,128],f32>
    return %8 : !torch.vtensor<[1,2,128,128],f32>
  }
}
