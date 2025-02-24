//==-------------------- device_global_map.hpp -----------------------------==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#pragma once

__SYCL_INLINE_NAMESPACE(cl) {
namespace sycl {
namespace detail {
namespace device_global_map {

__SYCL_EXPORT void add(const void *DeviceGlobalPtr, const char *UniqueId);

} // namespace device_global_map
} // namespace detail
} // namespace sycl
} // __SYCL_INLINE_NAMESPACE(cl)
