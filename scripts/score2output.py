import argparse
parser = argparse.ArgumentParser(prog='score2output.py', description='''
	Take raw score and output score in BED format
''')
parser.add_argument('--score_ref', help='''
	Raw score in HDF5 for reference allele
''')
parser.add_argument('--score_alt', help='''
	Raw score in HDF5 for alternative allele
''')
parser.add_argument('--var', help='''
	List of variants which are input to input2score.py
''')
parser.add_argument('--label_idx', type = int, help='''
        Index of output label (1-based)
''')
parser.add_argument('--output')
args = parser.parse_args()

import h5py
import gzip

def read_data(filename):
    yh = h5py.File(filename, 'r')
    yp = yh.get('y_pred')
    # yp = yh['y_pred'][()]
    # yh.close()
    return (yp, yh)

(yref, yh1) = read_data(args.score_ref)
yref = yref[:, args.label_idx - 1]
(yalt, yh2) = read_data(args.score_alt)
yalt = yalt[:, args.label_idx - 1]

o = gzip.open(args.output, 'wt')

with gzip.open(args.var, 'rt') as f:
    i = 0
    for line in f:
        line = line.strip()
        line = line.split('\t')
        seq = line[0]
        name = line[1]
        (chrm, start, end, a1, a2) = name.split('@')
        ref = yref[i]
        alt = yalt[i]
        i += 1
        o.write('\t'.join((chrm, start, end, a1, a2, str(ref), str(alt))) + '\n')
o.close()
yh1.close()
yh2.close()
