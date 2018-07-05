# This snakemake file defines the pipeline of:
# input: a list of variant
# output: the corresponding scores of two alleles
#
# Note that the deep_variant model will be used
#
# Pipeline in brief:
# 1. variant --> sequence (the flanking region of the variant will be extracted, 499-1-500 by design)
# 2. sequence --> input (HDF5 one-hot coding of sequence)
# 3. input --> score
# 4. score --> output (chr  pos0 pos1  a1  a2  score1  score2)
# input format (in TXT): chr  pos0 pos1  a1  a2 (delimiter = '\t', allele is relative to reference)


rule all:
    input:
        [ '{output_dir}/{name}/output__{label}.bed.gz'.format(name = config['out_prefix'], output_dir = config['out_dir'] if 'out_dir' in config else 'output', label = l)
          for l in list(config['pred_model']['label']) ]



design = config['design'].split('-')
chunk_before = int(design[0])
chunk_after = int(design[-1])
script_dir = config['script_dir'] if 'script_dir' in config else 'scripts'

rule var2seq_var2region:
    input:
        config['var_list']
    output:
        temp('{output_dir}/{name}/var2region.bed')
    params:
        cb = chunk_before,
        ca = chunk_after
    shell:
        '''
        cat {input[0]} | awk -F"\t" -v OFS="\t" '{{
            # if($6=="+") {{
            start=$2-{chunk_before};
            end=$3+{chunk_after};
            # }}
            # else if($6=="-") {{
            #     start=$2-{chunk_after};
            #     end=$3+{chunk_before}
            # }}
            name=$1"@"$2"@"$3"@"$4"@"$5;
            print $1,start,end,name,$5
        }}' > {output[0]}
        '''

rule var2seq_region2seq:
    input:
        '{output_dir}/{name}/var2region.bed',
        config['reference_genome']
    output:
        temp('{output_dir}/{name}/region2seq.tab')
    log:
        '{output_dir}/{name}/region2seq.log'
    shell:
        'bedtools getfasta -fi {input[1]} -bed {input[0]} -fo {output[0]} -name -tab 2> {log}'

rule var2seq_check:
    input:
        '{output_dir}/{name}/region2seq.tab'
    output:
        temp('{output_dir}/{name}/check.passed.REF.tab.gz'),
        temp('{output_dir}/{name}/check.passed.ALT.tab.gz'),
        '{output_dir}/{name}/check.NOTpassed.txt'
    params:
        ifcheck = config['check_allele']
    shell:
        'python {script_dir}/var2seq_check.py \
            --input {input[0]} \
            --output_prefix {wildcards.output_dir}/{wildcards.name}/check \
            --length_before {chunk_before} \
            --length_after {chunk_after} \
            --ifcheck {params.ifcheck}'

rule seq2input:
    input:
        '{output_dir}/{name}/check.passed.{type}.tab.gz'
    output:
        temp('{output_dir}/{name}/input.{type}.hdf5')
    shell:
        'python {script_dir}/seq2input.py --seq_file {input[0]} --out_name {output[0]}'

rule input2score:
    input:
        '{output_dir}/{name}/input.{type}.hdf5',
        config['pred_model']['path']
    output:
        temp('{output_dir}/{name}/raw_score.{type}.hdf5')
    log:
        '{output_dir}/{name}/raw_score.{type}.log'
    shell:
        'python {script_dir}/input2score.py --data {input[0]} --model {input[1]} --output {output[0]} > {log}'

rule score2output:
    input:
        '{output_dir}/{name}/raw_score.REF.hdf5',
        '{output_dir}/{name}/raw_score.ALT.hdf5',
        '{output_dir}/{name}/check.passed.REF.tab.gz'
    output:
        '{output_dir}/{name}/output__{label}.bed.gz'
    params:
        idx = lambda wildcards: config['pred_model']['label'][wildcards.label]
    shell:
        '''
        python {script_dir}/score2output.py \
            --score_ref {input[0]} \
            --score_alt {input[1]} \
            --var {input[2]} \
            --output {output[0]} \
            --label_idx {params.idx}
        '''

rule all_gpu:
    input:
        '{output_dir}/{name}/raw_score.ALT.hdf5'.format(name = config['out_prefix'], output_dir = config['out_dir'] if 'out_dir' in config else 'output'),
        '{output_dir}/{name}/raw_score.REF.hdf5'.format(name = config['out_prefix'], output_dir = config['out_dir'] if 'out_dir' in config else 'output')
