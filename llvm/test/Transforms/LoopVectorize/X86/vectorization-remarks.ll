; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-vectorize -mtriple=x86_64-unknown-linux -S -pass-remarks='loop-vectorize' 2>&1 | FileCheck -check-prefix=VECTORIZED %s
; RUN: opt < %s -loop-vectorize -force-vector-width=1 -force-vector-interleave=4 -mtriple=x86_64-unknown-linux -S -pass-remarks='loop-vectorize' 2>&1 | FileCheck -check-prefix=UNROLLED %s
; RUN: opt < %s -loop-vectorize -force-vector-width=1 -force-vector-interleave=1 -mtriple=x86_64-unknown-linux -S -pass-remarks-analysis='loop-vectorize' 2>&1 | FileCheck -check-prefix=NONE %s

; RUN: llc < %s -mtriple x86_64-pc-linux-gnu -o - | FileCheck -check-prefix=DEBUG-OUTPUT %s
; DEBUG-OUTPUT-NOT: .loc
; DEBUG-OUTPUT-NOT: {{.*}}.debug_info

; VECTORIZED: remark: vectorization-remarks.c:17:8: vectorized loop (vectorization width: 4, interleaved count: 1)
; UNROLLED: remark: vectorization-remarks.c:17:8: interleaved loop (interleaved count: 4)
; NONE: remark: vectorization-remarks.c:17:8: loop not vectorized: vectorization and interleaving are explicitly disabled, or the loop has already been vectorized

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define i32 @foo(i32 %n) #0 !dbg !4 {
; VECTORIZED-LABEL: @foo(
; VECTORIZED-NEXT:  entry:
; VECTORIZED-NEXT:    [[DIFF:%.*]] = alloca i32, align 4
; VECTORIZED-NEXT:    [[CB:%.*]] = alloca [16 x i8], align 16
; VECTORIZED-NEXT:    [[CC:%.*]] = alloca [16 x i8], align 16
; VECTORIZED-NEXT:    store i32 0, i32* [[DIFF]], align 4, !dbg [[DBG8:![0-9]+]], !tbaa [[TBAA9:![0-9]+]]
; VECTORIZED-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]], !dbg [[DBG13:![0-9]+]]
; VECTORIZED:       vector.ph:
; VECTORIZED-NEXT:    br label [[VECTOR_BODY:%.*]], !dbg [[DBG13]]
; VECTORIZED:       vector.body:
; VECTORIZED-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ], !dbg [[DBG13]]
; VECTORIZED-NEXT:    [[VEC_PHI:%.*]] = phi <4 x i32> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP10:%.*]], [[VECTOR_BODY]] ]
; VECTORIZED-NEXT:    [[TMP0:%.*]] = add i64 [[INDEX]], 0
; VECTORIZED-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CB]], i64 0, i64 [[TMP0]], !dbg [[DBG17:![0-9]+]]
; VECTORIZED-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i8, i8* [[TMP1]], i32 0, !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[TMP3:%.*]] = bitcast i8* [[TMP2]] to <4 x i8>*, !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[WIDE_LOAD:%.*]] = load <4 x i8>, <4 x i8>* [[TMP3]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19:![0-9]+]]
; VECTORIZED-NEXT:    [[TMP4:%.*]] = sext <4 x i8> [[WIDE_LOAD]] to <4 x i32>, !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[TMP5:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CC]], i64 0, i64 [[TMP0]], !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[TMP6:%.*]] = getelementptr inbounds i8, i8* [[TMP5]], i32 0, !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[TMP7:%.*]] = bitcast i8* [[TMP6]] to <4 x i8>*, !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[WIDE_LOAD1:%.*]] = load <4 x i8>, <4 x i8>* [[TMP7]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; VECTORIZED-NEXT:    [[TMP8:%.*]] = sext <4 x i8> [[WIDE_LOAD1]] to <4 x i32>, !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[TMP9:%.*]] = sub <4 x i32> [[TMP4]], [[TMP8]], !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[TMP10]] = add <4 x i32> [[TMP9]], [[VEC_PHI]], !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4, !dbg [[DBG13]]
; VECTORIZED-NEXT:    [[TMP11:%.*]] = icmp eq i64 [[INDEX_NEXT]], 16, !dbg [[DBG13]]
; VECTORIZED-NEXT:    br i1 [[TMP11]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !dbg [[DBG13]], !llvm.loop [[LOOP20:![0-9]+]]
; VECTORIZED:       middle.block:
; VECTORIZED-NEXT:    [[TMP12:%.*]] = call i32 @llvm.vector.reduce.add.v4i32(<4 x i32> [[TMP10]]), !dbg [[DBG13]]
; VECTORIZED-NEXT:    [[CMP_N:%.*]] = icmp eq i64 16, 16, !dbg [[DBG13]]
; VECTORIZED-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[SCALAR_PH]], !dbg [[DBG13]]
; VECTORIZED:       scalar.ph:
; VECTORIZED-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 16, [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; VECTORIZED-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[TMP12]], [[MIDDLE_BLOCK]] ]
; VECTORIZED-NEXT:    br label [[FOR_BODY:%.*]], !dbg [[DBG13]]
; VECTORIZED:       for.body:
; VECTORIZED-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; VECTORIZED-NEXT:    [[ADD8:%.*]] = phi i32 [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ], [ [[ADD:%.*]], [[FOR_BODY]] ], !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CB]], i64 0, i64 [[INDVARS_IV]], !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[TMP13:%.*]] = load i8, i8* [[ARRAYIDX]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; VECTORIZED-NEXT:    [[CONV:%.*]] = sext i8 [[TMP13]] to i32, !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CC]], i64 0, i64 [[INDVARS_IV]], !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[TMP14:%.*]] = load i8, i8* [[ARRAYIDX2]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; VECTORIZED-NEXT:    [[CONV3:%.*]] = sext i8 [[TMP14]] to i32, !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[SUB:%.*]] = sub i32 [[CONV]], [[CONV3]], !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[ADD]] = add nsw i32 [[SUB]], [[ADD8]], !dbg [[DBG17]]
; VECTORIZED-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1, !dbg [[DBG13]]
; VECTORIZED-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 16, !dbg [[DBG13]]
; VECTORIZED-NEXT:    br i1 [[EXITCOND]], label [[FOR_END]], label [[FOR_BODY]], !dbg [[DBG13]], !llvm.loop [[LOOP22:![0-9]+]]
; VECTORIZED:       for.end:
; VECTORIZED-NEXT:    [[ADD_LCSSA:%.*]] = phi i32 [ [[ADD]], [[FOR_BODY]] ], [ [[TMP12]], [[MIDDLE_BLOCK]] ], !dbg [[DBG17]]
; VECTORIZED-NEXT:    store i32 [[ADD_LCSSA]], i32* [[DIFF]], align 4, !dbg [[DBG17]], !tbaa [[TBAA9]]
; VECTORIZED-NEXT:    call void @ibar(i32* [[DIFF]]), !dbg [[DBG24:![0-9]+]]
; VECTORIZED-NEXT:    ret i32 0, !dbg [[DBG25:![0-9]+]]
;
; UNROLLED-LABEL: @foo(
; UNROLLED-NEXT:  entry:
; UNROLLED-NEXT:    [[DIFF:%.*]] = alloca i32, align 4
; UNROLLED-NEXT:    [[CB:%.*]] = alloca [16 x i8], align 16
; UNROLLED-NEXT:    [[CC:%.*]] = alloca [16 x i8], align 16
; UNROLLED-NEXT:    store i32 0, i32* [[DIFF]], align 4, !dbg [[DBG8:![0-9]+]], !tbaa [[TBAA9:![0-9]+]]
; UNROLLED-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]], !dbg [[DBG13:![0-9]+]]
; UNROLLED:       vector.ph:
; UNROLLED-NEXT:    br label [[VECTOR_BODY:%.*]], !dbg [[DBG13]]
; UNROLLED:       vector.body:
; UNROLLED-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ], !dbg [[DBG13]]
; UNROLLED-NEXT:    [[VEC_PHI:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[TMP28:%.*]], [[VECTOR_BODY]] ]
; UNROLLED-NEXT:    [[VEC_PHI1:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[TMP29:%.*]], [[VECTOR_BODY]] ]
; UNROLLED-NEXT:    [[VEC_PHI2:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[TMP30:%.*]], [[VECTOR_BODY]] ]
; UNROLLED-NEXT:    [[VEC_PHI3:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[TMP31:%.*]], [[VECTOR_BODY]] ]
; UNROLLED-NEXT:    [[INDUCTION:%.*]] = add i64 [[INDEX]], 0
; UNROLLED-NEXT:    [[INDUCTION4:%.*]] = add i64 [[INDEX]], 1
; UNROLLED-NEXT:    [[INDUCTION5:%.*]] = add i64 [[INDEX]], 2
; UNROLLED-NEXT:    [[INDUCTION6:%.*]] = add i64 [[INDEX]], 3
; UNROLLED-NEXT:    [[TMP0:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CB]], i64 0, i64 [[INDUCTION]], !dbg [[DBG17:![0-9]+]]
; UNROLLED-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CB]], i64 0, i64 [[INDUCTION4]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CB]], i64 0, i64 [[INDUCTION5]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CB]], i64 0, i64 [[INDUCTION6]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP4:%.*]] = load i8, i8* [[TMP0]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19:![0-9]+]]
; UNROLLED-NEXT:    [[TMP5:%.*]] = load i8, i8* [[TMP1]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[TMP6:%.*]] = load i8, i8* [[TMP2]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[TMP7:%.*]] = load i8, i8* [[TMP3]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[TMP8:%.*]] = sext i8 [[TMP4]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP9:%.*]] = sext i8 [[TMP5]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP10:%.*]] = sext i8 [[TMP6]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP11:%.*]] = sext i8 [[TMP7]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP12:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CC]], i64 0, i64 [[INDUCTION]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP13:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CC]], i64 0, i64 [[INDUCTION4]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP14:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CC]], i64 0, i64 [[INDUCTION5]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP15:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CC]], i64 0, i64 [[INDUCTION6]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP16:%.*]] = load i8, i8* [[TMP12]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[TMP17:%.*]] = load i8, i8* [[TMP13]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[TMP18:%.*]] = load i8, i8* [[TMP14]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[TMP19:%.*]] = load i8, i8* [[TMP15]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[TMP20:%.*]] = sext i8 [[TMP16]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP21:%.*]] = sext i8 [[TMP17]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP22:%.*]] = sext i8 [[TMP18]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP23:%.*]] = sext i8 [[TMP19]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP24:%.*]] = sub i32 [[TMP8]], [[TMP20]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP25:%.*]] = sub i32 [[TMP9]], [[TMP21]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP26:%.*]] = sub i32 [[TMP10]], [[TMP22]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP27:%.*]] = sub i32 [[TMP11]], [[TMP23]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP28]] = add i32 [[TMP24]], [[VEC_PHI]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP29]] = add i32 [[TMP25]], [[VEC_PHI1]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP30]] = add i32 [[TMP26]], [[VEC_PHI2]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP31]] = add i32 [[TMP27]], [[VEC_PHI3]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 4, !dbg [[DBG13]]
; UNROLLED-NEXT:    [[TMP32:%.*]] = icmp eq i64 [[INDEX_NEXT]], 16, !dbg [[DBG13]]
; UNROLLED-NEXT:    br i1 [[TMP32]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !dbg [[DBG13]], !llvm.loop [[LOOP20:![0-9]+]]
; UNROLLED:       middle.block:
; UNROLLED-NEXT:    [[BIN_RDX:%.*]] = add i32 [[TMP29]], [[TMP28]], !dbg [[DBG13]]
; UNROLLED-NEXT:    [[BIN_RDX7:%.*]] = add i32 [[TMP30]], [[BIN_RDX]], !dbg [[DBG13]]
; UNROLLED-NEXT:    [[BIN_RDX8:%.*]] = add i32 [[TMP31]], [[BIN_RDX7]], !dbg [[DBG13]]
; UNROLLED-NEXT:    [[CMP_N:%.*]] = icmp eq i64 16, 16, !dbg [[DBG13]]
; UNROLLED-NEXT:    br i1 [[CMP_N]], label [[FOR_END:%.*]], label [[SCALAR_PH]], !dbg [[DBG13]]
; UNROLLED:       scalar.ph:
; UNROLLED-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ 16, [[MIDDLE_BLOCK]] ], [ 0, [[ENTRY:%.*]] ]
; UNROLLED-NEXT:    [[BC_MERGE_RDX:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[BIN_RDX8]], [[MIDDLE_BLOCK]] ]
; UNROLLED-NEXT:    br label [[FOR_BODY:%.*]], !dbg [[DBG13]]
; UNROLLED:       for.body:
; UNROLLED-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; UNROLLED-NEXT:    [[ADD8:%.*]] = phi i32 [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ], [ [[ADD:%.*]], [[FOR_BODY]] ], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CB]], i64 0, i64 [[INDVARS_IV]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP33:%.*]] = load i8, i8* [[ARRAYIDX]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[CONV:%.*]] = sext i8 [[TMP33]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CC]], i64 0, i64 [[INDVARS_IV]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[TMP34:%.*]] = load i8, i8* [[ARRAYIDX2]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; UNROLLED-NEXT:    [[CONV3:%.*]] = sext i8 [[TMP34]] to i32, !dbg [[DBG17]]
; UNROLLED-NEXT:    [[SUB:%.*]] = sub i32 [[CONV]], [[CONV3]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[ADD]] = add nsw i32 [[SUB]], [[ADD8]], !dbg [[DBG17]]
; UNROLLED-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1, !dbg [[DBG13]]
; UNROLLED-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 16, !dbg [[DBG13]]
; UNROLLED-NEXT:    br i1 [[EXITCOND]], label [[FOR_END]], label [[FOR_BODY]], !dbg [[DBG13]], !llvm.loop [[LOOP22:![0-9]+]]
; UNROLLED:       for.end:
; UNROLLED-NEXT:    [[ADD_LCSSA:%.*]] = phi i32 [ [[ADD]], [[FOR_BODY]] ], [ [[BIN_RDX8]], [[MIDDLE_BLOCK]] ], !dbg [[DBG17]]
; UNROLLED-NEXT:    store i32 [[ADD_LCSSA]], i32* [[DIFF]], align 4, !dbg [[DBG17]], !tbaa [[TBAA9]]
; UNROLLED-NEXT:    call void @ibar(i32* [[DIFF]]), !dbg [[DBG23:![0-9]+]]
; UNROLLED-NEXT:    ret i32 0, !dbg [[DBG24:![0-9]+]]
;
; NONE-LABEL: @foo(
; NONE-NEXT:  entry:
; NONE-NEXT:    [[DIFF:%.*]] = alloca i32, align 4
; NONE-NEXT:    [[CB:%.*]] = alloca [16 x i8], align 16
; NONE-NEXT:    [[CC:%.*]] = alloca [16 x i8], align 16
; NONE-NEXT:    store i32 0, i32* [[DIFF]], align 4, !dbg [[DBG8:![0-9]+]], !tbaa [[TBAA9:![0-9]+]]
; NONE-NEXT:    br label [[FOR_BODY:%.*]], !dbg [[DBG13:![0-9]+]]
; NONE:       for.body:
; NONE-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; NONE-NEXT:    [[ADD8:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[ADD:%.*]], [[FOR_BODY]] ], !dbg [[DBG17:![0-9]+]]
; NONE-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CB]], i64 0, i64 [[INDVARS_IV]], !dbg [[DBG17]]
; NONE-NEXT:    [[TMP0:%.*]] = load i8, i8* [[ARRAYIDX]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19:![0-9]+]]
; NONE-NEXT:    [[CONV:%.*]] = sext i8 [[TMP0]] to i32, !dbg [[DBG17]]
; NONE-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds [16 x i8], [16 x i8]* [[CC]], i64 0, i64 [[INDVARS_IV]], !dbg [[DBG17]]
; NONE-NEXT:    [[TMP1:%.*]] = load i8, i8* [[ARRAYIDX2]], align 1, !dbg [[DBG17]], !tbaa [[TBAA19]]
; NONE-NEXT:    [[CONV3:%.*]] = sext i8 [[TMP1]] to i32, !dbg [[DBG17]]
; NONE-NEXT:    [[SUB:%.*]] = sub i32 [[CONV]], [[CONV3]], !dbg [[DBG17]]
; NONE-NEXT:    [[ADD]] = add nsw i32 [[SUB]], [[ADD8]], !dbg [[DBG17]]
; NONE-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1, !dbg [[DBG13]]
; NONE-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 16, !dbg [[DBG13]]
; NONE-NEXT:    br i1 [[EXITCOND]], label [[FOR_END:%.*]], label [[FOR_BODY]], !dbg [[DBG13]]
; NONE:       for.end:
; NONE-NEXT:    [[ADD_LCSSA:%.*]] = phi i32 [ [[ADD]], [[FOR_BODY]] ], !dbg [[DBG17]]
; NONE-NEXT:    store i32 [[ADD_LCSSA]], i32* [[DIFF]], align 4, !dbg [[DBG17]], !tbaa [[TBAA9]]
; NONE-NEXT:    call void @ibar(i32* [[DIFF]]), !dbg [[DBG20:![0-9]+]]
; NONE-NEXT:    ret i32 0, !dbg [[DBG21:![0-9]+]]
;
entry:
  %diff = alloca i32, align 4
  %cb = alloca [16 x i8], align 16
  %cc = alloca [16 x i8], align 16
  store i32 0, i32* %diff, align 4, !dbg !10, !tbaa !11
  br label %for.body, !dbg !15

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %add8 = phi i32 [ 0, %entry ], [ %add, %for.body ], !dbg !19
  %arrayidx = getelementptr inbounds [16 x i8], [16 x i8]* %cb, i64 0, i64 %indvars.iv, !dbg !19
  %0 = load i8, i8* %arrayidx, align 1, !dbg !19, !tbaa !21
  %conv = sext i8 %0 to i32, !dbg !19
  %arrayidx2 = getelementptr inbounds [16 x i8], [16 x i8]* %cc, i64 0, i64 %indvars.iv, !dbg !19
  %1 = load i8, i8* %arrayidx2, align 1, !dbg !19, !tbaa !21
  %conv3 = sext i8 %1 to i32, !dbg !19
  %sub = sub i32 %conv, %conv3, !dbg !19
  %add = add nsw i32 %sub, %add8, !dbg !19
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1, !dbg !15
  %exitcond = icmp eq i64 %indvars.iv.next, 16, !dbg !15
  br i1 %exitcond, label %for.end, label %for.body, !dbg !15

for.end:                                          ; preds = %for.body
  store i32 %add, i32* %diff, align 4, !dbg !19, !tbaa !11
  call void @ibar(i32* %diff) #2, !dbg !22
  ret i32 0, !dbg !23
}

declare void @ibar(i32*) #1

!llvm.module.flags = !{!7, !8}
!llvm.ident = !{!9}
!llvm.dbg.cu = !{!24}

!1 = !DIFile(filename: "vectorization-remarks.c", directory: ".")
!2 = !{}
!3 = !{!4}
!4 = distinct !DISubprogram(name: "foo", line: 5, isLocal: false, isDefinition: true, virtualIndex: 6, flags: DIFlagPrototyped, isOptimized: true, unit: !24, scopeLine: 6, file: !1, scope: !5, type: !6, retainedNodes: !2)
!5 = !DIFile(filename: "vectorization-remarks.c", directory: ".")
!6 = !DISubroutineType(types: !2)
!7 = !{i32 2, !"Dwarf Version", i32 4}
!8 = !{i32 1, !"Debug Info Version", i32 3}
!9 = !{!"clang version 3.5.0 "}
!10 = !DILocation(line: 8, column: 3, scope: !4)
!11 = !{!12, !12, i64 0}
!12 = !{!"int", !13, i64 0}
!13 = !{!"omnipotent char", !14, i64 0}
!14 = !{!"Simple C/C++ TBAA"}
!15 = !DILocation(line: 17, column: 8, scope: !16)
!16 = distinct !DILexicalBlock(line: 17, column: 8, file: !1, scope: !17)
!17 = distinct !DILexicalBlock(line: 17, column: 8, file: !1, scope: !18)
!18 = distinct !DILexicalBlock(line: 17, column: 3, file: !1, scope: !4)
!19 = !DILocation(line: 18, column: 5, scope: !20)
!20 = distinct !DILexicalBlock(line: 17, column: 27, file: !1, scope: !18)
!21 = !{!13, !13, i64 0}
!22 = !DILocation(line: 20, column: 3, scope: !4)
!23 = !DILocation(line: 21, column: 3, scope: !4)
!24 = distinct !DICompileUnit(language: DW_LANG_C89, file: !1, emissionKind: NoDebug)
