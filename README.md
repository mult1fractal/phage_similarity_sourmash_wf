# Phage Similarity Workflow (sourmash)

Nextflow (DSL2) pipeline for the **taxonomic classification of phages** by
k-mer similarity search with [sourmash](https://sourmash.readthedocs.io/).
Query FASTA sequences are sketched and searched against a sourmash SBT index
built from a reference phage database, returning the best similarity matches
per input sequence.

## Features

- Sketches input genomes with `sourmash sketch dna` (`k=21, scaled=100`)
- Searches sketches against a pre-built sourmash SBT index (`sourmash search`)
- Automatically downloads and builds the reference database on first run:
  - **NCBI RefSeq phages** (`--ncbi_db`)
  - **PhageScope database** (`--phagescope_db`, ~32 GB)
- `storeDir` caching so reference data and search results survive across runs
  and cloud spot-instance interruptions
- Runs locally (`local,docker`) or on Google Cloud Batch (`ukj_cloud`)
- Execution report & timeline generated automatically in `Runinfo/`
- Supports `-resume` for checkpointing

## Requirements

- [Nextflow](https://www.nextflow.io/) **>= 21.04.0**
- [Docker](https://www.docker.com/) (for the `docker` profile)
- A Google Cloud project / batch setup (only for the `ukj_cloud` profile)

## Quick start

```bash
# NCBI RefSeq phage reference database
nextflow run main.nf \
  --fasta /path/to/all_pos_phage.fasta \
  --databases /mnt/6tb_1/nextflow-autodownload-databases/ \
  --ncbi_db \
  --output results/ncbi \
  -profile local,docker \
  -work-dir /mnt/6tb_1/work/

# PhageScope reference database
nextflow run main.nf \
  --fasta '*.fasta' \
  --phagescope_db \
  --output results/phagescope \
  --cores 15 \
  -profile local,docker
```

On the first run the reference sequences are downloaded (from OSF), sketched,
and indexed into `phages.sbt.zip`. On subsequent runs the cached database is
reused.

## Parameters

| Parameter        | Default                  | Description                                                        |
|------------------|--------------------------|--------------------------------------------------------------------|
| `--fasta`        | – (required)             | Input FASTA file(s) / glob pattern                                 |
| `--ncbi_db`      | `false`                  | Use the NCBI RefSeq phage reference database                       |
| `--phagescope_db`| `false`                  | Use the PhageScope reference database (~32 GB)                     |
| `--databases`    | `nextflow-autodownload-databases` | Base directory for downloaded reference databases          |
| `--cores`        | auto                     | CPU cores for the `sourmash` processes (local use)                 |
| `--max_cores`    | auto                     | Max cores for a process (local use)                                |
| `--memory`       | `12`                     | Available memory (local use)                                       |
| `--output`       | `results`                | Name of the result folder                                          |
| `--workdir`      | `false`                  | Path to the temporary files                                        |
| `--help`         | `false`                  | Print usage information and exit                                   |

Exactly one of `--ncbi_db` or `--phagescope_db` should be selected.

## Pipeline overview

The main workflow lives in
[`workflows/sourmash_wf/phage_tax_classification_wf.nf`](workflows/sourmash_wf/phage_tax_classification_wf.nf):

```
query FASTA ──► sourmash_tax ──► {query}.temporary (similarity results)
                    ▲
                    │  phages.sbt.zip
                    │
download_references_* ──► sourmash_*_tax_build (sketch + sourmash index)
```

| Process                                    | Description                                                                 |
|--------------------------------------------|-----------------------------------------------------------------------------|
| `download_references_NCBI` / `download_references_phage_scope` | Downloads reference fasta + metadata from OSF, stored under `--databases` |
| `sourmash_NCBI_tax_build` / `sourmash_phage_scope_tax_build`  | Sketches reference genomes (`k=21, scaled=100`) and builds `phages.sbt.zip` |
| `sourmash_tax`                             | Sketches each query genome and searches it against the SBT index            |
| `split_multi_fasta_2` *(commented out)*     | Optional per-contig split with `seqkit split --by-id`                        |
| `concat_sourmash_results` *(commented out)* | Concatenates per-contig `.temporary` results into a single CSV               |

## Configuration

Main configuration is in [`nextflow.config`](nextflow.config), with
per-profile overrides in [`configs/`](configs):

| File                      | Purpose                                                       |
|---------------------------|---------------------------------------------------------------|
| `configs/container.config`| Docker images per process label (sourmash, python, seqkit, …) |
| `configs/local.config`    | CPU allocation per label for local runs                       |
| `configs/nodes.config`    | CPU / memory / disk allocation for cloud (Batch) runs         |

### Profiles

- `local` – local executor with retry on interrupted exits
- `docker` – enables Docker containers (`configs/container.config`)
- `stub` – reduced cores for stub runs
- `ukj_cloud` – Google Cloud Batch executor with spot instances and bucket
  storage (uses the `noDocker` label for download steps)

## Outputs

- `{output}/Runinfo/execution_report.html` – execution report
- `{output}/Runinfo/execution_timeline.html` – execution timeline
- `{name}.temporary` – sourmash search results (CSV: similarity, md5,
  filename, name, query fields) for each query genome, cached in
  `--tmp_storage` (default `/tmp/nextflow-phage_similarity`)

## Notes

- The PhageScope reference database is ~32 GB; ensure sufficient disk space.
- The NCBI RefSeq phages bundle is downloaded from
  <https://osf.io/4t7zh/download>; the PhageScope bundle from
  <https://osf.io/ew8jg/download>.
- The workflow was designed around on-demand cloud instances (see the cost
  estimate in `main.nf --help`); `storeDir` caches results so an interrupted
  process can be resumed without recomputation.