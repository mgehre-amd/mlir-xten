// (c) Copyright 2020 Xilinx Inc. All Rights Reserved.
#ifndef LOWER_TO_LIBATEN_PASS_H
#define LOWER_TO_LIBATEN_PASS_H

#include <memory>
#include "mlir/Pass/Pass.h"

namespace xilinx {
namespace aten {

std::unique_ptr<mlir::Pass> createLowerToLibATenPass();
void registerLowerToLibATenPass();

} // namespace aten
} // namespace xilinx

#endif // LOWER_TO_LIBATEN_PASS_H