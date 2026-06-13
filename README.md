# SPI Master-Slave RTL Design and Functional Verification using Verilog,SystemVerilog

## Overview

This project implements a full-duplex SPI (Serial Peripheral Interface) communication system consisting of SPI Master and SPI Slave modules designed in Verilog HDL. The design was verified using a layered SystemVerilog verification environment featuring assertions,functional coverage,scoreboard-based checking and self-checking testbench architecture.

---

## Project Highlights

- SPI Master RTL Design
- SPI Slave RTL Design
- Full-Duplex Communication
- SCLK Generation Logic
- MOSI and MISO Data Transfer
- Chip Select (CS) Control
- SystemVerilog Verification Environment
- Functional Coverage Collection
- Cross Coverage Implementation
- SystemVerilog Assertions (SVA)
- Scoreboard-Based Data Checking
- Mailbox Communication
- Synopsys VCS Simulation
- Synopsys DVE Waveform Analysis

---

## SPI Protocol

SPI uses four signals:

| Signal | Description |
|----------|----------|
| MOSI | Master Out Slave In |
| MISO | Master In Slave Out |
| SCLK | Serial Clock |
| CS | Chip Select |

Protocol Configuration:

- CPOL = 0
- CPHA = 0
- 8-bit Data Transfer
- Full-Duplex Communication

---

## RTL Architecture

### SPI Master

The SPI Master performs:

- Clock Generation
- Chip Select Control
- MOSI Transmission
- MISO Reception
- Transfer Completion Detection

### SPI Slave

The SPI Slave performs:

- MOSI Reception
- MISO Transmission
- Data Capture
- Transfer Completion Detection

---

## Verification Environment

The design was verified using a layered SystemVerilog verification environment.

### Verification Components

- Interface
- Transaction
- Generator
- Driver
- Monitor
- Scoreboard
- Functional Coverage
- Assertions
- Testbench

### Verification Flow

Generator

↓

Driver

↓

SPI DUT

↓

Monitor

↓

Scoreboard

---

## Functional Coverage

Functional coverage was implemented using SystemVerilog covergroups.

### Coverage Points

#### MASTER_TX

- LOW Range
- MID Range
- HIGH Range

#### SLAVE_TX

- LOW Range
- MID Range
- HIGH Range

#### Corner Cases

- 0x00
- 0xFF
- 0xAA
- 0x55

#### Cross Coverage

MASTER_TX × SLAVE_TX

This ensures complete verification of master-slave transaction combinations.

---

## Assertions

The following SystemVerilog Assertions were implemented:

- CS remains HIGH during reset
- DONE remains LOW during reset
- SCLK remains LOW when CS is HIGH
- CS returns HIGH after transaction completion

---

## Scoreboard Checks

The scoreboard verifies successful full-duplex communication.

Checks performed:

```text
MASTER_RX == SLAVE_TX

SLAVE_RX == MASTER_TX
```

All received data is automatically compared against expected values.

---

## Simulation Results

| Metric | Result |
|----------|----------|
| Functional Coverage | PASS |
| Assertions | PASS |
| Scoreboard | PASS |
| Master Receive Check | PASS |
| Slave Receive Check | PASS |

---

# Synthesized and Implemented Design(Using Vivado)

<img width="1485" height="519" alt="image" src="https://github.com/user-attachments/assets/9ce50914-d6b8-44b2-bc85-048e9b389f4d" />

---

## Synopsys VCS Coverage Results

<img width="1600" height="900" alt="image" src="https://github.com/user-attachments/assets/7d5cd2ec-a341-4a1e-a631-6878b4e65396" />


---

## Synopsys DVE Waveform

<img width="1600" height="852" alt="image" src="https://github.com/user-attachments/assets/b4461788-8252-4a04-a52c-063526fc13fb" />


---

## Source Files

### RTL Design

- spi_master.v
- spi_slave.v

### Verification

- spi_if.sv
- spi_transaction.sv
- spi_generator.sv
- spi_driver.sv
- spi_monitor.sv
- spi_scoreboard.sv
- spi_coverage.sv
- spi_assertions.sv
- tb_spi_vip.sv

---

## Tools Used

- Vivado
- Synopsys VCS

---

## Conclusion

A complete SPI Master-Slave communication system was designed using Verilog HDL and verified using a layered SystemVerilog verification environment. Verification included assertions,functional coverage,cross coverage,scoreboard-based checking and corner-case testing. Simulation results demonstrated successful full-duplex SPI communication and protocol compliance.
