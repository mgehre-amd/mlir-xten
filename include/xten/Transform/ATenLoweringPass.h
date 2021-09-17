// (c) Copyright 2019 Xilinx Inc. All Rights Reserved.
#ifndef ATEN_LOWERING_PASS_H
#define ATEN_LOWERING_PASS_H

#include <memory>
#include "mlir/Pass/Pass.h"

namespace xilinx {
namespace xten {

std::unique_ptr<mlir::Pass> createATenLoweringPass();

} // namespace xten
} // namespace xilinx

#endif // ATEN_LOWERING_PASS_H
