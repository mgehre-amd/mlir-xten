// RUN: aten-opt %s -xten-minimize-live -split-input-file | FileCheck %s

// A diamond shaped dependency graph, where the order is expected to change.
// CHECK-LABEL:     one_diamond
// CHECK:     "conv2d_relu0"
// CHECK:     "conv2d_relu1"
// CHECK:     "conv2d0"
// CHECK:     "conv2d_tensoradd_relu0"

func.func @one_diamond(%31: !torch.vtensor<[1,64,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32> {
  %int0 = torch.constant.int 0
  %int1 = torch.constant.int 1
  %1 = torch.vtensor.literal(dense<0.00999999977> : tensor<64xf32>) : !torch.vtensor<[64],f32>
  %2 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x1x1xf32>) : !torch.vtensor<[64,64,1,1],f32>
  %3 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x3x3xf32>) : !torch.vtensor<[64,64,3,3],f32>
  %4 = torch.vtensor.literal(dense<2.000000e-02> : tensor<256x64x1x1xf32>) : !torch.vtensor<[256,64,1,1],f32>
  %5 = torch.vtensor.literal(dense<0.00999999977> : tensor<256xf32>) : !torch.vtensor<[256],f32>
  %29 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
  %32 = torch.prim.ListConstruct %int0, %int0 : (!torch.int, !torch.int) -> !torch.list<int>

  %33 = "xten.conv2d"(%31, %4, %5, %29, %32, %29, %int1) {layer_name = "conv2d0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %34 = "xten.conv2d_relu"(%31, %2, %1, %29, %32, %29, %int1) {layer_name = "conv2d_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %35 = "xten.conv2d_relu"(%34, %3, %1, %29, %29, %29, %int1) {layer_name = "conv2d_relu1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %36 = "xten.conv2d_tensoradd_relu"(%35, %4, %5, %29, %32, %29, %int1, %33) {layer_name = "conv2d_tensoradd_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>
  return %36 : !torch.vtensor<[1,256,56,56],f32>
}

// -----

// Same as one_diamond, but the order is already as expected.
// CHECK-LABEL:     one_rev_diamond
// CHECK:     "conv2d_relu0"
// CHECK:     "conv2d_relu1"
// CHECK:     "conv2d0"
// CHECK:     "conv2d_tensoradd_relu0"

func.func @one_rev_diamond(%31: !torch.vtensor<[1,64,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32> {
  %int0 = torch.constant.int 0
  %int1 = torch.constant.int 1
  %1 = torch.vtensor.literal(dense<0.00999999977> : tensor<64xf32>) : !torch.vtensor<[64],f32>
  %2 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x1x1xf32>) : !torch.vtensor<[64,64,1,1],f32>
  %3 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x3x3xf32>) : !torch.vtensor<[64,64,3,3],f32>
  %4 = torch.vtensor.literal(dense<2.000000e-02> : tensor<256x64x1x1xf32>) : !torch.vtensor<[256,64,1,1],f32>
  %5 = torch.vtensor.literal(dense<0.00999999977> : tensor<256xf32>) : !torch.vtensor<[256],f32>
  %29 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
  %32 = torch.prim.ListConstruct %int0, %int0 : (!torch.int, !torch.int) -> !torch.list<int>

  %34 = "xten.conv2d_relu"(%31, %2, %1, %29, %32, %29, %int1) {layer_name = "conv2d_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %35 = "xten.conv2d_relu"(%34, %3, %1, %29, %29, %29, %int1) {layer_name = "conv2d_relu1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %33 = "xten.conv2d"(%31, %4, %5, %29, %32, %29, %int1) {layer_name = "conv2d0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %36 = "xten.conv2d_tensoradd_relu"(%35, %4, %5, %29, %32, %29, %int1, %33) {layer_name = "conv2d_tensoradd_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>
  return %36 : !torch.vtensor<[1,256,56,56],f32>
}

// -----

// Check that the sort is stable for two identical diamonds
// CHECK-LABEL:     double_identical_diamond
// CHECK:     "a_conv2d_relu0"
// CHECK:     "a_conv2d_relu1"
// CHECK:     "a_conv2d0"
// CHECK:     "a_conv2d_tensoradd_relu0"
// CHECK:     "b_conv2d_relu0"
// CHECK:     "b_conv2d_relu1"
// CHECK:     "b_conv2d0"
// CHECK:     "b_conv2d_tensoradd_relu0"
// CHECK:     "add0"

func.func @double_identical_diamond(%a31: !torch.vtensor<[1,64,56,56],f32>, %b31: !torch.vtensor<[1,64,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32> {
  %int0 = torch.constant.int 0
  %int1 = torch.constant.int 1
  %1 = torch.vtensor.literal(dense<0.00999999977> : tensor<64xf32>) : !torch.vtensor<[64],f32>
  %2 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x1x1xf32>) : !torch.vtensor<[64,64,1,1],f32>
  %3 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x3x3xf32>) : !torch.vtensor<[64,64,3,3],f32>
  %4 = torch.vtensor.literal(dense<2.000000e-02> : tensor<256x64x1x1xf32>) : !torch.vtensor<[256,64,1,1],f32>
  %5 = torch.vtensor.literal(dense<0.00999999977> : tensor<256xf32>) : !torch.vtensor<[256],f32>
  %29 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
  %32 = torch.prim.ListConstruct %int0, %int0 : (!torch.int, !torch.int) -> !torch.list<int>

  %a34 = "xten.conv2d_relu"(%a31, %2, %1, %29, %32, %29, %int1) {layer_name = "a_conv2d_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %a35 = "xten.conv2d_relu"(%a34, %3, %1, %29, %29, %29, %int1) {layer_name = "a_conv2d_relu1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %a33 = "xten.conv2d"(%a31, %4, %5, %29, %32, %29, %int1) {layer_name = "a_conv2d0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %a36 = "xten.conv2d_tensoradd_relu"(%a35, %4, %5, %29, %32, %29, %int1, %a33) {layer_name = "a_conv2d_tensoradd_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>

  %b34 = "xten.conv2d_relu"(%b31, %2, %1, %29, %32, %29, %int1) {layer_name = "b_conv2d_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %b35 = "xten.conv2d_relu"(%b34, %3, %1, %29, %29, %29, %int1) {layer_name = "b_conv2d_relu1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %b33 = "xten.conv2d"(%b31, %4, %5, %29, %32, %29, %int1) {layer_name = "b_conv2d0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %b36 = "xten.conv2d_tensoradd_relu"(%b35, %4, %5, %29, %32, %29, %int1, %b33) {layer_name = "b_conv2d_tensoradd_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>

  %36 = "xten.add"(%a36, %b36) {layer_name = "add0"} : (!torch.vtensor<[1,256,56,56],f32>, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>
  return %36 : !torch.vtensor<[1,256,56,56],f32>
}

// -----

// Check that the sort is stable for two identical diamonds
// CHECK-LABEL:     swap_double_identical_diamond
// CHECK:     "b_conv2d_relu0"
// CHECK:     "b_conv2d_relu1"
// CHECK:     "b_conv2d0"
// CHECK:     "b_conv2d_tensoradd_relu0"
// CHECK:     "a_conv2d_relu0"
// CHECK:     "a_conv2d_relu1"
// CHECK:     "a_conv2d0"
// CHECK:     "a_conv2d_tensoradd_relu0"
// CHECK:     "add0"

func.func @swap_double_identical_diamond(%a31: !torch.vtensor<[1,64,56,56],f32>, %b31: !torch.vtensor<[1,64,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32> {
  %int0 = torch.constant.int 0
  %int1 = torch.constant.int 1
  %1 = torch.vtensor.literal(dense<0.00999999977> : tensor<64xf32>) : !torch.vtensor<[64],f32>
  %2 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x1x1xf32>) : !torch.vtensor<[64,64,1,1],f32>
  %3 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x3x3xf32>) : !torch.vtensor<[64,64,3,3],f32>
  %4 = torch.vtensor.literal(dense<2.000000e-02> : tensor<256x64x1x1xf32>) : !torch.vtensor<[256,64,1,1],f32>
  %5 = torch.vtensor.literal(dense<0.00999999977> : tensor<256xf32>) : !torch.vtensor<[256],f32>
  %29 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
  %32 = torch.prim.ListConstruct %int0, %int0 : (!torch.int, !torch.int) -> !torch.list<int>

  %b34 = "xten.conv2d_relu"(%b31, %2, %1, %29, %32, %29, %int1) {layer_name = "b_conv2d_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %b35 = "xten.conv2d_relu"(%b34, %3, %1, %29, %29, %29, %int1) {layer_name = "b_conv2d_relu1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %b33 = "xten.conv2d"(%b31, %4, %5, %29, %32, %29, %int1) {layer_name = "b_conv2d0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %b36 = "xten.conv2d_tensoradd_relu"(%b35, %4, %5, %29, %32, %29, %int1, %b33) {layer_name = "b_conv2d_tensoradd_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>

  %a34 = "xten.conv2d_relu"(%a31, %2, %1, %29, %32, %29, %int1) {layer_name = "a_conv2d_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %a35 = "xten.conv2d_relu"(%a34, %3, %1, %29, %29, %29, %int1) {layer_name = "a_conv2d_relu1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %a33 = "xten.conv2d"(%a31, %4, %5, %29, %32, %29, %int1) {layer_name = "a_conv2d0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %a36 = "xten.conv2d_tensoradd_relu"(%a35, %4, %5, %29, %32, %29, %int1, %a33) {layer_name = "a_conv2d_tensoradd_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>

  %36 = "xten.add"(%b36, %a36) {layer_name = "add0"} : (!torch.vtensor<[1,256,56,56],f32>, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>
  return %36 : !torch.vtensor<[1,256,56,56],f32>
}

// -----

// Two diamond shaped dependency graph, where the order is expected to change.
// CHECK-LABEL:     two_diamond
// CHECK:     "conv2d_relu0"
// CHECK:     "conv2d_relu1"
// CHECK:     "conv2d0"
// CHECK:     "conv2d_tensoradd_relu0"
// CHECK:     "conv2d_relu2"
// CHECK:     "conv2d_relu3"
// CHECK:     "conv2d1"
// CHECK:     "conv2d_tensoradd_relu1"

func.func @two_diamond(%31: !torch.vtensor<[1,64,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32> {
  %int0 = torch.constant.int 0
  %int1 = torch.constant.int 1
  %1 = torch.vtensor.literal(dense<0.00999999977> : tensor<64xf32>) : !torch.vtensor<[64],f32>
  %2 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x1x1xf32>) : !torch.vtensor<[64,64,1,1],f32>
  %3 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x3x3xf32>) : !torch.vtensor<[64,64,3,3],f32>
  %4 = torch.vtensor.literal(dense<2.000000e-02> : tensor<256x64x1x1xf32>) : !torch.vtensor<[256,64,1,1],f32>
  %5 = torch.vtensor.literal(dense<0.00999999977> : tensor<256xf32>) : !torch.vtensor<[256],f32>
  %6 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x256x1x1xf32>) : !torch.vtensor<[64,256,1,1],f32>
  %29 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
  %32 = torch.prim.ListConstruct %int0, %int0 : (!torch.int, !torch.int) -> !torch.list<int>

  %33 = "xten.conv2d"(%31, %4, %5, %29, %32, %29, %int1) {layer_name = "conv2d0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %34 = "xten.conv2d_relu"(%31, %2, %1, %29, %32, %29, %int1) {layer_name = "conv2d_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %35 = "xten.conv2d_relu"(%34, %3, %1, %29, %29, %29, %int1) {layer_name = "conv2d_relu1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %36 = "xten.conv2d_tensoradd_relu"(%35, %4, %5, %29, %32, %29, %int1, %33) {layer_name = "conv2d_tensoradd_relu0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>

  %x15 = torch.vtensor.literal(dense<2.000000e-02> : tensor<256x256x1x1xf32>) : !torch.vtensor<[256,256,1,1],f32>
  %x33 = "xten.conv2d"(%36, %x15, %5, %29, %32, %29, %int1) {layer_name = "conv2d1"} : (!torch.vtensor<[1,256,56,56],f32>, !torch.vtensor<[256,256,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %37 = "xten.conv2d_relu"(%36, %6, %1, %29, %32, %29, %int1) {layer_name = "conv2d_relu2"} : (!torch.vtensor<[1,256,56,56],f32>, !torch.vtensor<[64,256,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %38 = "xten.conv2d_relu"(%37, %3, %1, %29, %29, %29, %int1) {layer_name = "conv2d_relu3"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
  %39 = "xten.conv2d_tensoradd_relu"(%38, %4, %5, %29, %32, %29, %int1, %x33) {layer_name = "conv2d_tensoradd_relu1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>

  return %39 : !torch.vtensor<[1,256,56,56],f32>
}

// -----

// CHECK-LABEL:     forward
// CHECK:     "conv_0"
// CHECK:     "conv_1"
// CHECK:     "concat_0"
// CHECK:     "conv_6"
// CHECK:     "conv_3"
// CHECK:     "conv_2"
// CHECK:     "conv_4"
// CHECK:     "conv_7"

func.func @forward(%arg0: !torch.vtensor<[1,4,224,224],f32>) -> !torch.vtensor<[1,256,56,56],f32> attributes {input_names = ["global_input_0"], output_names = ["global_outout_0"]} {
    %int3 = torch.constant.int 3
    %int0 = torch.constant.int 0
    %int2 = torch.constant.int 2
    %int1 = torch.constant.int 1
    %false = torch.constant.bool false
    %0 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x4x7x7xf32>) : !torch.vtensor<[64,4,7,7],f32>
    %1 = torch.vtensor.literal(dense<0.00999999977> : tensor<64xf32>) : !torch.vtensor<[64],f32>
    %2 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x1x1xf32>) : !torch.vtensor<[64,64,1,1],f32>
    %3 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x64x3x3xf32>) : !torch.vtensor<[64,64,3,3],f32>
    %4 = torch.vtensor.literal(dense<2.000000e-02> : tensor<256x64x1x1xf32>) : !torch.vtensor<[256,64,1,1],f32>
    %5 = torch.vtensor.literal(dense<0.00999999977> : tensor<256xf32>) : !torch.vtensor<[256],f32>
    %6 = torch.vtensor.literal(dense<2.000000e-02> : tensor<64x256x1x1xf32>) : !torch.vtensor<[64,256,1,1],f32>
    %28 = torch.prim.ListConstruct %int2, %int2 : (!torch.int, !torch.int) -> !torch.list<int>
    %29 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
    %30 = torch.prim.ListConstruct %int3, %int3 : (!torch.int, !torch.int) -> !torch.list<int>
    %31 = torch.prim.ListConstruct %int0, %int0 : (!torch.int, !torch.int) -> !torch.list<int>
    %32 = "xten.conv2d_relu_maxpool"(%arg0, %0, %1, %28, %30, %29, %int1, %30, %28, %29, %29, %false) {layer_name = "conv_0"} : (!torch.vtensor<[1,4,224,224],f32>, !torch.vtensor<[64,4,7,7],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.bool) -> !torch.vtensor<[1,64,56,56],f32>
    %33 = "xten.conv2d_relu"(%32, %2, %1, %29, %31, %29, %int1) {layer_name = "conv_1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,1,1],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
    %35 = "xten.conv2d"(%32, %4, %5, %29, %31, %29, %int1) {layer_name = "conv_2"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
    %34 = "xten.conv2d_relu"(%33, %3, %1, %29, %29, %29, %int1) {layer_name = "conv_3"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
    %36 = "xten.conv2d_tensoradd_relu"(%34, %4, %5, %29, %31, %29, %int1, %35) {layer_name = "conv_4"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>
    %56 = torch.prim.ListConstruct %32, %33 : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[1,64,56,56],f32>) -> !torch.list<vtensor>
    %37 = torch.aten.cat %56, %int1 {layer_name = "concat_0"} : !torch.list<vtensor>, !torch.int -> !torch.vtensor<[1,256,56,56],f32>
    %38 = "xten.conv2d_relu"(%37, %3, %1, %29, %29, %29, %int1) {layer_name = "conv_6"} : (!torch.vtensor<[1,256,56,56],f32>, !torch.vtensor<[64,64,3,3],f32>, !torch.vtensor<[64],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,64,56,56],f32>
    %39 = "xten.conv2d_tensoradd_relu"(%38, %4, %5, %29, %31, %29, %int1, %36) {layer_name = "conv_7"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>
    return %39 : !torch.vtensor<[1,256,56,56],f32>
}

// -----

// Legal dead code where (dead) operations make no use of any xten operands. The order is expected to change.
// CHECK-LABEL:     legal_dead_code1
// CHECK:     "conv2d2"
// CHECK:     "conv2d0"
// CHECK:     "conv2d1"
// CHECK:     "add1"
func.func @legal_dead_code1(%arg0: !torch.vtensor<[1,64,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32> {
  %int0 = torch.constant.int 0
  %int1 = torch.constant.int 1
  %1 = torch.vtensor.literal(dense<2.000000e-02> : tensor<256x64x1x1xf32>) : !torch.vtensor<[256,64,1,1],f32>
  %2 = torch.vtensor.literal(dense<0.00999999977> : tensor<256xf32>) : !torch.vtensor<[256],f32>
  %29 = torch.prim.ListConstruct %int1, %int1 : (!torch.int, !torch.int) -> !torch.list<int>
  %32 = torch.prim.ListConstruct %int0, %int0 : (!torch.int, !torch.int) -> !torch.list<int>

  %33 = "xten.conv2d"(%arg0, %1, %2, %29, %32, %29, %int1) {layer_name = "conv2d0"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %34 = "xten.conv2d"(%arg0, %1, %2, %29, %32, %29, %int1) {layer_name = "conv2d1"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %35 = "xten.conv2d"(%arg0, %1, %2, %29, %32, %29, %int1) {layer_name = "conv2d2"} : (!torch.vtensor<[1,64,56,56],f32>, !torch.vtensor<[256,64,1,1],f32>, !torch.vtensor<[256],f32>, !torch.list<int>, !torch.list<int>, !torch.list<int>, !torch.int) -> !torch.vtensor<[1,256,56,56],f32>
  %37 = "xten.add"(%33, %34) {layer_name = "add1"} : (!torch.vtensor<[1,256,56,56],f32>, !torch.vtensor<[1,256,56,56],f32>) -> !torch.vtensor<[1,256,56,56],f32>
  return %37 : !torch.vtensor<[1,256,56,56],f32>
}