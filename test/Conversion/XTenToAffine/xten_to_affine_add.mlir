//===- air_to_affine_add.mlir ----------------------------------*- MLIR -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2021 Xilinx Inc.
//
//===----------------------------------------------------------------------===//

// RUN: aten-opt %s --xten-to-affine -cse | FileCheck %s
// NOTE: Assertions have been autogenerated by utils/generate-test-checks.py


// CHECK-LABEL:   func @forward(
// CHECK:           %[[VAL_2:.*]] = memref.alloc() : memref<3x4x5xf32>
// CHECK:           %[[VAL_3:.*]] = memref.buffer_cast %[[VAL_0:.*]] : memref<3x4x5xf32>
// CHECK:           %[[VAL_4:.*]] = memref.buffer_cast %[[VAL_1:.*]] : memref<3x4x5xf32>
// CHECK:           affine.for %[[VAL_5:.*]] = 0 to 3 {
// CHECK:             affine.for %[[VAL_6:.*]] = 0 to 4 {
// CHECK:               affine.for %[[VAL_7:.*]] = 0 to 5 {
// CHECK:                 %[[VAL_8:.*]] = affine.load %[[VAL_3]]{{\[}}%[[VAL_5]], %[[VAL_6]], %[[VAL_7]]] : memref<3x4x5xf32>
// CHECK:                 %[[VAL_9:.*]] = affine.load %[[VAL_4]]{{\[}}%[[VAL_5]], %[[VAL_6]], %[[VAL_7]]] : memref<3x4x5xf32>
// CHECK:                 %[[VAL_10:.*]] = addf %[[VAL_8]], %[[VAL_9]] : f32
// CHECK:                 affine.store %[[VAL_10]], %[[VAL_2]]{{\[}}%[[VAL_5]], %[[VAL_6]], %[[VAL_7]]] : memref<3x4x5xf32>
// CHECK:               }
// CHECK:             }
// CHECK:           } {affine_opt_label = "{{.*}}"}
// CHECK:           %[[VAL_11:.*]] = memref.tensor_load %[[VAL_2]] : memref<3x4x5xf32>
module attributes {torch.debug_module_name = "model"}  {
  func @forward(%arg0: !torch.vtensor<[3,4,5],f32>, %arg1: !torch.vtensor<[3,4,5],f32>) -> !torch.vtensor<[?,?],f32> {
    %0 = "xten.add"(%arg0, %arg1) : (!torch.vtensor<[3,4,5],f32>, !torch.vtensor<[3,4,5],f32>) -> !torch.vtensor<[?,?],f32>
    return %0 : !torch.vtensor<[?,?],f32>
  }
}