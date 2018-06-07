import argparse
parser = argparse.ArgumentParser(prog='var2seq_check.py', description='''
    Check if extracted sequence match the reference
''')
parser.add_argument('--input')
parser.add_argument('--output_prefix')
parser.add_argument('--length_before', type = int)
parser.add_argument('--length_after'. type = int)
parser.add_argument('--ifcheck', type = bool)
args = parser.parse_args()

import h5py
import gzip

good_ref_out = gzip.open('{prefix}.passed.REF.tab.gz'.format(prefix = args.output_prefix), 'wt')
good_alt_out = gzip.open('{prefix}.passed.ALT.tab.gz'.format(prefix = args.output_prefix), 'wt')
bad_out = open('{prefix}.NOTpassed.txt'.format(prefix = args.output_prefix), 'w')
if args.ifcheck == True:
    with open(args.input, 'r') as f:
        for line in f:
            line = line.strip()
            line = line.split('\t')
            seq = line[0]
            name = line[1]
            (chrm, start, end, a1, a2, strand) = name.split('-')
            ref_char = seq[length_before].upper()
            if ref_char != a1.upper():
                bad_out.write('\t'.join((chrm, start, end, a1, a2, strand, 'ref_char={ref_char}'.format(ref_char = ref_char))) + '\n')
            else:
                good_ref_out.write('\t'.join((seq, name)) + '\n')
                good_alt_out.write('\t'.join(seq[:args.length_before] + a2 + seq[args.length_after:], name) + '\n')
elif args.ifcheck == False:
    with open(args.input, 'r') as f:
        for line in f:
            line = line.strip()
            line = line.split('\t')
            seq = line[0]
            name = line[1]
            (chrm, start, end, a1, a2, strand) = name.split('-')
            ref_char = seq[length_before].upper()
            good_ref_out.write('\t'.join((seq, name)) + '\n')
            good_alt_out.write('\t'.join(seq[:args.length_before] + a2 + seq[args.length_after:], name) + '\n')
bad_out.close()
good_ref_out.close()
good_alt_out.close()
