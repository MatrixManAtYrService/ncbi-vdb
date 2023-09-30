{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    ,
    }:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      rec {
        packages = rec {
          ncbi-vdb = pkgs.stdenv.mkDerivation {
            name = "ncbi-vdb";
            src = self;

            nativeBuildInputs = [
              pkgs.cmake
              pkgs.perl
              pkgs.mbedtls
              pkgs.flex
              pkgs.bison
              pkgs.python3
              pkgs.doxygen
              pkgs.which
            ];

            configurePhase = ''
              ./configure --build-prefix=$out
               mkdir nixbuild
               cd nixbuild

               # use mbedtls from nixpkgs
               cmake -DCMAKE_INSTALL_PREFIX=$out -DHAVE_MBEDTLS_H=1 ..
            '';

            enableParallelBuilding = true;

            meta = {
              license = pkgs.lib.licenses.publicDomain;
              description = "The SRA Toolkit and SDK from NCBI is a collection of tools and libraries for using data in the INSDC Sequence Read Archives.  This project is a dependency of the SRA toolkit.";
            };
          };
          default = ncbi-vdb;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.cmake
            pkgs.perl
          ];
        };
      }
      );
}

