{ stdenv, requireFile, lib }:

let requireCLTool = version: sha256:
  let
    version' = lib.replaceStrings ["."] ["_"] version;
    dmg = "Command_Line_Tools_for_Xcode_${version'}.dmg";
    app = requireFile rec {
      name = "CommandLineTools";
      url = "https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_${version'}/Command_Line_Tools_for_Xcode_${version'}.dmg";
      hashMode = "recursive";
      inherit sha256;
      message  = ''
        Unfortunately, we cannot download ${name} automatically.
        Please go to ${url}
        to download it yourself, and add it to the Nix store by running the following commands.
        Note: download (~ 5GB), extraction and storing of Xcode will take a while

        nix-store --add-fixed --recursive sha256 /Library/Developer/CommandLineTools
      '';
    };
    meta = with stdenv.lib; {
      homepage = https://developer.apple.com/downloads/;
      description = "Apple's Command Line Tools for Xcode";
      license = licenses.unfree;
      platforms = platforms.darwin;
    };
  in app.overrideAttrs (oldAttrs : oldAttrs // { inherit meta; });

in lib.makeExtensible (self: {
  Command_Line_Tools_for_Xcode_11_2 = requireCLTool "11.2" "76ec9816dc26955c0d3d05cbd39b9500d18842ddd33a448c98fb896f1a917dc5";
  Command_Line_Tools_for_Xcode = self."Command_Line_Tools_for_Xcode_${lib.replaceStrings ["."] ["_"] (if stdenv.targetPlatform.useiOSPrebuilt then stdenv.targetPlatform.xcodeVer else "11.2")}";
})
