# Image processing

[![Build Status](https://travis-ci.com/hdl-util/image.svg?branch=master)](https://travis-ci.com/hdl-util/image)

SystemVerilog code for image processing tasks like [demosaicing](https://en.wikipedia.org/wiki/Demosaicing).

## Why?

I implemented raw camera video playback, but wanted a place to keep the demosaic algorithm logic and share it with others.

## Usage

1. Take files from `src/` and add them to your own project. If you use [hdlmake](https://hdlmake.readthedocs.io/en/master/), you can add this repository itself as a remote module.
1. Other helpful modules are also available in this GitHub organization.
1. Consult the testbench in `test/demosaic_tb.sv` for example usage.
1. Read through the parameter descriptions in `demosaic.sv` and tailor any instantiations to your situation.
1. Please create an issue if you run into a problem or have any questions.

## To-do List

* [x] [Malvar-He-Cutler](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/Demosaicing_ICASSP04.pdf) demosaic algorithm
* [ ] More upon request

## Reference Documents

* [High-Quality Linear Interpolation for Demosaicing of Bayer-Patterned Color Images](https://www.microsoft.com/en-us/research/publication/high-quality-linear-interpolation-for-demosaicing-of-bayer-patterned-color-images/)
