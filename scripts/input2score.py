import argparse
parser = argparse.ArgumentParser(prog='input2score.py', description='''
	Given HDF5 input (dataset named x) and model, make the prediction
	''')
parser.add_argument('--model', help='''
	HDF5 which can be loaded by keras.models.load_model and it takes
    raw data as input
''')
parser.add_argument('--data', help='''
	HDF5 file where input data is saved in x dataset and the dimension
    is (nsamples, window_size, 4)
''')
parser.add_argument('--output')
args = parser.parse_args()

import os
# os.environ['THEANO_FLAGS'] = "device=gpu"
# os.environ['floatX'] = 'float32'

from keras.models import load_model
import h5py
import numpy as np
import sys

print('Loading model')
model = load_model(args.model)

print('Loading data')
xh = h5py.File(args.data,'r')
x = xh['trainxdata'][()]
xh.close()

outfile = args.output

print('Predicting on test sequences')
y = model.predict(x, verbose=1)
ny = int(y.shape[0] / 2)
y = (y[:ny] + y[ny:]) / 2
out = h5py.File(outfile, 'w')
out.create_dataset('y_pred',data=y)
out.close()
