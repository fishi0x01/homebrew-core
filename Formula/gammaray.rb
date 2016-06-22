class Gammaray < Formula
  desc "Examine and manipulate Qt application internals at runtime"
  homepage "https://www.kdab.com/kdab-products/gammaray/"
  url "https://github.com/KDAB/GammaRay/releases/download/v2.4.1/gammaray-2.4.1.tar.gz"
  sha256 "08b151eaa4afeaaebc28eaae789f8da47d99012f1071f19d20d8d4d91115b6ab"
  head "https://github.com/KDAB/GammaRay.git"

  bottle do
    sha256 "c7f9d3e82f6267c1e50592e1942983eb5dbd555f12da1a7a71d5973ea3793035" => :el_capitan
    sha256 "149fcf14623364258624a74de84c1ab286ab7de0cc978dd83f3ddc8a2d39322b" => :yosemite
    sha256 "3ea0e2da59b8b73f0d51cc4b35f67f950ad06f7b00f0592efa4645e786c6ce5d" => :mavericks
    sha256 "1e11205cfd53296ea2a45f08d64c510bade4e910288202bb2d695e3511c9178e" => :mountain_lion
  end

  option "with-vtk", "Build with VTK-with-Qt support, for object 3D visualizer"
  option "with-test", "Verify the build with `make test`"

  needs :cxx11

  depends_on "cmake" => :build
  depends_on "qt5"
  depends_on "graphviz" => :recommended

  # VTK needs to have Qt support, and it needs to match GammaRay's
  depends_on "homebrew/science/vtk" => [:optional, "with-qt5"]

  def install
    # For Mountain Lion
    ENV.libcxx

    args = std_cmake_args
    args << "-DCMAKE_DISABLE_FIND_PACKAGE_VTK=" + ((build.without? "vtk") ? "ON" : "OFF")
    args << "-DCMAKE_DISABLE_FIND_PACKAGE_Graphviz=" + ((build.without? "graphviz") ? "ON" : "OFF")

    system "cmake", *args
    system "make"
    system "make", "test" if build.bottle? || build.with?("test")
    system "make", "install"
  end

  test do
    (prefix/"GammaRay.app/Contents/MacOS/gammaray").executable?
  end
end
