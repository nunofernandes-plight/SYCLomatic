//===--------------- APINamesTemplateType.inc -----------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

TYPE_REWRITE_ENTRY(
    "cuda::atomic",
        TYPE_CONDITIONAL_FACTORY(
        CheckTemplateArgCount(2),
        TYPE_FACTORY(STR(MapNames::getDpctNamespace() + "atomic"),
                     TEMPLATE_ARG(0),
                     TEMPLATE_ARG(1),
                     STR(MapNames::getClNamespace() + "memory_order::relaxed")),
        TYPE_FACTORY(STR(MapNames::getDpctNamespace() + "atomic"),
                     TEMPLATE_ARG(0))))

TYPE_REWRITE_ENTRY(
    "cuda::std::atomic",
    TYPE_CONDITIONAL_FACTORY(
        CheckTemplateArgCount(2),
        TYPE_FACTORY(STR(MapNames::getDpctNamespace() + "atomic"),
                     TEMPLATE_ARG(0),
                     TEMPLATE_ARG(1),
                     STR(MapNames::getClNamespace() + "memory_order::relaxed")),
        TYPE_FACTORY(STR(MapNames::getDpctNamespace() + "atomic"),
                     TEMPLATE_ARG(0))))

TYPE_REWRITE_ENTRY(
    "thrust::not_equal_to",
    TYPE_FACTORY(STR("std::not_equal_to"), TEMPLATE_ARG(0)))

FEATURE_REQUEST_FACTORY(HelperFeatureEnum::DplExtrasIterators_constant_iterator,
TYPE_REWRITE_ENTRY(
    "thrust::constant_iterator",
    TYPE_FACTORY(STR(MapNames::getDpctNamespace() + "constant_iterator"),
                     TEMPLATE_ARG(0))))

TYPE_REWRITE_ENTRY(
    "cub::CountingInputIterator",
    HEADER_INSERTION_FACTORY(HeaderType::HT_DPL_Iterator,
                             TYPE_FACTORY(STR("oneapi::dpl::counting_iterator"),
                                          TEMPLATE_ARG(0))))

TYPE_REWRITE_ENTRY("cub::TransformInputIterator",
                   HEADER_INSERTION_FACTORY(
                       HeaderType::HT_DPL_Iterator,
                       TYPE_FACTORY(STR("oneapi::dpl::transform_iterator"),
                                    TEMPLATE_ARG(2), TEMPLATE_ARG(1))))