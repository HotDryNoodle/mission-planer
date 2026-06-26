#pragma once

#include "satellite/exit_codes.hpp"

namespace mp {

constexpr int EXIT_OK = satellite::EXIT_OK;
constexpr int EXIT_VALIDATION = satellite::EXIT_VALIDATION;
constexpr int EXIT_DEPENDENCY = satellite::EXIT_DEPENDENCY;
constexpr int EXIT_NO_RESULT = satellite::EXIT_NO_RESULT;
constexpr int EXIT_RETRYABLE = satellite::EXIT_RETRYABLE;
constexpr int EXIT_FATAL = satellite::EXIT_FATAL;
constexpr int EXIT_USAGE = satellite::EXIT_USAGE;

}  // namespace mp
