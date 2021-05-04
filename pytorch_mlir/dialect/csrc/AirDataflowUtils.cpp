#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/OperationSupport.h"

#include "AirDataflowUtils.h"

#define DEBUG_TYPE "air-dataflow-utils"

using namespace mlir;

// Weight locations
#define COUT_LOC 0
#define CIN_LOC 1
#define F0_LOC 2
#define F1_LOC 3

// Acts locs
#define C_LOC 0
#define N_LOC 1
#define M_LOC 2

namespace xilinx {
    namespace air {
        ShapedType breakShapeInto(ShapedType initShape, unsigned int at, unsigned int into) {
            auto shape = initShape.getShape();
            std::vector<long> newShape = std::vector<long>(shape);
            newShape[at] = newShape[at] / into;
            shape = initShape.getShape();
            //int i = 0;
            //for(auto e : shape) {
            //llvm::outs() << "Got shape: " << e << " vs " << newShape[i] << "\n";
            //newShape.push_back(e);
            //i++;
            //}

            ArrayRef<long> nShape = ArrayRef<long>(newShape);
            ShapedType ttype = RankedTensorType::get(nShape, initShape.getElementType());

            return ttype;
        }

        // TODO most likely factor some code here
        void splitConstantActivationsInto(ConstantOp op, std::vector<Value> &ops, OpBuilder &builder, unsigned int loc,
                                          DenseElementsAttr at, unsigned int into) {
            ShapedType initialShape = at.getType();
            ArrayRef<int64_t> s = initialShape.getShape();

            uint64_t C = s[CIN_LOC];
            uint64_t N = s[N_LOC];
            uint64_t M = s[M_LOC];

            uint64_t C_switch = C;
            uint64_t N_switch = N;
            uint64_t M_switch = M;

            if(loc == 0) {
                C_switch = C / into;
            } else if(loc == 1) {
                N_switch = N / into;
            } else if(loc == 2) {
                M_switch = M / into;
            }

            if(initialShape.getElementType().isF32()) { // TODO more types
                std::vector<std::vector<APFloat>> vects;
                for(unsigned int i = 0; i < into; i++) {
                    vects.push_back(std::vector<APFloat>());
                }

                uint64_t i = 0;
                for(auto it =  at.float_value_begin(); it != at.float_value_end(); it++) {
                    //llvm::outs() << "Got this value: ";
                    //(*it).print(llvm::outs());
                    uint64_t loc_c = i / (M * N);
                    uint64_t loc_N = (i / M) % N;
                    uint64_t loc_M = i % M;

                    uint64_t vectsId = std::max(std::max(loc_c / C_switch, loc_N / N_switch),
                                                loc_M / M_switch);

                    vects.at(vectsId).push_back(*it);
                    i++;
                }

                for(uint64_t i = 0; i < into; i++) {
                    assert(vects.at(i).size() == (at.getType().getNumElements() / into));
                }

                ShapedType ttype = breakShapeInto(initialShape, loc, into);

                for(uint64_t i = 0; i < into; i++) {
                    DenseElementsAttr attr = DenseElementsAttr::get(ttype, vects.at(i));
                    Operation* cst = builder.create<ConstantOp>(builder.getUnknownLoc(), ttype, attr);
                    ops.push_back(cst->getResult(0));
                }
            }
        }

        // Splits weights into according to dim given by loc
        void splitConstantWeightsInto(ConstantOp op, std::vector<Value> &ops, OpBuilder &builder, unsigned int loc,
                                  DenseElementsAttr at, unsigned int into) {
            ShapedType initialShape = at.getType();
            ArrayRef<int64_t> s = initialShape.getShape();

            uint64_t COut = s[COUT_LOC];
            uint64_t CIn = s[CIN_LOC];
            uint64_t F0 = s[F0_LOC];
            uint64_t F1 = s[F1_LOC];

            uint64_t COut_switch = COut;
            uint64_t CIn_switch = CIn;
            uint64_t F0_switch = F0;
            uint64_t F1_switch = F1;

            if(loc == 0) {
                COut_switch = COut / into;
            } else if(loc == 1) {
                CIn_switch = CIn / into;
            } else if(loc == 2) {
                F0_switch = F0 / into;
            } else if(loc == 3) {
                F1_switch = F1 / into;
            }

            if(initialShape.getElementType().isF32()) { // TODO is this the only choice?
                std::vector<std::vector<APFloat>> vects;
                for(unsigned int i = 0; i < into; i++) {
                    vects.push_back(std::vector<APFloat>());
                }

                uint64_t i = 0;
                for(auto it =  at.float_value_begin(); it != at.float_value_end(); it++) {
                    //llvm::outs() << "Got this value: ";
                    //(*it).print(llvm::outs());

                    uint64_t loc_cout = i / (F0 * F1 * CIn);
                    uint64_t loc_cin = (i / (F0 * F1)) % CIn;
                    uint64_t loc_F0 = (i / F1) % F0;
                    uint64_t loc_F1 = i % F1;

                    uint64_t vectsId = std::max(std::max(loc_cout / COut_switch, loc_cin / CIn_switch),
                                                std::max(loc_F0 / F0_switch, loc_F1 / F1_switch));

                    vects.at(vectsId).push_back(*it);
                    i++;
                }

                for(uint64_t i = 0; i < into; i++) {
                    assert(vects.at(i).size() == (at.getType().getNumElements() / into));
                }

                ShapedType ttype = breakShapeInto(initialShape, loc, into);

                for(uint64_t i = 0; i < into; i++) {
                    DenseElementsAttr attr = DenseElementsAttr::get(ttype, vects.at(i));
                    Operation* cst = builder.create<ConstantOp>(builder.getUnknownLoc(), ttype, attr);
                    ops.push_back(cst->getResult(0));
                }
            }
        }

        // loc = 0 split
        // loc > 0 generate some other 0 biases
        void splitConstantBiasInto(ConstantOp op, std::vector<Value> &ops, OpBuilder &builder, unsigned int loc, DenseElementsAttr at, unsigned int into) {
            ShapedType initialShape = at.getType();
            if(initialShape.getElementType().isF32()) { // TODO extend to more types
                std::vector<std::vector<APFloat>> vects;
                for(unsigned int i = 0; i < into; i++) {
                    vects.push_back(std::vector<APFloat>());
                }

                uint64_t i = 0;
                for(auto it =  at.float_value_begin(); it != at.float_value_end(); it++) {
                    if(loc == 0) {
                        unsigned int index = i / (at.getType().getNumElements() / into);
                        vects.at(index).push_back(*it);
                    } else {
                        vects.at(0).push_back(*it);
                        // NOTE assume that same kernel with 0 bias from the compiler point of view
                        // NOTE create duplicate constants here
                        for(unsigned int j = 1; j < into; j++) {
                            vects.at(1).push_back(APFloat((float)0));
                        }
                    }
                    i++;
                }

                for(uint64_t i = 0; i < vects.size(); i++) {
                    assert(vects.at(i).size() == ((loc == 0) ? at.getType().getNumElements() / into : at.getType().getNumElements()));
                }

                // now splitted the dense in into parts, need to regenerate it
                ShapedType ttype;
                if(loc == 0) {
                    ttype = breakShapeInto(initialShape, 0, into);
                } else {
                    ttype = initialShape;
                }

                for(uint64_t i = 0; i < into; i++) {
                    DenseElementsAttr attr = DenseElementsAttr::get(ttype, vects.at(i));
                    Operation* cst = builder.create<ConstantOp>(builder.getUnknownLoc(), ttype, attr);
                    ops.push_back(cst->getResult(0));
                }
            }
        }

        // TODO support WSplit
        unsigned int splitToDim(Split split, SplitType t) {
            if(t == bSplitType) {
                if(split == PSplit) {
                    return 0;
                } else {
                    return 1;
                }
            } else if(t == aSplitType) {
                if(split == CaSplit) {
                    return 0;
                } else {
                    return (unsigned int )-1;
                }
            } else if(t == wSplitType) {
                if(split == PSplit) {
                    return 0;
                } else if(split == CaSplit) {
                    return 1;
                } else if(split == LSplit) {
                    return 2;
                }
            }
        }

        void splitConstantInto(ConstantOp op, std::vector<Value> &ops, OpBuilder &builder, Split split, SplitType t, unsigned int into) {
            for(NamedAttribute attr: op->getAttrs()) {
                // We Look for the Dense Attribute
                auto at = attr.second.dyn_cast<DenseElementsAttr>();
                if(at) {
                    if(t == bSplitType) {
                        unsigned int splitDim = splitToDim(split, t);
                        splitConstantBiasInto(op, ops, builder, splitDim, at, into);
                    } else if(t == aSplitType) {
                        unsigned int splitDim = splitToDim(split, t);
                        if(splitDim == (unsigned int)-1) {
                            // TODO maybe fail silently if top level is fine with that
                            llvm::outs() << "Only Ca split is supported to split activation tensors";
                            exit(1);
                        } else {
                            splitConstantActivationsInto(op, ops, builder, splitDim, at, into);
                        }
                    } else {
                        unsigned int splitDim = splitToDim(split, t);
                        splitConstantWeightsInto(op, ops, builder, splitDim, at, into);
                    }

                }
            }
        }

        void deleteOpsFrom(std::vector<Operation*> &ops) {
            for(unsigned int i = 0; i < ops.size(); i++) {
                ops.at(i)->erase();
            }
            ops.clear();
        }

        void insertConcat(OpBuilder &builder, Value prevRes, std::vector<Value> &values, unsigned int dim) {
            ShapedType prevResType = prevRes.getType().dyn_cast<ShapedType>();
            for(Operation* userOp: prevRes.getUsers()) {
                llvm::outs() << "Op is: " << userOp->getName() << "\n";
            }

            ArrayRef<Value> valuesRef = ArrayRef<Value>(values);
            ValueRange valuesRange(valuesRef);

            Operation* cstDim = builder.create<ConstantIntOp>(builder.getUnknownLoc(), dim, 32);
            Operation* res = builder.create<xilinx::air::ConcatOp>(builder.getUnknownLoc(), prevResType, valuesRange, cstDim->getResult(0));

            // Replace output of old convolution usage by concat value
            prevRes.replaceAllUsesWith(res->getResult(0));
        }

        void replaceSplit(OpBuilder &builder, xilinx::air::SplitOp split, std::vector<Value> &values, std::vector<Operation*> &toDelete, unsigned int dim) {
            unsigned int into = values.size();

            if(split.getNumResults() == into) {
                for(unsigned int i = 0; i < into; i++) {
                    split.getResult(i).replaceAllUsesWith(values.at(i));
                }

                // Delete split
                toDelete.push_back(split);
            } else {
                unsigned int splitResults = split.getNumResults();
                unsigned int resPerConv = splitResults / into;
                unsigned int rem = splitResults % into;

                unsigned int consumed = 0;
                for(unsigned int i = 0; i < into; i++) {
                    unsigned int shouldHandle = resPerConv + ((i > rem ) ? 1 : 0);
                    if(shouldHandle == 1) {
                        split.getResult(consumed).replaceAllUsesWith(values.at(i));
                        consumed++;
                    } else {
                        // TODO handle case where cannot do the expected split
                        // TODO double check the split op here
                        ArrayRef<Value> af = ArrayRef<Value>(values);
                        Operation* cstDim = builder.create<ConstantIntOp>(builder.getUnknownLoc(), dim, 32);
                        Operation* splitOp = builder.create<xilinx::air::SplitOp>(builder.getUnknownLoc(), TypeRange(af), values.at(i), cstDim->getResult(0));
                        for(unsigned int j = 0; j < shouldHandle; j++) {
                            split.getResult(consumed).replaceAllUsesWith(splitOp->getResult(j));
                            consumed++;
                        }
                    }
                }

                toDelete.push_back(split);
            }

        }

    }
}

