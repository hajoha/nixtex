{
  description = "LaTeX environment with SMILE and Awesome Beamer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
          rev = "861b33e29e323abf2e2eb0faf9b9057948d231e8";
          sha256 = "sha256-eVHH92ZhVN5P9ynskIWrhHqKPWGt7nL1k9BXWboyiDY=";
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
          rev = "e1260b3f311e664c0d830481ce35c544e6aa28fd";
          sha256 = "sha256-7n66MYKvIlP3bu/v7XAzLNEIn5/QUyd7LuqtLKT1aJY=";
        };
        installPhase = ''
          install -Dm644 beamerthemeawesome.sty $out/tex/latex/awesome-beamer/beamerthemeawesome.sty
        '';
      };

      tex = pkgs.texlive.combine {
        inherit (pkgs.texlive)
          scheme-small
          tcolorbox
          beamer
          biber
          biblatex
          csquotes
          pgf
          tikzfill
          tikzpingus
          tikzmark
          fontspec
          firamath-otf
          firamath
          fira
          lualatex-math
          contour
          xcolor
          background
          emoji
          fontawesome5
          listings
          lstfiracode
          xstring
          listingsutf8
          lstaddons
          accsupp
          fancyqr
          pict2e
          qrcode
          bigfoot
          hyperxmp
          ifmtarg
          luacode
          latexmk
          hyperref
          kvoptions
          iftex
          stringenc
          pdftexcmds
          acronym
          adjustbox
          multirow
          threeparttable
          titlesec
          ieeetran
          algorithms
          svg
          transparent
          relsize
          pdfcrop
          pdfjam
          minted
          pdfpc;
      };

    in
    {
      fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "FiraCode" "FiraCode-Regular" "FiraCode-Bold" ]; })
      ];

      devShell = pkgs.mkShell {
        buildInputs = [
          tex
          smile
          awesome-beamer
          pkgs.python3Packages.pygments
        ];

        shellHook = ''
          echo "Welcome to nixtex!"
          mkdir -p ./out
          mkdir -p ./res
          mkdir -p ./fonts
          touch main.tex
          touch refs.bib
          export TEXINPUTS="${smile}/tex/latex/smile:${awesome-beamer}/tex/latex/awesome-beamer:"
          export TTFONTS="./fonts/FiraCode-Regular.ttf:./fonts/FiraCode-Bold.ttf:"

          alias compile='lualatex --shell-escape -interaction=nonstopmode -output-directory=./out main.tex || biber --input-directory=./out --output-directory=./out main || lualatex --shell-escape -interaction=nonstopmode -output-directory=./out main.tex || lualatex --shell-escape -interaction=nonstopmode -output-directory=./out main.tex'
          alias compile_talk='lualatex -interaction=nonstopmode -output-directory=./out talk.tex || biber --input-directory=./out --output-directory=./out main || lualatex -interaction=nonstopmode -output-directory=./out talk.tex || lualatex -interaction=nonstopmode -output-directory=./out talk.tex'

          alias compile_paper='pdflatex -interaction=nonstopmode -output-directory=./paper/out paper/paper.tex || bibtex ./paper/out/paper || pdflatex -interaction=nonstopmode -output-directory=./paper/out paper/paper.tex || pdflatex -interaction=nonstopmode -output-directory=./paper/out paper/paper.tex'

          alias count_words='pdftotext ./paper/out/paper.pdf - | egrep -e '\w\w\w+' | iconv -f ISO-8859-15 -t UTF-8 | wc -w'
          alias cleanup='latexmk -CA && rm -rf ./out/* && rm -rf ./pkgs/'
          wget https://www.static.tu.berlin/fileadmin/www/_processed_/b/9/csm_TUBerlin-ImagebilderOktober2019-PhilippArnoldtPhotography-115_bec3e1c6c1.jpg -nc -O ./res/uni.jpg
        '';
      };
    });
}