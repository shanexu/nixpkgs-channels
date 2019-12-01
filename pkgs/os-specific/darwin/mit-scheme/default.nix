{ pkgs, stdenvNoCC, fetchurl, makeWrapper, gnum4, texinfo, texLive, automake, lib, macosVersion, xcodeVersion }:

let
  version = "9.2";
  xcode = pkgs.darwin."Command_Line_Tools_for_Xcode_${lib.replaceStrings ["."] ["_"] xcodeVersion}";
in
stdenvNoCC.mkDerivation {
  name = "mit-scheme-macos${lib.replaceStrings ["."] ["_"] macosVersion}-xcode${lib.replaceStrings ["."] ["_"] xcodeVersion}-${version}";

  # MIT/GNU Scheme is not bootstrappable, so it's recommended to compile from
  # the platform-specific tarballs, which contain pre-built binaries.  It
  # leads to more efficient code than when building the tarball that contains
  # generated C code instead of those binaries.
  src = fetchurl {
      url = "mirror://gnu/mit-scheme/stable.pkg/${version}/mit-scheme-c-${version}.tar.gz";
      sha256 = "0w5ib5vsidihb4hb6fma3sp596ykr8izagm57axvgd6lqzwicsjg";
    };

  buildInputs = [ xcode ];

  configurePhase = "(cd doc && ./configure)";

  buildPhase =
    '' export PATH=${xcode}/usr/bin:$PATH
       export CPATH=${xcode}/SDKs/MacOSX${macosVersion}.sdk/usr/include

       cd src
       for i in 6001/edextra.scm \
                6001/floppy.scm \
                compiler/etc/disload.scm \
                edwin/techinfo.scm \
                edwin/unix.scm \
                swat/c/tk3.2-custom/Makefile \
                swat/c/tk3.2-custom/tcl/Makefile \
                swat/scheme/other/btest.scm \
                microcode/configure
       do
           sed -i "s~/usr/local~$out~g" $i
       done
       sed -i 's/run_configure/run_configure --without-x --with-macosx-version=10.15/g' ./etc/make-liarc.sh
       ./etc/make-liarc.sh --prefix=$out

       cd ../doc

       # Provide a `texinfo.tex'.
       export TEXINPUTS="$(echo ${automake}/share/automake-*)"
       echo "\$TEXINPUTS is \`$TEXINPUTS'"
       make

       cd ..
    '';

  installPhase =
    '' make prefix=$out install -C src
       make prefix=$out install -C doc
    '';

  fixupPhase =
    '' wrapProgram $out/bin/mit-scheme-c --set MITSCHEME_LIBRARY_PATH \
         $out/lib/mit-scheme-c
    '';

  nativeBuildInputs = [ makeWrapper gnum4 texinfo texLive automake ];

  # XXX: The `check' target doesn't exist.
  doCheck = false;

  meta = with stdenvNoCC.lib; {
    description = "MIT/GNU Scheme, a native code Scheme compiler";

    longDescription =
      '' MIT/GNU Scheme is an implementation of the Scheme programming
         language, providing an interpreter, compiler, source-code debugger,
         integrated Emacs-like editor, and a large runtime library.  MIT/GNU
         Scheme is best suited to programming large applications with a rapid
         development cycle.
      '';

    homepage = https://www.gnu.org/software/mit-scheme/;

    license = licenses.gpl2Plus;

    maintainers = [ ];

    # Build fails on Cygwin and Darwin:
    # <http://article.gmane.org/gmane.lisp.scheme.mit-scheme.devel/489>.
    platforms = platforms.darwin;
  };
}
