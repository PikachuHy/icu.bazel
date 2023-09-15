#include "assert.h"
#include "unicode/numfmt.h"
#include "unicode/unistr.h"
#include <iostream>
#include <unicode/ucnv.h>
int main() {
  auto name = ucnv_getDefaultName();
  std::cout << "name: " << name << std::endl;
  auto count = ucnv_countAvailable();
  std::cout << "count: " << count << std::endl;
  for (std::size_t i = 0; i < count; i++) {
    UErrorCode error{};
    auto name = ucnv_getAvailableName(i);
    auto alias_count = ucnv_countAliases(name, &error);
    if (U_FAILURE(error)) {
      std::cout << "FAILURE: " << std::string(u_errorName(error)) << std::endl;
      return 1;
    }
    for (std::size_t j = 0; j < alias_count; j++) {
      auto alias = ucnv_getAlias(name, j, &error);
      std::cout << j << ": " << alias << std::endl;
    }
  }
  return 0;
}