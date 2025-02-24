; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-vectorize -force-vector-interleave=1 -instcombine -mattr=+sve -mtriple aarch64-unknown-linux-gnu \
; RUN:     -pass-remarks-missed=loop-vectorize < %s 2>%t | FileCheck %s
; RUN: cat %t | FileCheck %s --check-prefix=CHECK-REMARKS
; RUN: opt -S -loop-vectorize -force-vector-interleave=1 -force-target-instruction-cost=1 -instcombine -mattr=+sve -mtriple aarch64-unknown-linux-gnu \
; RUN:     -pass-remarks-missed=loop-vectorize < %s 2>%t | FileCheck %s
; RUN: cat %t | FileCheck %s --check-prefix=CHECK-REMARKS

define void @vec_load(i64 %N, double* nocapture %a, double* nocapture readonly %b) {
; CHECK-LABEL: @vec_load(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP7:%.*]] = icmp sgt i64 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP7]], label [[FOR_BODY_PREHEADER:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP1:%.*]] = shl i64 [[TMP0]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ugt i64 [[TMP1]], [[N]]
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_MEMCHECK:%.*]]
; CHECK:       vector.memcheck:
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr double, double* [[A:%.*]], i64 [[N]]
; CHECK-NEXT:    [[SCEVGEP4:%.*]] = getelementptr double, double* [[B:%.*]], i64 [[N]]
; CHECK-NEXT:    [[BOUND0:%.*]] = icmp ugt double* [[SCEVGEP4]], [[A]]
; CHECK-NEXT:    [[BOUND1:%.*]] = icmp ugt double* [[SCEVGEP]], [[B]]
; CHECK-NEXT:    [[FOUND_CONFLICT:%.*]] = and i1 [[BOUND0]], [[BOUND1]]
; CHECK-NEXT:    br i1 [[FOUND_CONFLICT]], label [[SCALAR_PH]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP3:%.*]] = shl i64 [[TMP2]], 1
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N]], [[TMP3]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds double, double* [[B]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast double* [[TMP4]] to <vscale x 2 x double>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 2 x double>, <vscale x 2 x double>* [[TMP5]], align 8, !alias.scope !5
; CHECK-NEXT:    [[TMP6:%.*]] = call <vscale x 2 x double> @foo_vec(<vscale x 2 x double> [[WIDE_LOAD]])
; CHECK-NEXT:    [[TMP7:%.*]] = fadd <vscale x 2 x double> [[TMP6]], shufflevector (<vscale x 2 x double> insertelement (<vscale x 2 x double> poison, double 1.000000e+00, i32 0), <vscale x 2 x double> poison, <vscale x 2 x i32> zeroinitializer)
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds double, double* [[A]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast double* [[TMP8]] to <vscale x 2 x double>*
; CHECK-NEXT:    store <vscale x 2 x double> [[TMP7]], <vscale x 2 x double>* [[TMP9]], align 8, !alias.scope !8, !noalias !5
; CHECK-NEXT:    [[TMP10:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP11:%.*]] = shl i64 [[TMP10]], 1
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP11]]
; CHECK-NEXT:    [[TMP12:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP12]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP10:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N_MOD_VF]], 0
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END_LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[FOR_BODY_PREHEADER]] ], [ 0, [[VECTOR_MEMCHECK]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds double, double* [[B]], i64 [[IV]]
; CHECK-NEXT:    [[TMP13:%.*]] = load double, double* [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[TMP14:%.*]] = call double @foo(double [[TMP13]]) #[[ATTR5:[0-9]+]]
; CHECK-NEXT:    [[ADD:%.*]] = fadd double [[TMP14]], 1.000000e+00
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds double, double* [[A]], i64 [[IV]]
; CHECK-NEXT:    store double [[ADD]], double* [[ARRAYIDX2]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP12:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp7 = icmp sgt i64 %N, 0
  br i1 %cmp7, label %for.body, label %for.end

for.body:                                         ; preds = %for.body.preheader, %for.body
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %arrayidx = getelementptr inbounds double, double* %b, i64 %iv
  %0 = load double, double* %arrayidx, align 8
  %1 = call double @foo(double %0) #0
  %add = fadd double %1, 1.000000e+00
  %arrayidx2 = getelementptr inbounds double, double* %a, i64 %iv
  store double %add, double* %arrayidx2, align 8
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, %N
  br i1 %exitcond.not, label %for.end, label %for.body, !llvm.loop !1

for.end:                                 ; preds = %for.body, %entry
  ret void
}

define void @vec_scalar(i64 %N, double* nocapture %a) {
; CHECK-LABEL: @vec_scalar(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP7:%.*]] = icmp sgt i64 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP7]], label [[FOR_BODY_PREHEADER:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP1:%.*]] = shl i64 [[TMP0]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ugt i64 [[TMP1]], [[N]]
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP3:%.*]] = shl i64 [[TMP2]], 1
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N]], [[TMP3]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = call <vscale x 2 x double> @foo_vec(<vscale x 2 x double> shufflevector (<vscale x 2 x double> insertelement (<vscale x 2 x double> poison, double 1.000000e+01, i32 0), <vscale x 2 x double> poison, <vscale x 2 x i32> zeroinitializer))
; CHECK-NEXT:    [[TMP5:%.*]] = fsub <vscale x 2 x double> [[TMP4]], shufflevector (<vscale x 2 x double> insertelement (<vscale x 2 x double> poison, double 1.000000e+00, i32 0), <vscale x 2 x double> poison, <vscale x 2 x i32> zeroinitializer)
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds double, double* [[A:%.*]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP7:%.*]] = bitcast double* [[TMP6]] to <vscale x 2 x double>*
; CHECK-NEXT:    store <vscale x 2 x double> [[TMP5]], <vscale x 2 x double>* [[TMP7]], align 8
; CHECK-NEXT:    [[TMP8:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP9:%.*]] = shl i64 [[TMP8]], 1
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP9]]
; CHECK-NEXT:    [[TMP10:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP10]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP13:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N_MOD_VF]], 0
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END_LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[FOR_BODY_PREHEADER]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[TMP11:%.*]] = call double @foo(double 1.000000e+01) #[[ATTR5]]
; CHECK-NEXT:    [[SUB:%.*]] = fadd double [[TMP11]], -1.000000e+00
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds double, double* [[A]], i64 [[IV]]
; CHECK-NEXT:    store double [[SUB]], double* [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP14:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp7 = icmp sgt i64 %N, 0
  br i1 %cmp7, label %for.body, label %for.end

for.body:                                         ; preds = %for.body.preheader, %for.body
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %0 = call double @foo(double 10.0) #0
  %sub = fsub double %0, 1.000000e+00
  %arrayidx = getelementptr inbounds double, double* %a, i64 %iv
  store double %sub, double* %arrayidx, align 8
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond.not = icmp eq i64 %iv.next, %N
  br i1 %exitcond.not, label %for.end, label %for.body, !llvm.loop !1

for.end:                                 ; preds = %for.body, %entry
  ret void
}

define void @vec_ptr(i64 %N, i64* noalias %a, i64** readnone %b) {
; CHECK-LABEL: @vec_ptr(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP7:%.*]] = icmp sgt i64 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP7]], label [[FOR_BODY_PREHEADER:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP1:%.*]] = shl i64 [[TMP0]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ugt i64 [[TMP1]], 1024
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP3:%.*]] = shl i64 [[TMP2]], 1
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 1024, [[TMP3]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub nsw i64 1024, [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr i64*, i64** [[B:%.*]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast i64** [[TMP4]] to <vscale x 2 x i64*>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 2 x i64*>, <vscale x 2 x i64*>* [[TMP5]], align 8
; CHECK-NEXT:    [[TMP6:%.*]] = call <vscale x 2 x i64> @bar_vec(<vscale x 2 x i64*> [[WIDE_LOAD]])
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i64, i64* [[A:%.*]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast i64* [[TMP7]] to <vscale x 2 x i64>*
; CHECK-NEXT:    store <vscale x 2 x i64> [[TMP6]], <vscale x 2 x i64>* [[TMP8]], align 4
; CHECK-NEXT:    [[TMP9:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP10:%.*]] = shl i64 [[TMP9]], 1
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP10]]
; CHECK-NEXT:    [[TMP11:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP11]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP16:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N_MOD_VF]], 0
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END_LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[FOR_BODY_PREHEADER]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i64*, i64** [[B]], i64 [[IV]]
; CHECK-NEXT:    [[LOAD:%.*]] = load i64*, i64** [[GEP]], align 8
; CHECK-NEXT:    [[CALL:%.*]] = call i64 @bar(i64* [[LOAD]]) #[[ATTR6:[0-9]+]]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i64, i64* [[A]], i64 [[IV]]
; CHECK-NEXT:    store i64 [[CALL]], i64* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[IV_NEXT]], 1024
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP17:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp7 = icmp sgt i64 %N, 0
  br i1 %cmp7, label %for.body, label %for.end

for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %gep = getelementptr i64*, i64** %b, i64 %iv
  %load = load i64*, i64** %gep
  %call = call i64 @bar(i64* %load) #1
  %arrayidx = getelementptr inbounds i64, i64* %a, i64 %iv
  store i64 %call, i64* %arrayidx
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond = icmp eq i64 %iv.next, 1024
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !1

for.end:
  ret void
}

define void @vec_intrinsic(i64 %N, double* nocapture readonly %a) {
; CHECK-LABEL: @vec_intrinsic(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP7:%.*]] = icmp sgt i64 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP7]], label [[FOR_BODY_PREHEADER:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.body.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP1:%.*]] = shl i64 [[TMP0]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ugt i64 [[TMP1]], [[N]]
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[TMP2:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP3:%.*]] = shl i64 [[TMP2]], 1
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[N]], [[TMP3]]
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[N]], [[N_MOD_VF]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds double, double* [[A:%.*]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast double* [[TMP4]] to <vscale x 2 x double>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <vscale x 2 x double>, <vscale x 2 x double>* [[TMP5]], align 8
; CHECK-NEXT:    [[TMP6:%.*]] = call fast <vscale x 2 x double> @sin_vec_nxv2f64(<vscale x 2 x double> [[WIDE_LOAD]])
; CHECK-NEXT:    [[TMP7:%.*]] = fadd fast <vscale x 2 x double> [[TMP6]], shufflevector (<vscale x 2 x double> insertelement (<vscale x 2 x double> poison, double 1.000000e+00, i32 0), <vscale x 2 x double> poison, <vscale x 2 x i32> zeroinitializer)
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast double* [[TMP4]] to <vscale x 2 x double>*
; CHECK-NEXT:    store <vscale x 2 x double> [[TMP7]], <vscale x 2 x double>* [[TMP8]], align 8
; CHECK-NEXT:    [[TMP9:%.*]] = call i64 @llvm.vscale.i64()
; CHECK-NEXT:    [[TMP10:%.*]] = shl i64 [[TMP9]], 1
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], [[TMP10]]
; CHECK-NEXT:    [[TMP11:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP11]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP18:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N_MOD_VF]], 0
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_END_LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[FOR_BODY_PREHEADER]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[IV_NEXT:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds double, double* [[A]], i64 [[IV]]
; CHECK-NEXT:    [[TMP12:%.*]] = load double, double* [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[TMP13:%.*]] = call fast double @llvm.sin.f64(double [[TMP12]]) #[[ATTR7:[0-9]+]]
; CHECK-NEXT:    [[ADD:%.*]] = fadd fast double [[TMP13]], 1.000000e+00
; CHECK-NEXT:    store double [[ADD]], double* [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[IV_NEXT]] = add nuw nsw i64 [[IV]], 1
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[IV_NEXT]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_END_LOOPEXIT]], label [[FOR_BODY]], !llvm.loop [[LOOP19:![0-9]+]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %cmp7 = icmp sgt i64 %N, 0
  br i1 %cmp7, label %for.body, label %for.end

for.body:
  %iv = phi i64 [ 0, %entry ], [ %iv.next, %for.body ]
  %arrayidx = getelementptr inbounds double, double* %a, i64 %iv
  %0 = load double, double* %arrayidx, align 8
  %1 = call fast double @llvm.sin.f64(double %0) #2
  %add = fadd fast double %1, 1.000000e+00
  store double %add, double* %arrayidx, align 8
  %iv.next = add nuw nsw i64 %iv, 1
  %exitcond = icmp eq i64 %iv.next, %N
  br i1 %exitcond, label %for.end, label %for.body, !llvm.loop !1

for.end:
  ret void
}

; CHECK-REMARKS: UserVF ignored because of invalid costs.
; CHECK-REMARKS-NEXT: t.c:3:10: Instruction with invalid costs prevented vectorization at VF=(vscale x 1): load
; CHECK-REMARKS-NEXT: t.c:3:20: Instruction with invalid costs prevented vectorization at VF=(vscale x 1, vscale x 2): call to llvm.sin.f32
; CHECK-REMARKS-NEXT: t.c:3:30: Instruction with invalid costs prevented vectorization at VF=(vscale x 1): store
define void @vec_sin_no_mapping(float* noalias nocapture %dst, float* noalias nocapture readonly %src, i64 %n) {
; CHECK-LABEL: @vec_sin_no_mapping(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[N:%.*]], 2
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_VEC:%.*]] = and i64 [[N]], -2
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr inbounds float, float* [[SRC:%.*]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast float* [[TMP0]] to <2 x float>*, !dbg [[DBG20:![0-9]+]]
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <2 x float>, <2 x float>* [[TMP1]], align 4, !dbg [[DBG20]]
; CHECK-NEXT:    [[TMP2:%.*]] = call fast <2 x float> @llvm.sin.v2f32(<2 x float> [[WIDE_LOAD]]), !dbg [[DBG23:![0-9]+]]
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds float, float* [[DST:%.*]], i64 [[INDEX]]
; CHECK-NEXT:    [[TMP4:%.*]] = bitcast float* [[TMP3]] to <2 x float>*, !dbg [[DBG24:![0-9]+]]
; CHECK-NEXT:    store <2 x float> [[TMP2]], <2 x float>* [[TMP4]], align 4, !dbg [[DBG24]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 2
; CHECK-NEXT:    [[TMP5:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP5]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP25:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[N_VEC]], [[N]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[N_VEC]], [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[I_07:%.*]] = phi i64 [ [[INC:%.*]], [[FOR_BODY]] ], [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds float, float* [[SRC]], i64 [[I_07]]
; CHECK-NEXT:    [[TMP6:%.*]] = load float, float* [[ARRAYIDX]], align 4, !dbg [[DBG20]]
; CHECK-NEXT:    [[TMP7:%.*]] = tail call fast float @llvm.sin.f32(float [[TMP6]]), !dbg [[DBG23]]
; CHECK-NEXT:    [[ARRAYIDX1:%.*]] = getelementptr inbounds float, float* [[DST]], i64 [[I_07]]
; CHECK-NEXT:    store float [[TMP7]], float* [[ARRAYIDX1]], align 4, !dbg [[DBG24]]
; CHECK-NEXT:    [[INC]] = add nuw nsw i64 [[I_07]], 1
; CHECK-NEXT:    [[EXITCOND_NOT:%.*]] = icmp eq i64 [[INC]], [[N]]
; CHECK-NEXT:    br i1 [[EXITCOND_NOT]], label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], !llvm.loop [[LOOP26:![0-9]+]]
; CHECK:       for.cond.cleanup:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %i.07 = phi i64 [ %inc, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds float, float* %src, i64 %i.07
  %0 = load float, float* %arrayidx, align 4, !dbg !11
  %1 = tail call fast float @llvm.sin.f32(float %0), !dbg !12
  %arrayidx1 = getelementptr inbounds float, float* %dst, i64 %i.07
  store float %1, float* %arrayidx1, align 4, !dbg !13
  %inc = add nuw nsw i64 %i.07, 1
  %exitcond.not = icmp eq i64 %inc, %n
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !1

for.cond.cleanup:                                 ; preds = %for.body
  ret void
}

; CHECK-REMARKS: UserVF ignored because of invalid costs.
; CHECK-REMARKS-NEXT: t.c:3:10: Instruction with invalid costs prevented vectorization at VF=(vscale x 1): load
; CHECK-REMARKS-NEXT: t.c:3:30: Instruction with invalid costs prevented vectorization at VF=(vscale x 1, vscale x 2): call to llvm.sin.f32
; CHECK-REMARKS-NEXT: t.c:3:20: Instruction with invalid costs prevented vectorization at VF=(vscale x 1, vscale x 2): call to llvm.sin.f32
; CHECK-REMARKS-NEXT: t.c:3:40: Instruction with invalid costs prevented vectorization at VF=(vscale x 1): store
define void @vec_sin_no_mapping_ite(float* noalias nocapture %dst, float* noalias nocapture readonly %src, i64 %n) {
entry:
  br label %for.body

for.body:                                         ; preds = %entry, %if.end
  %i.07 = phi i64 [ %inc, %if.end ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds float, float* %src, i64 %i.07
  %0 = load float, float* %arrayidx, align 4, !dbg !11
  %cmp = fcmp ugt float %0, 0.0000
  br i1 %cmp, label %if.then, label %if.else
if.then:
  %1 = tail call fast float @llvm.sin.f32(float %0), !dbg !12
  br label %if.end
if.else:
  %2 = tail call fast float @llvm.sin.f32(float 0.0), !dbg !13
  br label %if.end
if.end:
  %3 = phi float [%1, %if.then], [%2, %if.else]
  %arrayidx1 = getelementptr inbounds float, float* %dst, i64 %i.07
  store float %3, float* %arrayidx1, align 4, !dbg !14
  %inc = add nuw nsw i64 %i.07, 1
  %exitcond.not = icmp eq i64 %inc, %n
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !1

for.cond.cleanup:                                 ; preds = %for.body
  ret void
}

; CHECK-REMARKS: UserVF ignored because of invalid costs.
; CHECK-REMARKS-NEXT: t.c:3:10: Instruction with invalid costs prevented vectorization at VF=(vscale x 1): load
; CHECK-REMARKS-NEXT: t.c:3:20: Instruction with invalid costs prevented vectorization at VF=(vscale x 1, vscale x 2): call to llvm.sin.f32
; CHECK-REMARKS-NEXT: t.c:3:30: Instruction with invalid costs prevented vectorization at VF=(vscale x 1): store
define void @vec_sin_fixed_mapping(float* noalias nocapture %dst, float* noalias nocapture readonly %src, i64 %n) {
entry:
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %i.07 = phi i64 [ %inc, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds float, float* %src, i64 %i.07
  %0 = load float, float* %arrayidx, align 4, !dbg !11
  %1 = tail call fast float @llvm.sin.f32(float %0) #3, !dbg !12
  %arrayidx1 = getelementptr inbounds float, float* %dst, i64 %i.07
  store float %1, float* %arrayidx1, align 4, !dbg !13
  %inc = add nuw nsw i64 %i.07, 1
  %exitcond.not = icmp eq i64 %inc, %n
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !1

for.cond.cleanup:                                 ; preds = %for.body
  ret void
}

; Even though there are no function mappings attached to the call
; in the loop below we can still vectorize the loop because SVE has
; hardware support in the form of the 'fqsrt' instruction.
define void @vec_sqrt_no_mapping(float* noalias nocapture %dst, float* noalias nocapture readonly %src, i64 %n) #0 {
entry:
  br label %for.body

for.body:                                         ; preds = %entry, %for.body
  %i.07 = phi i64 [ %inc, %for.body ], [ 0, %entry ]
  %arrayidx = getelementptr inbounds float, float* %src, i64 %i.07
  %0 = load float, float* %arrayidx, align 4
  %1 = tail call fast float @llvm.sqrt.f32(float %0)
  %arrayidx1 = getelementptr inbounds float, float* %dst, i64 %i.07
  store float %1, float* %arrayidx1, align 4
  %inc = add nuw nsw i64 %i.07, 1
  %exitcond.not = icmp eq i64 %inc, %n
  br i1 %exitcond.not, label %for.cond.cleanup, label %for.body, !llvm.loop !1

for.cond.cleanup:                                 ; preds = %for.body
  ret void
}


declare double @foo(double)
declare i64 @bar(i64*)
declare double @llvm.sin.f64(double)
declare float @llvm.sin.f32(float)
declare float @llvm.sqrt.f32(float)

declare <vscale x 2 x double> @foo_vec(<vscale x 2 x double>)
declare <vscale x 2 x i64> @bar_vec(<vscale x 2 x i64*>)
declare <vscale x 2 x double> @sin_vec_nxv2f64(<vscale x 2 x double>)
declare <2 x double> @sin_vec_v2f64(<2 x double>)

attributes #0 = { "vector-function-abi-variant"="_ZGV_LLVM_Nxv_foo(foo_vec)" }
attributes #1 = { "vector-function-abi-variant"="_ZGV_LLVM_Nxv_bar(bar_vec)" }
attributes #2 = { "vector-function-abi-variant"="_ZGV_LLVM_Nxv_llvm.sin.f64(sin_vec_nxv2f64)" }
attributes #3 = { "vector-function-abi-variant"="_ZGV_LLVM_N2v_llvm.sin.f64(sin_vec_v2f64)" }

!1 = distinct !{!1, !2, !3}
!2 = !{!"llvm.loop.vectorize.width", i32 2}
!3 = !{!"llvm.loop.vectorize.scalable.enable", i1 true}

!llvm.dbg.cu = !{!4}
!llvm.module.flags = !{!7}
!llvm.ident = !{!8}

!4 = distinct !DICompileUnit(language: DW_LANG_C99, file: !5, producer: "clang", isOptimized: true, runtimeVersion: 0, emissionKind: NoDebug, enums: !6, splitDebugInlining: false, nameTableKind: None)
!5 = !DIFile(filename: "t.c", directory: "somedir")
!6 = !{}
!7 = !{i32 2, !"Debug Info Version", i32 3}
!8 = !{!"clang"}
!9 = distinct !DISubprogram(name: "foo", scope: !5, file: !5, line: 2, type: !10, scopeLine: 2, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !4, retainedNodes: !6)
!10 = !DISubroutineType(types: !6)
!11 = !DILocation(line: 3, column: 10, scope: !9)
!12 = !DILocation(line: 3, column: 20, scope: !9)
!13 = !DILocation(line: 3, column: 30, scope: !9)
!14 = !DILocation(line: 3, column: 40, scope: !9)
