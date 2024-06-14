local lib = import 'lib.libsonnet';

local opam_switch = '4.14.0';

// ----------------------------------------------------------------------------
// The job
// ----------------------------------------------------------------------------
// oses in the matrix are: ubuntu-latest, macos-latest, and windows-latest
local job = lib.os_matrix(oss=['ubuntu-latest', 'macos-latest', 'windows-latest'], steps=
  [
    lib.checkout_step,
    // this must be done after the checkout as opam installs itself
    // locally in the project folder
    {
      uses: 'ocaml/setup-ocaml@v2',
      with: {
        'ocaml-compiler': opam_switch,
        // This is for 'windows-latest', otherwise can't install recent packages
        // like dune 3.7 or ocamlformat 0.26.1
        // We switch from fdopen's opam mingw repo to the official one.
        // Hopefully it works fine with other OSes too.
        // the opam-repository-mingw has the "sunset" branch because it should
        // soon be unecessary once opam 2.2 is released.
        'opam-repositories': |||
           opam-repository-mingw: https://github.com/ocaml-opam/opam-repository-mingw.git#sunset
           default: https://github.com/ocaml/opam-repository.git
        |||,

        //'opam-depext': true,
      },
    },
    lib.cache_opam.step(
      key=opam_switch + '-build-test-' + "${{ hashFiles('hello-world.opam') }}",
      path="_opam",
    ),
    {
      name: 'Debugging the environment',
      // - ocamlc is available only under opam,
      //   so one needs eval $(opam env) (or opam exec) to make it accessible
      // - opam was commented because on windows it is not by default
      //   in the PATH (it needs the CYGWIN_ROOT_BIN adjustment)
      run: |||
        echo '-- native env --'
        env
        echo '-- env under make --'
        make show_env
        echo '-- which make --'
        which make
        echo '-- make --version --'
        make --version
        echo '-- opam --version --'
        export PATH="${CYGWIN_ROOT_BIN}:${PATH}"
        opam --version
        echo '-- ocamlc -v --'
        opam exec -- ocamlc -v
      |||,
    },
    {
      name: 'Install dependencies',
      // TODO: rely on opam depext?
      // since we already have the cache of the switch potentially in _opam we
      // only need to update the switch
      run: |||
        make update
      |||,
    },
    // 
    // alt:
    //  - eval $(opam env) requires bash (windows pwsh would fail),
    //    and requires opam in the PATH (hence CYGWIN_ROOT_BIN adjustment),
    //    but seems to be buggy under windows in GHA and truncate t
    //  - `opam exec -- dune ...` requires opam in the PATH but not
    //     make
    {
      name: 'Build',
      run: |||
          export PATH="${CYGWIN_ROOT_BIN}:${PATH}"
          opam exec -- env
          opam exec -- make
      |||,
    },
    {
      name: 'Test',
      run: |||
         export PATH="${CYGWIN_ROOT_BIN}:${PATH}"
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
