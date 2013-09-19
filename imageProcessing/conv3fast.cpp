/* [response] = conv3fast(volume, kernel);
 * [response] = conv3fast(volume, xKernel, yKernel, zKernel);
 *
 * (c) Francois Aguet, 09/19/2013
 *
 * Compilation:
 * Mac/Linux: mex -I/usr/local/include -I../mex/include conv3fast.cpp
 * Windows: mex COMPFLAGS="$COMPFLAGS /TP /MT" -I"..\mex\include" -output conv3fast conv3fast.cpp
 */

#include <algorithm>
#include "mex.h"
#include "convolver3D.h"

using namespace std;


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

    // check # inputs
    if (nrhs != 2 && nrhs != 4)
        mexErrMsgTxt("Required inputs: image, kernel -or- image, x-kernel, y-kernel, z-kernel.");
    
    // check dimensions
    if (!mxIsDouble(prhs[0]) || mxGetNumberOfDimensions(prhs[0]) != 3)
        mexErrMsgTxt("Input must be a 3D double array.");
    const mwSize* dims = mxGetDimensions(prhs[0]);
    int ny = (int)dims[0]; // reversed: (m,n) -> (y,x)
    int nx = (int)dims[1];
    int nz = (int)dims[2];

    // check kernel vectors
    int nkx = max(mxGetM(prhs[1]),mxGetN(prhs[1]));
    int nky, nkz;
    if (nrhs==4) {
        nky = max(mxGetM(prhs[2]),mxGetN(prhs[2]));
        nkz = max(mxGetM(prhs[3]),mxGetN(prhs[3]));
    } else {
        nky = nkx;
        nkz = nkx;
    }

    // check whether kernels are 1D
    if (nkx!=mxGetNumberOfElements(prhs[1]) ||
            ((nrhs==4) && (nky != mxGetNumberOfElements(prhs[2]) || 
                           nkz != mxGetNumberOfElements(prhs[3]) )))
        mexErrMsgTxt("Kernels must be 1D vectors with an odd number of entries.");

    // check whether input is at least the size of the kernel
    if (2*nkx-1<nx || 2*nky-1<ny || 2*nkz-1<nz)
        mexErrMsgTxt("Kernels must have at least (N+1)/2 elements for each dimension.");

    
    int N = nx*ny*nz;
    double* input = mxGetPr(prhs[0]);
    // check for NaNs in input, as these will result in a crash
    for (int i=0;i<N;++i) {
        if (mxIsNaN(input[i])) {
            mexErrMsgTxt("Input image contains NaNs.");
            break;
        }
    }
    
    double* kx = mxGetPr(prhs[1]);
    double* voxels = new double[N];
    double* buffer = new double[N];
    
    // convolve along 'x' first
    convolveEvenY(input, kx, nkx, ny, nx, nz, voxels); // inverted x,y dims in Matlab
    if (nrhs==2) {
        convolveEvenX(voxels, kx, nkx, ny, nx, nz, buffer);
        convolveEvenZ(buffer, kx, nkx, ny, nx, nz, voxels);
    } else {
        double* ky = mxGetPr(prhs[2]);
        double* kz = mxGetPr(prhs[3]);
        convolveEvenX(voxels, ky, nky, ny, nx, nz, buffer);
        convolveEvenZ(buffer, kz, nkz, ny, nx, nz, voxels);
    }
    
    if (nlhs > 0) {
        plhs[0] =  mxCreateNumericArray(3, dims, mxDOUBLE_CLASS, mxREAL);
        memcpy(mxGetPr(plhs[0]), voxels, N*sizeof(double));
    }
    
    // Free memory
    delete[] buffer;
    delete[] voxels;
}
    