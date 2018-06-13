"DASHing Towards Hollywood"
---------------------------

This software artefact has been made available in support of the following publication:
	Ahsan, S., McQuistin, S., Perkins, C.  and Ott, J. (2018) DASHing Towards
	Hollywood. In: ACM Multimedia Systems Conference (MMSys 2018), Amsterdam, The
	Netherlands, 12-15 June 2018
	
	DOI: https://doi.org/10.1145/3204949.3204959
	
To aid with reproducibility, this artefact includes all of the source code used in
generating the results described in this paper, alongside a Makefile that describes and
performs the process of performing the experiments, processing and graphing the results,
and producing the paper.

To generate the paper, the following dependencies must be installed:

	- FFmpeg (3.4.2)
	- Python (2.7)
	- R (3.4.3) and packages (rkvo, ggplot2, data.table)
	- Vagrant (2.0.2)
	- VirtualBox (5.2.6r120293)
	- xz (5.2.3)

Building the paper using the Makefile provided may take several days. Appendix A of the
paper (https://doi.org/10.1145/3204949.3204959) describes the various stages of the
build process, alongside estimates of how long they may take on typical hardware.

The code and software included is subject to the licence contained in the LICENCE file.
