# SBCC 2026 Requirements

Source:

- Main page: `https://sbcc.sdsc.edu/main-page.html`
- Rules: `https://sbcc.sdsc.edu/rules-page.html`

Current SBCC 2026 rules checked on April 7, 2026:

- Apple M1-M5 chips are not allowed.
- Teams must use a minimum of 4 sockets of the same type.
- Teams must run MPI.
- Cluster power limit is 250 W.
- Cluster hardware cost limit is $6,000 MSRP.
- Competition hours and physical-access restrictions apply on April 9-11, 2026.
- HPL efficiency reporting requires a GFLOPS/W table for the tested chips.

## What This Repo Covers

- D-LLAMA can run on Jetson and on multiple nodes using its built-in network transport.
- The Jetson Qwen 3 0.6B tokenizer artifact in `models/qwen3_0.6b_q40/` is corrected and tracked.
- Jetson GPU launchers are tuned for the verified Vulkan path on this host.

## What This Repo Does Not Prove By Itself

- That your cluster has at least 4 sockets.
- That all required sockets are the same type.
- That your total cluster power is at or below 250 W.
- That your total hardware MSRP is at or below $6,000.
- That your competition workflow obeys the SBCC connection and physical-access window.
- That your D-LLAMA workflow uses MPI. The upstream `distributed-llama` transport is socket-based, not MPI-based.

## Practical Interpretation

For SBCC, this repository can cover the D-LLAMA benchmark workload, but it does not by itself make a full SBCC submission compliant.

You still need:

- an MPI-capable cluster environment for the competition requirements,
- a 4-socket minimum hardware design,
- a documented power and MSRP budget,
- an operations plan for the official competition hours.

## Preflight

Run:

```sh
./sbcc_preflight.sh
```

Optional environment variables:

```sh
SBCC_CLUSTER_WATTS=230
SBCC_CLUSTER_MSRP_USD=5400
SBCC_SOCKET_COUNT=4
SBCC_SOCKET_TYPE="Jetson Orin Nano"
./sbcc_preflight.sh
```
