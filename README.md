mocap-dense-trajectories
========================

This code generates dense trajectories similar to [those of Wang et. al](https://lear.inrialpes.fr/people/wang/dense_trajectories), [1]
but generated from mocap data, instead of video sequences. For an extended 
description visit our [project website](http://UBC-CVLab.github.io/mocap-dense-trajectories/).

![The Process in a Nuthsell](https://github.com/UBC-CVLab/mocap-dense-trajectories/blob/master/imgs/nutshell.png?raw=true)

This code was written mainly by [Ankur Gupta](http://www.cs.ubc.ca/~ankgupta/) and [Julieta Martinez](http://www.cs.ubc.ca/~julm/).

Usage
-----
The input is a .bvh file. You can find the entire CMU mocap dataset converted to bvh format [on the internet](https://sites.google.com/a/cgspeed.com/cgspeed/motion-capture/cmu-bvh-conversion).

To generate trajectories from a sample file, run `demo_trajectory_generation`. To see nice visualizations of the process and some of the nuts and bolts of how this is done, run `demo_trajectory_generation_2`.

The main function that you want to call is `imocap2trajectories`. The output is an n-by-(7 + trajectory_length*2) matrix where each row has the following entries:

```
frameNum:     The trajectory ends on this frame
mean_x:       The mean value of the x coordinates of the trajectory
mean_y:       The mean value of the y coordinates of the trajectory
var_x:        The variance of the x coordinates of the trajectory
var_y:        The variance of the y coordinates of the trajectory
length:       The length of the trajectory
scale:        This information is lost due to ortographic projection. Set to -1.
Trajectory:   2x[trajectory length] (default 30 dimension). x and y entries of the trajectory.
```

As opposed to the video dense trajectories, we obviously do not compute visual descriptors along the trajectories.

Citation
--------
If you use this code, please cite our CVPR 14 paper:

```
A. Gupta, J. Martinez, J. J. Little and R. J. Woodham. "Pose from Motion for Cross-view Action Recognition via Non-linear Circulant Temporal Encoding". In CVPR, 2014.
```

Bibtex:
```
@inproceedings{gupta20143dpose,
  title={{3D Pose from Motion for Cross-view Action Recognition via Non-linear Circulant Temporal Encoding}},
  author={Gupta, Ankur and Martinez, Julieta and Little, James J. and Woodham, Robert J.},
  booktitle={CVPR},
  year={2014}
}
```

References
----------

1. Wang, Heng, et al. "Action recognition by dense trajectories." Computer Vision and Pattern Recognition (CVPR), 2011 IEEE Conference on. IEEE, 2011.
2. Katz, Sagi, Ayellet Tal, and Ronen Basri. "Direct visibility of point sets." ACM Transactions on Graphics (TOG). Vol. 26. No. 3. ACM, 2007.


Acknowledgements
----------
We include the following third-party code for user's convenience. We Thank the original authors for making their code publicly available:
- bvh-matlab by Will Robertson. Complete project accessible [here](https://github.com/wspr/bvh-matlab).
- Hidden Point Removal by Sagi Katz. Hosted at [Matlab Central](http://www.mathworks.com/matlabcentral/fileexchange/16581-hidden-point-removal).
- Fast Marching Toolbox by Gabriel Peyré. Hosted [here](https://github.com/gpeyre/matlab-toolboxes).  

