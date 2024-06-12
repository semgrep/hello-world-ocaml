// ----------------------------------------------------------------------------
// OPAM caching
// ----------------------------------------------------------------------------
// copy pasted from semgrep.libsonnet in the semgrep repo
local cache_opam = {
  step(key, path="~/.opam"): {
    name: 'Set GHA cache for OPAM in ' + path,
    uses: 'actions/cache@v3',
    env: {
      SEGMENT_DOWNLOAD_TIMEOUT_MINS: 2,
    },
    with: {
      path: path,
      key: '${{ runner.os }}-${{ runner.arch }}-opam-deps-%s' % key,
    },
   },
   // to be used with workflow_dispatch and workflow_call in the workflow
  inputs(required): {
    inputs: {
    'use-cache': {
      description: 'Use Opam Cache - uncheck the box to disable use of the opam cache, meaning a long-running but completely from-scratch build.',
      required: required,
      type: 'boolean',
      default: true,
    },
  }
  },
  if_cache_inputs: {
    'if': '${{ inputs.use-cache}}'
  },
};


// ----------------------------------------------------------------------------
// Entry point
// ----------------------------------------------------------------------------

{
  checkout_step: {
    uses: 'actions/checkout@v3',
    with: {
      submodules: true,
    },
  },
  cache_opam: cache_opam,
  on_classic: {
    // can be run manually from the GHA dashboard
    workflow_dispatch: null,
    // on the PR
    pull_request: null,
    // and another time once the PR is merged on develop
    push: {
      branches: [
        'main',
      ],
    },
  },
  // For making matrix jobs, i.e. one job running on multiple OSes.
  os_matrix(oss=['ubuntu-latest', 'macos-latest', 'windows-latest'], steps): {
    strategy: {
      matrix: {
        os: oss,
      },
    },
    'runs-on': '${{ matrix.os }}',
    defaults: {
    run: {
      // Windows GHA runners default to pwsh (PowerShell) but we want bash
      // to be consistent.
      shell: 'bash',
    },
  },
    steps: steps,
  },
}
