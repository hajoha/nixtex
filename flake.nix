{
  description = "LaTeX environment with SMILE and Awesome Beamer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05"; # Or the latest stable branch
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:

    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };

      smile = pkgs.stdenv.mkDerivation {
        pname = "smile";
        version = "unstable-2025-04-27";
        src = pkgs.fetchFromGitHub {
          owner = "hajoha";
          repo = "smile";
          rev = "master"; # Ideally pin to a real commit hash
          sha256 = "sha256-eVHH92ZhVN5P9ynskIWrhHqKPWGt7nL1k9BXWboyiDY="; # Update if rev changes
        };
        installPhase = ''
          install -Dm644 smile.sty $out/tex/latex/smile/smile.sty
        '';
      };

      awesome-beamer = pkgs.stdenv.mkDerivation {
        pname = "awesome-beamer";
        version = "unstable-2025-04-27";
        src = pkgs.fetchFromGitHub {
          owner = "hajoha";
          repo = "awesome-beamer";
          rev = "master"; # Ideally pin to a real commit hash
          sha256 = "sha256-7n66MYKvIlP3bu/v7XAzLNEIn5/QUyd7LuqtLKT1aJY="; # Update if rev changes
        };
        installPhase = ''
          install -Dm644 beamerthemeawesome.sty $out/tex/latex/awesome-beamer/beamerthemeawesome.sty
        '';
      };

      tex = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-basic;
        packages = with pkgs.texlive; [
          dvisvgm
          dvipng
          wrapfig
          amsmath
          ulem
          hyperref
          capt-of
          latexmk
          beamer
          luaotfload-main
        ];
      };
    in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            smile
            awesome-beamer
            tex
          ];

          shellHook = ''
            echo "Welcome to nixtex!"
            mkdir -p ./out
            touch main.tex
            alias compile='latexmk -pdf -pdflatex="pdflatex -interaction=nonstopmode -output-directory=./out" main.tex'
            alias clear='latexmk -CA && rm -rf ./out/* && rm -rf ./pkgs/'
          '';
        };
      });
}
