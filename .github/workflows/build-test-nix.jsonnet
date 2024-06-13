// This workflow builds and tests semgrep via nix!
local actions = import 'libs/actions.libsonnet';
local lib = import 'lib.libsonnet';

// ----------------------------------------------------------------------------
// The Workflow
// ----------------------------------------------------------------------------
local job = lib.os_matrix(
  oss=['ubuntu-latest', 'macos-latest'],
  steps=[
    lib.checkout_step,
    {
        name: "Set up Nix",
        uses: "DeterminateSystems/nix-installer-action@main",
    },
    {
        name: "Cache Nix",
        uses: "DeterminateSystems/magic-nix-cache-action@main"
    },
    {
        name: "Check Flake Validity",
        uses: "DeterminateSystems/flake-checker-action@main"
    },
    {
        name: "Build and Check Flake",
        run: "make nix-check-verbose"
    }
]);
{
  name: 'build-test-nix',
  on: lib.on_classic,
  jobs: {
    job: job,
  },
}
