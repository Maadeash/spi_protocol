# SPI Protocol Design using Verilog

## Introduction

SPI (Serial Peripheral Interface) is a synchronous serial communication protocol used for fast data transfer between a master device and one or more slave devices.

SPI uses separate lines for clock and data transfer, making it faster than asynchronous communication protocols.

SPI is widely used in:

- Sensors
- Flash memory
- ADC/DAC interfaces
- Display modules
- FPGA communication
- Embedded systems

SPI mainly uses four signals:

- MOSI (Master Out Slave In)
- MISO (Master In Slave Out)
- SCLK (Serial Clock)
- CS (Chip Select)

This project implements SPI Mode 0 communication between SPI master and SPI slave modules.

---

# Features of SPI

- Synchronous serial communication
- Full duplex communication
- Master-slave architecture
- High-speed communication
- Simple hardware implementation
- Edge-based data transfer

---

# SPI Mode Used

This project uses:

- SPI Mode 0
- Clock idle LOW
- Data sampled on clock rising edge
- Data shifted on clock falling edge

---

# SPI Architecture

The design consists of:

- SPI Master
- SPI Slave
- Verilog Testbench

The SPI master generates:

- SCLK
- CS
- MOSI

The SPI slave generates:

- MISO

---

# SPI Operation

## Master Operation

The SPI master performs the following operations:

- Waits for start signal
- Loads transmit data
- Generates serial clock
- Sends data through MOSI
- Receives data through MISO
- Indicates transfer completion

---

## Slave Operation

The SPI slave performs the following operations:

- Detects chip select activation
- Receives data from MOSI
- Sends data through MISO
- Stores received data
- Indicates valid received data

---

# Important SPI Signals

| Signal | Description |
|--------|-------------|
| clk | System clock |
| rst | Reset signal |
| start | Starts SPI transfer |
| data_in | Parallel input data |
| data_out | Parallel output data |
| mosi | Master Out Slave In |
| miso | Master In Slave Out |
| sclk | Serial clock |
| cs | Chip select |
| busy | Transfer in progress |
| done | Transfer complete |
| data_ready | Slave data availability |
| data_valid | Received data valid |

---

# SPI Master FSM

The SPI master uses the following FSM states:

## IDLE
- Waits for start signal

## LOAD
- Loads transmit data
- Activates chip select

## TRANSFER
- Sends and receives serial data
- Generates SPI clock

## FINISH
- Ends communication
- Returns to IDLE state

---

# SPI Slave FSM

The SPI slave uses the following FSM states:

## IDLE
- Waits for chip select activation

## TRANSFER
- Receives MOSI data
- Sends MISO data

## COMPLETE
- Transfer completed
- Waits for chip select release

---

# Clock Operation

In SPI Mode 0:

- MOSI data changes on falling edge of SCLK
- MISO data is sampled on rising edge of SCLK

---

# Tools Used

- Vivado

---

# Languages Used

## Design
- Verilog HDL

## Testbench
- Verilog

---

# Testbench

A Verilog testbench was created to verify SPI communication between master and slave modules.

The testbench verifies:

- SPI clock generation
- MOSI transmission
- MISO reception
- Chip select operation
- Data transfer correctness

---


# Synthesized and Implemented Design

<img width="1485" height="519" alt="image" src="https://github.com/user-attachments/assets/9ce50914-d6b8-44b2-bc85-048e9b389f4d" />

---


# Output Waveforms

<img width="1553" height="716" alt="image" src="https://github.com/user-attachments/assets/35015d98-c004-4852-96eb-641eaa7816d8" />


---

# Source Files

## Design Files

- spi_master.v
- spi_slave.v

## Testbench File

- spi_tb.v

---


# Applications of SPI

- Flash memory communication
- Sensor interfacing
- ADC/DAC communication
- Display modules
- FPGA peripheral communication

---

# Conclusion

SPI protocol was successfully designed using Verilog HDL. The project includes SPI master and SPI slave modules operating in SPI Mode 0. Simulation results verified correct serial data communication between master and slave using the Verilog testbench.
