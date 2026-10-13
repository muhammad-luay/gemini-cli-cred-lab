# gemini-cli-cred-lab (CI credential-reach lab)

Own-infrastructure security lab for the google-ai VRP engagement (CI-LAB class; own repos only).

Quantifies what a command spawned by untrusted workspace `.gemini/settings.json` can reach at
`@google/gemini-cli` startup on GitHub-hosted runners: child-process env sanitization, parent/process
env visibility, cross-step persistence of a detached background process, and log-masking vs artifact
exfiltration. All "secrets" are dummy canaries planted by this lab; no real credentials are used.

Workflow: `.github/workflows/gemini-trust-cred.yml` (workflow_dispatch) checks out the fork branch
`muhammad-luay/gemini-cli-cred-lab@attacker-cred` (attacker-authored config, owned by the engagement)
and runs gemini-cli 0.63.0 in two modes: raw CLI and the official `google-github-actions/run-gemini-cli@v0`.

Payload is benign collection only (env/process snapshots to per-job artifacts).
