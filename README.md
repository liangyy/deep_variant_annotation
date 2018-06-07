## Input format

See `test_var.txt` as an example.

In brief, TAB-delimited TEXT file is required. Each row is a variant, column 1-5 are: chromosome, position (0-based), position (1-based), reference allele, alternative allele. Note that allele is relative to forward strand in reference genome assembly.

## Pipeline usage

The pipeline is built upon `snakemake`. A configuration file is needed which provides the path of input variant list and which labels are planned to predict for.

An example configuration file is `config.test.yaml`

1. `out_prefix`: Specify the output directory. For instance, `config.test.yaml` makes output to `output/my-test/`
2. `pred_model`: Contain information of predictive model being used. For each model, it can predict labels of multiple genomic annotations, so label index should also be provided
3. `reference_genome`: The genome assembly which matches the input variant file
4. `check_allele`: True or False. If True, the pipeline will check whether the reference allele specified in variant list matches the genome assembly provided. For instance, it will be at `output/my-test/check.NOTpassed.txt` for `config.test.yaml`
5. `design`: The model will take the 1000-bp flanking window of the variant to predict the score. Here, `design` specifies how many bps before/after the variant

## Setting up computing environment

The easiest way to do this is

```
$ cd /project2/xinhe/yanyul
$ source setup.sh
$ source activate deepvarpred_test
```

**CAUTION**: It may overwrite your own `.bashrc` or `.bash_profile` so the best practice is to work on an independent login or on cluster

## Running on RCC

See an example `sbatch` at `sbatch/test.sbatch`. To use `sinteractive` follows similar idea.
