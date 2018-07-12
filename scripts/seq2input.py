import argparse
parser = argparse.ArgumentParser(prog='seq2input', description='''
    Given the formatted output from 1_snp2pos.py (second column is the sequence),
    output the hdf5 file which is ready to be used as the input for making the
    prediction. For efficiency, please provide the length of the sequence as well.
    ''')
parser.add_argument('--seq_file', help='''
    Ideally, it is the output of 1_snp2seq.py but you may use any file unless the
    second column is the sequence of interest.
''')
parser.add_argument('--out_name')
parser.add_argument('--window', default=1000, type=int)
parser.add_argument('--debug', default=False)
args = parser.parse_args()

import subprocess

def mySubprocess(cmd, debug):
    if debug is False:
        result = subprocess.check_output(cmd, shell=True)
        return result
    else:
        print(cmd)


import numpy as np
import os
import h5py
import gzip

cmd = '''zcat {file} | wc -l'''.format(file=args.seq_file)
length = mySubprocess(cmd, args.debug)
if args.debug is True:
    sys.exit()
huge_array = np.zeros((int(length), args.window, 4), np.uint8)
encode = {'A': 0, 'T': 3, 'G': 1, 'C': 2}

counter = 0
with gzip.open(args.seq_file, 'rt') as infile:
    for line in infile:
        seq = line.strip().split('\t')[0].upper()
        digit_seq = np.zeros((args.window, 4))
        for i in range(len(seq)):
            if seq[i] not in encode:
                continue
            else:
                digit_seq[i, encode[seq[i]]] = 1
        huge_array[counter] = np.uint8(digit_seq)
        counter += 1

huge_array_flip = huge_array[:,::-1,::-1]
huge_array = np.concatenate([huge_array, huge_array_flip],axis=0)
out = args.out_name
f = h5py.File(out, 'w')
f.create_dataset('trainxdata', data=huge_array)
f.close()
