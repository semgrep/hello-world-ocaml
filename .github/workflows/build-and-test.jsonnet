local lib = import 'lib.libsonnet';

local opam_switch = '4.14.0';

// ----------------------------------------------------------------------------
// The job
// ----------------------------------------------------------------------------
// oses are: ubuntu, macos, windows
local job = lib.os_matrix(steps=
  [
    lib.checkout_step,
    // this must be done after the checkout as opam installs itself
    // locally in the project folder
    {
      uses: 'ocaml/setup-ocaml@v2',
      with: {
        'ocaml-compiler': opam_switch,
        //'opam-depext': true,
      },
    },
    lib.cache_opam.step(
      key=opam_switch + '-build-test-' + "${{ hashFiles('hello-world.opam') }}",
      path="_opam",
    ),
    {
      name: 'Install dependencies',
      // TODO: rely on opam depext?
      run: |||
        make update
      |||,
    },
    // alt: use `eval $(opam env)`, but this requires bash (windows pwsh fails),
    // and I get some PATH issue on Windows (need add CYGWIN_ROOT_BIN to PATH)
    // so simpler to use `opam exec ...`
    {
      name: 'Build',
      run: |||
         opam exec -- make
      |||,
    },
    {
      name: 'Test',
      run: |||
         opam exec -- make test
      |||,
    },
  ])
;

// ----------------------------------------------------------------------------
// The Workflow
// ----------------------------------------------------------------------------
{
  name: 'build-and-test',
  on: lib.on_classic,
  jobs: {
    job: job,
  },
}
