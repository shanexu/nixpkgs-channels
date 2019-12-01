{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  version = "0.5.2";
  pname = "jenv";
  src = fetchurl {
    url = "https://github.com/jenv/jenv/archive/${version}.tar.gz";
    sha256 = "4cdce828bfaeb6561733bab641ed2912107a8bc24758a17f2387ee78403afb9a";
  };
  buildPhase =
    ''
    outdir=$out/libexec
    mkdir -p $outdir
    cp -r * $outdir
    '';
  installPhase =
    ''
    mkdir $out/bin
    ln -s $outdir/libexec/jenv $out/bin/jenv;
    '';
  dontFixup = true;
  meta = with stdenv.lib; {
    description = "jEnv is an updated fork of jenv, a beloved Java environment manager adapted from rbenv.";
    longDescription =
      ''This is an updated fork of jenv, a beloved Java environment manager adapted from rbenv.

        jenv gives you a few critical affordances for using java on development machines:

          * It lets you switch between java versions. This is useful when developing Android applications, which generally require Java 8 for its tools, versus server applications, which use later versions like Java 11.
          * It sets JAVA_HOME inside your shell, in a way that can be set globally, local to the current working directory or per shell.

        However, this project does not:

          * Install java for you. Use your platform appropriate package manager to install java. On macOS, brew is recommended.
          * This document will show you how to install jenv, review its most common commands, show example workflows and identify known issues.
      '';
    homepage = http://www.jenv.be;
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
