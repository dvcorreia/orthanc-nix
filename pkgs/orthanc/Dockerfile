FROM nixos/nix:2.24.0

RUN nix-channel --update

COPY . .
RUN nix-build

