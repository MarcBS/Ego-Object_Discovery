
#define BOOST_FILESYSTEM_VERSION 3
#define BOOST_FILESYSTEM_NO_DEPRECATED 
#include <boost/filesystem.hpp>

namespace fs = ::boost::filesystem;

void get_all(const fs::path& root, const string& ext, vector<fs::path>& ret);