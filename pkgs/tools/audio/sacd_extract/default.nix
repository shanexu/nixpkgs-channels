{ stdenv, cmake, fetchurl, libiconv }:

stdenv.mkDerivation rec {
  pname = "sacd_extract";
  version = "0.3.8";
  nativeBuildInputs = [ cmake ];
  buildInputs = [ libiconv ];

  src = fetchurl {
    url = "https://github.com/sacd-ripper/sacd-ripper/archive/${version}.tar.gz";
    sha256 = "8c65c5fa518cb2c9d7c7221b6cd322ef1553341c6eb47bc670979e0eb7cefcce";
  };

  sourceRoot = "sacd-ripper-${version}/tools/${pname}";

  installPhase = ''
    install -D sacd_extract $out/bin/sacd_extract
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE='Release'"
  ];

  meta = with stdenv.lib; {
    description = "Extract DSD files from an SACD image";
    license = licenses.gpl2;
    platforms = platforms.all;
  };
}
