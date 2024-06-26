class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.1.42.tar.gz"
  sha256 "c4b0cf67a9d4873ac7724005a43585de9b10d36a0760e3a30c9e5a70316c424e"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "3ec7720e840dc320fd797fac01245a562b12f999c122acb89ffd6bba72bdf8a8"
    sha256 cellar: :any,                 arm64_ventura:  "f67435f0089dfc45101cbc01eefac04459efa0a10d36777356fbcdf0f0e9abdc"
    sha256 cellar: :any,                 arm64_monterey: "9d72787ddac8a30194a7ad9cf8d351c612c3556ba8510c99e0c41ec9cc3d98db"
    sha256 cellar: :any,                 sonoma:         "d50042cc21b9e0648f66e02749228ce65e4534eba4f8eb58d7c0f640ea1d399a"
    sha256 cellar: :any,                 ventura:        "28ec20b26bbdd2216d7bc23bf35116a0eb0385999d5a1162eeba67dfb93fedd0"
    sha256 cellar: :any,                 monterey:       "698308f53f1b985bab2c2205a214a7908915fb3f978bb974f060747e73563d07"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "25076bae98c99b5a10e46ebccbd07be2261c5b76f4fb07937b2db01d67580645"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libgit2"
  depends_on "openssl@3"

  uses_from_macos "python" => :test

  on_linux do
    # On macOS, bzip2-sys will use the bundled lib as it cannot find the system or brew lib.
    # We only ship bzip2.pc on Linux which bzip2-sys needs to find library.
    depends_on "bzip2"
  end

  def install
    ENV["LIBGIT2_NO_VENDOR"] = "1"

    # Ensure that the `openssl` crate picks up the intended library.
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix
    ENV["OPENSSL_NO_VENDOR"] = "1"

    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
  end

  def check_binary_linkage(binary, library)
    binary.dynamically_linked_libraries.any? do |dll|
      next false unless dll.start_with?(HOMEBREW_PREFIX.to_s)

      File.realpath(dll) == File.realpath(library)
    end
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    [
      Formula["libgit2"].opt_lib/shared_library("libgit2"),
      Formula["openssl@3"].opt_lib/shared_library("libssl"),
      Formula["openssl@3"].opt_lib/shared_library("libcrypto"),
    ].each do |library|
      assert check_binary_linkage(bin/"uv", library),
             "No linkage with #{library.basename}! Cargo is likely using a vendored version."
    end
  end
end
