# Project: Neural Network Inference Accelerator on Zedboard - AMD Zynq 7000

# Overview

## **Verilog Part**

- Systolic Array - 2D grid (8x8) of PEs, each PE has a multiplier, accumulator, and internal registers. neural network weights are pre-loaded into the registers of the PEs
- Im2Col (Image-to-Column) Memory - An RTL block using BRAM as FIFOs - flattens the 2D overlapping convolution windows into 1D vectors, and feeds them to Systolic Array as continuous matrices.
- Activation function (ReLU) Datapath - Truncation logic and a simple conditional multiplexer.

## **Role of ARM Cortex-A9 Processor**

If i have no SD card, i will use Xilinx Vitis debugger to push compiled .elf (C code executable) directly into the ZedBoard SRAM via JTAG.

## **The C Code:**

- Initialize the UART driver to listen to your laptop.
- Write the received image bytes into the DDR3 memory
- Initialize the Xilinx AXI DMA engine, pass the source and destination DDR3 address, and the transfer length.
- Trigger the DMA - takes data from DDR3, converts it to an AXI-Stream, and gives to Verilog array
- Wait for the DMA "Transfer Complete" hardware interrupt.
- Read the resulting classification from DDR3 and printf it back to the UART terminal.

## Model

- pre-trained PyTorch model for the MNIST or CIFAR-10 dataset.
- Write a Python script to perform Post-Training Quantization (PTQ) to convert all FP32 weights to INT8 - Export as a weights.h
- Concepts covered: AXI, DMA, RTL, Pipelining, Systolic Arrays, Hardware-Software Co-Design, and Timing Closure

# Complete Project Decomposition

### **1. ARM Cortex-A9 Software (Bare-Metal C)**

Role: Acts as the host controller. Initializes DMA, orchestrates Python-UART communication, manages DDR3 memory buffers.

Dependencies: xaxidma.h, xparameters.h, xuartps.h.

I/O: Receives image via UART, pushes to DDR3 via CPU, pushes to PL via DMA.

Implementation Difficulty: Low. (Already largely completed).

Testing Difficulty: Medium. Requires physical hardware to test UART stability and cache invalidations.

### **2. AXI4-Stream Top-Level Wrapper**

Role: The protocol bridge. Translates AXI handshakes (tvalid, tready, tlast) into internal accelerator enable signals.

Dependencies: Zynq PS reset/clock generation.

I/O: 32-bit AXI-Stream in/out.

Implementation Difficulty: High. Managing backpressure without dropping data packets is notoriously difficult.

Testing Difficulty: High. Requires AXI Verification IP (VIP) in simulation.

### **3. Im2Col (Image-to-Column) BRAM Buffers**

Role: Caches incoming streamed pixels and flattens $3 \times 3$ sliding windows into continuous 1D data streams to feed the systolic array continuously.

Dependencies: Vivado Block Memory Generator (Dual-Port RAM).

I/O: Streamed pixel inputs, parallel vector outputs.

Implementation Difficulty: High. Requires complex read/write pointer management to handle overlapping convolution strides.

Testing Difficulty: Medium. Can be fully simulated using standard Verilog testbenches.

### **4. Weight-Stationary Systolic Array (16x16)**

Role: The compute core. A grid of Processing Elements (PEs) that propagates activations horizontally and partial sums vertically.

Dependencies: None (pure combinational/sequential logic).

I/O: 16-element activation vector in, 16-element partial sum vector out.

Implementation Difficulty: Medium. Heavy use of generate blocks and skewed shift-registers.

Testing Difficulty: Low/Medium. Highly deterministic math; easily verified in Vivado simulation.

### **5. MAC Processing Elements (PE)**

Role: Computes (Activation * Weight) + Partial_Sum.

Dependencies: DSP48E1 slices (inferred by synthesis).

I/O: 8-bit INT8 inputs, 32-bit accumulator outputs.

Implementation Difficulty: Low. Basic synchronous math.

Testing Difficulty: Low.

### **6. ReLU & Requantization Logic**

Role: Truncates the 32-bit accumulated sum back to 8-bit INT8 and clamps negative values to zero.

Dependencies: Systolic Array output.

I/O: 32-bit array in, 8-bit array out.

Implementation Difficulty: Low. Simple bit-shifting and multiplexing.

Testing Difficulty: Low.