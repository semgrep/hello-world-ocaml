local lib = import 'lib.libsonnet';

local opam_switch = '5.2.0';

// ----------------------------------------------------------------------------
// The job
// ----------------------------------------------------------------------------
local job = {
  'runs-on': 'ubuntu-latest',
  steps: [
    lib.checkout_step,
    // this must be done after the checkout as opam installs itself
    // locally in the project folder
    {
      uses: 'ocaml/setup-ocaml@v2',
      with: {
        'ocaml-compiler': opam_switch,
        //'opam-depext': false,
      },
    },
    lib.cache_opam.step(
      key=opam_switch + '-build-test-' + "${{ hashFiles('hello-world.opam') }}",
      path="_opam",
    ),
    {
      name: 'Install dependencies',
      run: |||
        sudo make install-deps-UBUNTU
        make install-deps
      |||,
    },
    {
      name: 'Build',
      run: |||
        eval $(opam env)
        make
      |||,
    },
    {
      name: 'Test',
      run: |||
        eval $(opam env)
        make test
      |||,
    },
  ],
};

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
