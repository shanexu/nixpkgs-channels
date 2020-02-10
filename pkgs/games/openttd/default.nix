{ stdenv, fetchurl, fetchzip, pkgconfig, SDL, libpng, zlib, xz, freetype, fontconfig
, withOpenGFX ? true, withOpenSFX ? true, withOpenMSX ? true
, withFluidSynth ? true, audioDriver ? "alsa", fluidsynth, soundfont-fluid, procps
, writeScriptBin, makeWrapper, runtimeShell
}:

let
  opengfx = fetchzip {
    url = "https://binaries.openttd.org/extra/opengfx/0.5.5/opengfx-0.5.5-all.zip";
    sha256 = "065l0g5nawcd6fkfbsfgviwgq9610y7gxzkpmd19i423d0lrq6d8";
  };

  opensfx = fetchzip {
    url = "https://binaries.openttd.org/extra/opensfx/0.2.3/opensfx-0.2.3-all.zip";
    sha256 = "1bb167kszdd6dqbcdjrxxwab6b7y7jilhzi3qijdhprpm5gf1lp3";
  };

  openmsx = fetchzip {
    url = "https://binaries.openttd.org/extra/openmsx/0.3.1/openmsx-0.3.1-all.zip";
    sha256 = "0qnmfzz0v8vxrrvxnm7szphrlrlvhkwn3y92b4iy0b4b6yam0yd4";
  };

  playmidi = writeScriptBin "playmidi" ''
    #!${runtimeShell}
    trap "${procps}/bin/pkill fluidsynth" EXIT
    ${fluidsynth}/bin/fluidsynth -a ${audioDriver} -i ${soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2 $*
  '';

in
stdenv.mkDerivation rec {
  pname = "openttd";
  version = "1.9.3";

  src = fetchurl {
    url = "https://proxy.binaries.openttd.org/openttd-releases/${version}/${pname}-${version}-source.tar.xz";
    sha256 = "0ijq72kgx997ggw40i5f4a3nf7y2g72z37l47i18yjvgbdzy320r";
  };

  nativeBuildInputs = [ pkgconfig makeWrapper ];
  buildInputs = [ SDL libpng xz zlib freetype fontconfig ]
    ++ stdenv.lib.optionals withFluidSynth [ fluidsynth soundfont-fluid ];

  prefixKey = "--prefix-dir=";

  configureFlags = [
    "--without-liblzo2"
  ];

  makeFlags = [ "INSTALL_PERSONAL_DIR=" ];

  postInstall = ''
    mv $out/games/ $out/bin

    ${stdenv.lib.optionalString withOpenGFX ''
      cp ${opengfx}/* $out/share/games/openttd/baseset
    ''}

    mkdir -p $out/share/games/openttd/data

    ${stdenv.lib.optionalString withOpenSFX ''
      cp ${opensfx}/*.{obs,cat} $out/share/games/openttd/data
    ''}

    mkdir $out/share/games/openttd/baseset/openmsx

    ${stdenv.lib.optionalString withOpenMSX ''
      cp ${openmsx}/*.{obm,mid} $out/share/games/openttd/baseset/openmsx
    ''}

    ${stdenv.lib.optionalString withFluidSynth ''
      wrapProgram $out/bin/openttd \
        --add-flags -m \
        --add-flags extmidi:cmd=${playmidi}/bin/playmidi
    ''}
  '';

  meta = {
    description = ''Open source clone of the Microprose game "Transport Tycoon Deluxe"'';
    longDescription = ''
      OpenTTD is a transportation economics simulator. In single player mode,
      players control a transportation business, and use rail, road, sea, and air
      transport to move goods and people around the simulated world.

      In multiplayer networked mode, players may:
        - play competitively as different businesses
        - play cooperatively controlling the same business
        - observe as spectators
    '';
    homepage = https://www.openttd.org/;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ jcumming the-kenny fpletz ];
  };
}
