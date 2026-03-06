---
name: make-experiment
description: >
  Create an experiment file for a topic in a Wolfram research project. Generates
  TopicExperiment.wl with functions for parameter sweeps, numerical experiments,
  data generation, or benchmarks as specified by the user. Trigger on
  "make experiment for X", "create experiment", "add experiment to X",
  "experiment on X", "run experiments for X", or "parameter sweep for X".
---

# Make Experiment

Creates an experiment file for an existing topic scope.

## What you need

1. **Topic name** — the CamelCase scope name (e.g. `RicciCurvature`).
   Must match an existing `Code/<Topic>.wl`.
2. **What to experiment on** — ask the user what they want to explore:
   parameter sweeps, numerical experiments, data generation, benchmarks, etc.
3. **Project root** — the directory containing `Code/`, `CLAUDE.md`, etc.

If the user already specified the experiment scope, don't ask again.

## What to create

### 1. Experiment code file

Create `Code/<Topic>Experiment.wl`:
```wolfram
(* ::Package:: *)
BeginPackage["<Topic>Experiment`"]

(* experiment function declarations *)

Begin["`Private`"]

(* experiment function definitions *)

End[]
EndPackage[]
```

Populate with functions based on what the user wants. Common patterns:
- `<Topic>ParameterSweep[params___]` — systematic parameter variation
- `<Topic>RunExperiment[config_Association]` — run a configured experiment
- `<Topic>GenerateData[spec_]` — generate datasets
- `<Topic>Benchmark[functions_, inputs_]` — timing comparisons

Each function should return structured results (Associations or Datasets)
suitable for visualization and analysis.

### 2. Add experiments section to topic notebook

Read the existing `<Topic>N.nb` (latest), append an Experiments section using
the read → append → rewrite workflow:

```
## Experiments
  Get["Code/<Topic>Experiment.wl"]

### <ExperimentName1>
  Description of the experiment.
  <example call>
  <visualization of results>

### <ExperimentName2>
  ...
```

If the user prefers a separate notebook, create `<Topic>Experiments1.nb` instead.

### 3. Update CLAUDE.md

Add `<Topic>Experiment.wl` to the Code structure section.

## After creating experiments

Tell the user:
- What experiment functions were created
- Where the experiment code lives
- The notebook section/file where they can run experiments
- Suggest next steps based on the experiment type
