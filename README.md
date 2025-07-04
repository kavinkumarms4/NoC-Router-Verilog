# Network-on-Chip (NoC) Router – Verilog Implementation

This project implements a parameterized **5-port NoC router** using Verilog HDL. It is intended for educational, experimental, and VLSI prototyping purposes.

## Overview

The router is designed for use in a 2D mesh Network-on-Chip (NoC) topology, supporting the following ports:
- Local
- North
- South
- East
- West

Each port receives and transmits 8-bit wide packets using a simple, credit-based handshake protocol.

## Packet Format

Each packet is 8 bits wide and structured as follows:

[7:6] -> Destination X coordinate (2 bits)  
[5:4] -> Destination Y coordinate (2 bits)  
[3:0] -> Payload (4 bits)

## Features

- XY-based deterministic routing
- FIFO buffering on all input ports
- Ready/valid handshake mechanism
- Scalable to mesh topologies (e.g., 4x4 or larger)

## Routing Logic

The router uses XY routing, where:
1. The packet is first forwarded in the X-direction (East or West) until the X-coordinate matches.
2. Then forwarded in the Y-direction (North or South) until the Y-coordinate matches.
3. If both coordinates match, the packet is sent to the Local port.

This approach is simple, deadlock-free, and deterministic.

## Directory Structure

noc-router/
├── src/
│   ├── router.v        # Top-level router module
│   └── fifo.v          # Parameterized FIFO buffer
│
├── tb/
│   └── router_tb.v     # Functional testbench with stimuli
│
├── doc/
│   └── diagram.png     # Optional: Router architecture diagram
│
├── waveform/
│   └── sim_wave.png    # Optional: Vivado simulation waveform
│
├── README.md           # Project documentation
├── LICENSE             # Open-source license (MIT recommended)
└── .gitignore          # Version control exclusions

## Testbench

A simple testbench is provided to simulate and verify the router behavior. It feeds packets to the Local port with various destination coordinates and observes routing toward East, North, etc.

## Simulation Tool

- Developed and simulated using Vivado 2024.2
- Functional waveform verification completed

## Future Enhancements

- Parameterized payload width
- Virtual channel support
- Round-robin arbitration
- Multi-router NoC grid integration
- AXI-Stream or Wishbone interface wrappers

## Author

Kavin Kumar M S  
Electronics Engineering Undergraduate  
LinkedIn: https://www.linkedin.com/in/kavinkumarms
