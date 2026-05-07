![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# BFD1000 5 Channel Line follower sensor with clip and obstacle detection
<p align="center">
  <img src="./imgs/BF1000_Sensor.jpg" width="256">
</p>

- [Read the documentation for project](docs/info.md)

<p>
This project implements the combinatory logic for the BFD1000 Line follower sensor. This sensor includes 5 channels for line detection and two additional channels: Clip for collision and Near for distance.
This project was first started as a Wokwi project at https://wokwi.com/projects/461375630008882177
followed by a Verilog implementation for hardware simulations on the Nexuys4 FPGA board.
</p>
## Set up your Verilog project

1. Add your Verilog files to the `src` folder.
2. Edit the [info.yaml](info.yaml) and update information about your project, paying special attention to the `source_files` and `top_module` properties. If you are upgrading an existing Tiny Tapeout project, check out our [online info.yaml migration tool](https://tinytapeout.github.io/tt-yaml-upgrade-tool/).
3. Edit [docs/info.md](docs/info.md) and add a description of your project.
4. Adapt the testbench to your design. See [test/README.md](test/README.md) for more information.

The GitHub action will automatically build the ASIC files using [LibreLane](https://www.zerotoasiccourse.com/terminology/librelane/).

## Resources

- [FAQ](https://tinytapeout.com/faq/)
- [Digital design lessons](https://tinytapeout.com/digital_design/)
- [Learn how semiconductors work](https://tinytapeout.com/siliwiz/)
- [Join the community](https://tinytapeout.com/discord)
- [Build your design locally](https://www.tinytapeout.com/guides/local-hardening/)

## Acknowldgement

This project is carried out with the support of the IEEE Open Silicon initiative. and TinyTapout project, to learn more and get started, visit https://tinytapeout.com.
