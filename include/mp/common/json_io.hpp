#pragma once

#include "satellite/json_io.hpp"

namespace mp {

using Json = satellite::Json;

using satellite::read_json_file;
using satellite::read_json_input;
using satellite::read_json_stdin;
using satellite::read_text_file;
using satellite::utc_now_iso8601;
using satellite::write_json_file;
using satellite::write_json_stdout;
using satellite::write_text_file;

}  // namespace mp
